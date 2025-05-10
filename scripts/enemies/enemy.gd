extends Node2D

@export var health = 100
@export var move_speed = 400
@export var swing_speed = 0.5
@export var damage = 5
@onready var player = get_node("root/main/Player1")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#move enemy toward playerr
	if player:
		var direction = (player.global_position - global_position).normalized()
		position += direction * move_speed * delta

func deal_damage(body):
	#player_health - damage
	pass

func take_damage():
	health -= 5
	if health <= 0:
		queue_free()

func swing():
	#animation
	#sound
	#$melee dwjaka 
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	swing()
	deal_damage(body)
