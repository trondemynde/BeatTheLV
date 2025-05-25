extends Node2D
class_name Room

signal room_cleared
enum RoomType {NORMAL, START, SHOP, BOSS}


@export var room_type: RoomType = RoomType.NORMAL
@export var room_size := Vector2(1190, 648)
@export var max_enemies := 5
@export var enemy_scenes: Array[PackedScene]
@export var boss_scene: PackedScene
@export var spawn_area: Rect2 = Rect2(-400, -300, 800, 600)  # Area relative to room center

var enemies_spawned := false
var is_cleared := false
var current_enemies := 0
var doors := []
var boss_ref = null 

func _ready() -> void:
	add_to_group("rooms")
	
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
	
	if room_type == RoomType.BOSS:
		is_cleared = false
	if room_type != RoomType.NORMAL:
		is_cleared = true

func _on_player_entered(body):
	if !body.is_in_group("player") or is_cleared:
		return
	
	if !enemies_spawned:
		spawn_enemies()
		lock_doors(true)
	elif current_enemies <= 0:
		lock_doors(false)
		is_cleared = true
		room_cleared.emit()

func spawn_enemies():
	enemies_spawned = true
	current_enemies = randi_range(1, max_enemies)
	
	for i in current_enemies:
		await get_tree().create_timer(randf_range(0, 0.3)).timeout
		var enemy = enemy_scenes.pick_random().instantiate()
		enemy.connect("tree_exiting", _on_enemy_died)
		add_child(enemy)
		enemy.global_position = global_position + Vector2(
			randf_range(spawn_area.position.x, spawn_area.end.x),
			randf_range(spawn_area.position.y, spawn_area.end.y)
		)

func _on_enemy_died():
	current_enemies -= 1
	if current_enemies <= 0 and enemies_spawned:
		lock_doors(false)
		is_cleared = true
		room_cleared.emit()

func lock_doors(locked: bool):
	for door in doors:
		if door:
			door.monitoring = !locked  # Disable detection when locked
			door.visible = !locked  # Visual feedback

	# Visual effect (optional)
	#if locked:
		#$LockedParticles.emitting = true
