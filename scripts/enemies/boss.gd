extends CharacterBody2D
class_name Boss

@export var max_health := 500
@export var phase2_health := 300
@export var phase3_health := 100

var current_health: int
var current_phase := 1
var is_active := false

func _ready():
	current_health = max_health
	$HealthBar.max_value = max_health
	$HealthBar.value = current_health
	#$AnimatedSprite2D.play("idle")

func activate():
	is_active = true
	$PhaseTimer.start()
	start_phase_attacks()

func take_damage():
	if !is_active: return
	
	current_health -= 20
	$HealthBar.value = current_health
	#$AnimatedSprite2D.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	#$AnimatedSprite2D.modulate = Color.WHITE
	
	_on_phase_timer_timeout()
	
	if current_health <= 0:
		die()

func _physics_process(delta):
	if is_active:
		var player = get_tree().get_nodes_in_group("Player")[0]
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * 100
		move_and_slide()

func enter_phase(number: int):
	current_phase = number
	$PhaseTimer.wait_time *= 0.7  # Faster attacks each phase
	#$AnimatedSprite2D.play("phase_" + str(number))

	match number:
		2:
			$AttackPatterns/BulletCircle.wait_time *= 0.5
		3:
			$AttackPatterns/ChargeAttack.wait_time *= 0.3

func start_phase_attacks():
	var attack_timers = [
		$AttackPatterns/ChargeAttack,
		$AttackPatterns/BulletCircle,
		$AttackPatterns/SlamAttack
	]
	
	for timer in attack_timers:
		timer.start(randf_range(1.0, 3.0))

func _on_charge_attack_timeout():
	pass
	#if !is_active: return
	#
	## Charge toward player
	#var player = get_tree().get_nodes_in_group("Player")[0]
	#var direction = (player.global_position - global_position).normalized()
	#velocity = direction * 3000
	#move_and_slide()
	##$AnimatedSprite2D.play("charge")
	#$AttackPatterns/ChargeAttack.start(randf_range(2.0, 4.0))

func _on_bullet_circle_timeout():
	if !is_active: return
	var spawn_point = $".".global_position
	# 360-degree bullet spray
	for i in 36:  
		var bullet = preload("res://scenes/enemies/EnemyBullet.tscn").instantiate()
		bullet.direction = Vector2.RIGHT.rotated(deg_to_rad(i * 10))
		bullet.position = spawn_point
		get_tree().current_scene.add_child(bullet) 
	
	$AttackPatterns/BulletCircle.start(randf_range(1.5, 3.0))


func die():
	is_active = false
	#$AnimatedSprite2D.play("death")
	#await $AnimatedSprite2D.animation_finished
	queue_free()


func _on_phase_timer_timeout() -> void:
		# Rotate through attack patterns each phase
	match current_phase:
		1:
			_on_charge_attack_timeout()
		2:
			_on_bullet_circle_timeout()
		3:
			# Alternate between attacks in phase 3
			if randf() > 0.5:
				_on_charge_attack_timeout()
			else:
				_on_bullet_circle_timeout()
	$PhaseTimer.start(randf_range(2.0, 4.0))
