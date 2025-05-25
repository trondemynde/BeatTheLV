extends Area2D

@export var speed := 300.0
@export var damage := 5
var direction := Vector2.RIGHT

func _ready():
	rotation = direction.angle()

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
	queue_free()
