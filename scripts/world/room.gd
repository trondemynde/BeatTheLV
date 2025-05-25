extends Node2D
class_name Room

signal room_cleared
enum RoomType {NORMAL, START, SHOP, BOSS}


@export var room_type: RoomType = RoomType.NORMAL
@export var room_size := Vector2(1190, 648)
@export var max_enemies := 5
@export var enemy_scenes: Array[PackedScene]
@export var spawn_area: Rect2 = Rect2(-400, -300, 800, 600)  # Area relative to room center

var enemies_spawned := false
var is_cleared := false
var current_enemies := 0
var doors := []
var is_player_inside := false

func _ready() -> void:
	add_to_group("rooms")
	
	if has_node("SpawnAreaVisualizer"):
		var visualizer = $SpawnAreaVisualizer
		if visualizer.has_method("get_rect"):  # kui see on nt CollisionShape2D või Area2D + script
			spawn_area = visualizer.get_rect()
		elif visualizer is CollisionShape2D:
			var shape = visualizer.shape
			if shape is RectangleShape2D:
				spawn_area = Rect2(
					visualizer.position - shape.extents, #what dis doooo
					shape.extents * 2
				)
	 
	if room_type != RoomType.NORMAL:
		is_cleared = true
		return
	
	doors = [
		get_node_or_null("Doors/DoorTop"),
		get_node_or_null("Doors/DoorRight"),
		get_node_or_null("Doors/DoorLeft"),
		get_node_or_null("Doors/DoorBottom")
	]
	$PlayerDetector.connect("body_entered", _on_player_entered)
	$PlayerDetector.connect("body_exited", _on_player_exited)

func _on_player_entered(body):
	if !body.is_in_group("player") or is_cleared:
		return

	is_player_inside = true  # margib ruum aktiivseks

	if !enemies_spawned:
		spawn_enemies()
		lock_doors(true)
	elif current_enemies <= 0:
		lock_doors(false)
		is_cleared = true
		room_cleared.emit()

func _on_player_exited(body):
	if body.is_in_group("player"):
		is_player_inside = false

#func _on_player_entered(body):
	#if !body.is_in_group("player") or is_cleared:
		#return
	#
	#if !enemies_spawned:
		#spawn_enemies()
		#lock_doors(true)
	#elif current_enemies <= 0:
		#lock_doors(false)
		#is_cleared = true
		#room_cleared.emit()

#func spawn_enemies():
	#enemies_spawned = true
	#current_enemies = randi_range(1, max_enemies)
	#
	#var spawn_area_node = $SpawnAreaVisualizer
	#var shape = spawn_area_node.get_node("CollisionShape2D").shape as RectangleShape2D
	#var extents = shape.extents
	#var area_pos = spawn_area_node.global_position
	#
	#for i in range(current_enemies):
		#await get_tree().create_timer(randf_range(0, 0.3)).timeout
		#var enemy = enemy_scenes.pick_random().instantiate()
		#enemy.connect("tree_exiting", _on_enemy_died)
		#add_child(enemy)
#
		#var offset = Vector2(
			#randf_range(-extents.x, extents.x),
			#randf_range(-extents.y, extents.y)
		#)
		#enemy.global_position = area_pos + offset
		#print("Spawned enemy at:", enemy.global_position)

func spawn_enemies():
	if !is_player_inside:
		print("Skipping spawn, player not in this room.")
	else:
		enemies_spawned = true
		current_enemies = randi_range(1, max_enemies)

		for i in range(current_enemies):
			await get_tree().create_timer(randf_range(0, 0.3)).timeout
			var enemy = enemy_scenes.pick_random().instantiate()
			enemy.connect("tree_exiting", _on_enemy_died)
			add_child(enemy)

			var local_spawn_pos = Vector2(
				randf_range(spawn_area.position.x, spawn_area.end.x),
				randf_range(spawn_area.position.y, spawn_area.end.y)
			)
			enemy.global_position = to_global(local_spawn_pos)
			print("Spawned enemy at:", enemy.global_position)

#func spawn_enemies():
	#enemies_spawned = true
	#current_enemies = randi_range(1, max_enemies)
	#
	#for i in range(current_enemies):
		#await get_tree().create_timer(randf_range(0, 0.3)).timeout
		#var enemy = enemy_scenes.pick_random().instantiate()
		#enemy.connect("tree_exiting", _on_enemy_died)
		#add_child(enemy)
		#var local_spawn_pos = Vector2(
			#randf_range(spawn_area.position.x, spawn_area.end.x),
			#randf_range(spawn_area.position.y, spawn_area.end.y)
		#)
		#enemy.global_position = to_global(local_spawn_pos)
		#print("Spawned enemy at:", enemy.global_position)

#func spawn_enemies():
	#enemies_spawned = true
	#current_enemies = randi_range(1, max_enemies)
	#
	#for i in current_enemies:
		#await get_tree().create_timer(randf_range(0, 0.3)).timeout
#
		#if enemy_scenes.size() == 0:
			#push_error("enemy_scenes array is empty!")
			#continue
#
		#var enemy_scene = enemy_scenes[randi() % enemy_scenes.size()]
		#if enemy_scene == null:
			#push_error("Null enemy scene found in enemy_scenes!")
			#continue
#
		#var enemy = enemy_scene.instantiate()
		#enemy.connect("tree_exiting", _on_enemy_died)
		#add_child(enemy)
		#enemy.global_position = global_position + Vector2(
			#randf_range(spawn_area.position.x, spawn_area.end.x),
			#randf_range(spawn_area.position.y, spawn_area.end.y)
		#)


func _on_enemy_died():
	current_enemies -= 1
	print("Enemy died, remaining:", current_enemies)
	if current_enemies <= 0 and enemies_spawned:
		lock_doors(false)
		print("doors unlocked")
		is_cleared = true
		print("room cleared")
		room_cleared.emit()

func lock_doors(locked: bool):
	for door in doors:
		if door:
			door.monitoring = !locked  # Disable detection when locked
			door.visible = !locked  # Visual feedback

	# Visual effect (optional)
	#if locked:
		#$LockedParticles.emitting = true
