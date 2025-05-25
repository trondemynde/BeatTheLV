extends CharacterBody2D

#player variables
@export var move_speed := 300.0
@export var dash_speed := 1200.0
@export var dash_duration := 0.15
@export var dash_cooldown := 0.5
@onready var sprite := $AnimatedSprite2D
#dash
var is_dashing := false	
var can_dash := true
var dash_direction := Vector2.ZERO


#shooting
@export var bullet_scene: PackedScene
@export var fire_rate := 0.2 
var can_shoot := true


#for camera
@onready var camera: Camera2D = $Camera2D
var current_room: Node2D = null

func _ready():
	# Configure camera
	camera.zoom = Vector2(0.7, 0.7)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 3.0
	camera.limit_smoothed = true
	$AnimatedSprite2D.play("default_1")
	#$AnimatedSprite2D.flip_h = true
	

func _physics_process(_delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if Input.is_action_just_pressed("dash"):
		start_dash(input_dir)
		
	if is_dashing:
		velocity = dash_direction * dash_speed
	else: 
		velocity = input_dir * move_speed
		
	move_and_slide()
	
	var new_room = _get_current_room()
	if new_room and new_room != current_room:
		_transition_to_room(new_room)

#	movement direction
	if input_dir.x != 0:
		sprite.flip_h = input_dir.x < 0

	#if input_dir.length() > 0: #for animations
		#sprite.play("run")
	#else:
		#sprite.play("idle")

func start_dash(direction:Vector2):
	is_dashing = true
	can_dash = false
	dash_direction = direction.normalized()
	
#	dash duration
	await get_tree().create_timer(dash_duration).timeout
	is_dashing = false
#	cooldown
	await  get_tree().create_timer(dash_cooldown).timeout
	can_dash = true	

#func flip_player(event): #input nussib muidu tootab
#	if event.is_action_pressed("move_left"):
#		$AnimatedSprite2D.flip_h = true
#		if event.is_action_released("move_left"):
#			$AnimatedSprite2D.flip_h = false
#
#func flip_player1(direction):
#	if direction.x < 0:
#		$AnimatedSprite2D.flip_h = true
#	elif direction.x > 0:
#		$AnimatedSprite2D.flip_h = false

func _process(_delta):
	add_to_group("player")
#	camera controls
	camera.zoom = Vector2(1,1)
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 5.0
	
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot():
	if not bullet_scene: return
	var bullet = bullet_scene.instantiate()
	bullet.direction = (get_global_mouse_position() - global_position).normalized()
	bullet.position = global_position
	get_parent().add_child(bullet)
	can_shoot = false
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

#	for camera controls
func _get_current_room() -> Node2D:
	var rooms = get_tree().get_nodes_in_group("rooms")
	
	for room in rooms:
		var room_rect = Rect2(room.position, room.room_size)
		if room_rect.has_point(global_position):
			return room
	return null
	
func _transition_to_room(room:Node2D):
	current_room = room
	
	camera.limit_left = room.position.x
	camera.limit_top = room.position.y
	camera.limit_right = room.position.x + room.room_size.x
	camera.limit_bottom = room.position.y + room.room_size.y
	
	_screen_shake(0.4, 0)

func _screen_shake(duration: float, strength: float):
	var shake_timer = Timer.new()
	add_child(shake_timer)
	shake_timer.wait_time = duration
	shake_timer.one_shot = true
	
	var original_offset = camera.offset
	
	shake_timer.timeout.connect(func():
		camera.offset = original_offset
		shake_timer.queue_free()
	)
	
	# Apply random offset during shake
	for i in range(10):
		camera.offset = original_offset + Vector2(
			randf_range(-strength, strength),
			randf_range(-strength, strength)
		)
		await get_tree().create_timer(duration/10).timeout
	
	shake_timer.start()
