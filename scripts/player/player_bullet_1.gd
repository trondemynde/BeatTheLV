extends Area2D


@export var speed := 800.0
@export var damage := 10
@export var stop_on_impact := true
@export var impact_effect_duration := 0.2


var direction := Vector2.RIGHT
var is_moving := true
var hit_something := false


func _ready() -> void:
	rotation = direction.angle()
	$AnimatedSprite2D.play("default")
	
func _physics_process(delta):
	if is_moving and not hit_something:
		position += direction * speed * delta

func _on_body_entered(body):
	if hit_something:
		return
	print("hit")
	
	hit_something = true
	
	if stop_on_impact:
		is_moving = false
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimatedSprite2D/GPUParticles2D.set_visible(false)
		if body.has_method("take_damage"):
			body.take_damage()
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.play("hit")
			await $AnimatedSprite2D.animation_finished
	queue_free()
	#if body.is_in_group("Wall"):
		#$AnimatedSprite2D.play("hit")
		#await $AnimatedSprite2D.animation_finished 
		#queue_free() 
