extends Node
#
#var current_room_pos := Vector2i.ZERO
#var minimap: Minimap
#
#func _ready():
	#minimap = get_node("/root/Main/Minimap")
#
#func register_room(room: Node2D, grid_pos: Vector2i):
	#minimap.register_room(room, grid_pos)
#
#func update_player_position(room_pos: Vector2i, player_offset: Vector2):
	#if room_pos != current_room_pos:
		#minimap.update_room(current_room_pos, "visited")
		#current_room_pos = room_pos
	#minimap.update_player_position(room_pos, player_offset)
#
#func room_cleared(room_pos: Vector2i):
	#minimap.update_room(room_pos, "cleared")
