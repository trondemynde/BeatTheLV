extends CharacterBody2D

@export var health = 100
@export var move_speed = 400
@export var swing_speed = 0.5
@export var damage = 5
@onready var player = get_node("/root/Main/Player1")
var enemies = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * 100.0
	move_and_slide()

func deal_damage(_body):
	#player_health - damage
	pass

#see paks ei saa uksest labi
func die():
	emit_signal("enemy_died")
	queue_free()

func take_damage():
	health -= 20
	print(health)
	if health == 0:
		queue_free()

func swing():
	#animation
	#sound
	#$melee dwjaka 
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	swing()
	deal_damage(body)
