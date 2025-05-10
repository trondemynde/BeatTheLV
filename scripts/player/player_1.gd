extends CharacterBody2D

@export var move_speed := 300.0

@export var bullet_scene: PackedScene
@export var fire_rate := 0.2 
var can_shoot := true

func _process(delta):
	add_to_group("player")
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

func _physics_process(delta):
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * move_speed
	move_and_slide()
