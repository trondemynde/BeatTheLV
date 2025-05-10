extends Area2D


@export var speed := 800.0
@export var damage := 1
var direction := Vector2.RIGHT

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	print("hit")
	if body.is_in_group("Wall"):
		queue_free() 
	elif body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()
