extends Room



func _ready():
	
	lock_doors(true)
	spawn_boss()


func spawn_boss():
	var boss = preload("res://scenes/enemies/boss.tscn").instantiate()
	$BossSpawn.add_child(boss)
	boss.global_position = $BossSpawn.global_position
	boss.activate()
	boss.connect("tree_exited", _on_boss_defeated)

func _on_boss_defeated():
	lock_doors(false)
