extends Node

@export var room_scenes: Dictionary = {
	"normal": preload("res://scenes/World/rooms/normal_room_1.tscn"),
	"start": preload("res://scenes/World/rooms/start_room_1.tscn"),
	"boss": preload("res://scenes/World/rooms/boss_room_1.tscn"),
	"shop": preload("res://scenes/World/rooms/shop_room_1.tscn")
	# Add other room types
}

var teleport_cooldown := false
@onready var generator: DungeonGenerator = $"../DungeonGenerator"

func _ready() -> void:
	generate_dungeon()


func generate_dungeon() -> void:
	# Clear existing dungeon
	for child in $"../Dungeon".get_children():
		child.queue_free()
	
	generator.generate()
	
	# Instantiate rooms with error handling
	for room_data in generator.rooms:
		var room_scene = room_scenes.get(room_data.room_type, room_scenes["normal"])
		if not room_scene:
			push_error("Missing scene for room type: ", room_data.room_type)
			continue
			
		var room_instance = room_scene.instantiate()
		room_instance.position = room_data.position
		room_instance.name = "room_%d" % room_data.id
		
		$"../Dungeon".add_child(room_instance)
		
		# Setup doors if they exist
		var doors_node = room_instance.get_node_or_null("Doors")
		if doors_node:
			_setup_doors(room_instance, room_data)
		else:
			push_warning("Room missing Doors node: ", room_instance.name)

func _setup_doors(room_instance: Node2D, room_data: RoomData) -> void:
	var door_offsets = {
		"Top": Vector2(0, -1),
		"Bottom": Vector2(0, 1),
		"Left": Vector2(-1, 0),
		"Right": Vector2(1, 0)
	}

	for dir in door_offsets:
		var door_path = "Doors/Door" + dir
		if not room_instance.has_node(door_path):
			continue
			
		var door = room_instance.get_node(door_path)
		var check_pos = room_data.position + (door_offsets[dir] * DungeonGenerator.ROOM_SIZE)
		
		if generator.dungeon_map.has(check_pos):
			# Enable door if connection exists
			door.monitoring = true
			door.body_entered.connect(_on_door_entered.bind(door_offsets[dir]))
		else:
			# Remove door if no connection
			door.queue_free()
			

func _on_door_entered(body: Node2D, direction: Vector2) -> void:
	if body.is_in_group("player") and not teleport_cooldown:
		teleport_cooldown = true
		var current_room_pos = _find_player_room()
		var new_room_pos = current_room_pos + (direction * DungeonGenerator.ROOM_SIZE)
		
		if generator.dungeon_map.has(new_room_pos):
			# Position player slightly inside new room
			var entry_point = new_room_pos + (DungeonGenerator.ROOM_SIZE / 2)
			entry_point -= direction * 30
			body.position = entry_point
			
			await get_tree().create_timer(0.5).timeout
			teleport_cooldown = false

func _find_player_room() -> Vector2:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		for room in generator.rooms: 
			var room_rect = Rect2(room.position, DungeonGenerator.ROOM_SIZE)
			if room_rect.has_point(player.position):
				return room.position
	return Vector2.ZERO
