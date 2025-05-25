#class_name Minimap
#extends CanvasLayer
#
#
#@export var room_icon_scene: PackedScene
#@export var room_size := Vector2(20, 15)  # Minimap icon size
#@export var player_icon: Texture2D
#@export var colors := {
	#"unvisited": Color(0.2, 0.2, 0.2),
	#"visited": Color(0.4, 0.4, 0.8),
	#"current": Color(1, 1, 1),
	#"cleared": Color(0.3, 0.8, 0.3)
#}
#@export var room_pixel_size := Vector2(1224, 720)
#var rooms := {}  # Dictionary: Vector2i -> MinimapRoom
#
#func _ready():
	#$PlayerIcon.texture = player_icon
#
#func register_room(grid_pos: Vector2i, room: Node2D):
	#var icon = room_icon_scene.instantiate()
	#$Rooms.add_child(icon)
	#icon.position = Vector2(grid_pos) * room_size
	#rooms[grid_pos] = {
		#"icon": icon,
		#"room": room,
		#"state": "unvisited"
	#}
#
#func update_room(grid_pos: Vector2i, state: String):
	#if rooms.has(grid_pos):
		#rooms[grid_pos].node.modulate = colors[state]
		#rooms[grid_pos].state = state
#
#func update_player_position(room_pos: Vector2i, player_offset: Vector2):
	#if rooms.has(room_pos):
		## Convert everything to Vector2 for consistent math
		#var icon_center = Vector2(room_pos) * room_size
		#var player_offset_normalized = player_offset / room_pixel_size
		#var player_pos = icon_center + (player_offset_normalized * room_size)
		#
		#$PlayerIcon.position = player_pos
		#
		#if rooms[room_pos].state != "current":
			#update_room(room_pos, "current")
