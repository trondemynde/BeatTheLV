extends Node2D



func _input(event):
	if event.is_action_pressed("ui_accept"):
		# Regenerate dungeon on spacebar
		$DungeonManager.generate_dungeon()
		
