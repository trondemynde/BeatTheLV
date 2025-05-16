class_name DungeonGenerator
extends Node

const ROOM_SIZE := Vector2(1152, 648)
const MAX_ROOMS := 10
const MAX_ITERATIONS := 5000  # Very high to guarantee placement
const MIN_SPACING := ROOM_SIZE * 1.01  # Just 1% buffer

var rooms: Array[RoomData] = []
var dungeon_map := {}

var cleared_rooms := {}

func generate() -> void:
	rooms.clear()
	dungeon_map.clear()
	
	# Create starting room
	var start_room := RoomData.new()
	start_room.id = 0
	start_room.position = Vector2.ZERO
	start_room.room_type = "start"
	_register_room(start_room)
	
	# Generate additional rooms with guaranteed placement
	for i in range(1, MAX_ROOMS):
		if not _add_room_with_retry():
			print("Stopped after placing ", rooms.size(), " rooms")
			break
	
	_ensure_connectivity()
	_place_special_rooms()
	print("Success! Generated ", rooms.size(), " connected rooms")

func _add_room_with_retry() -> bool:
	var directions = [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]
	
	# Try all existing rooms as potential connection points
	for random_room in rooms:
		directions.shuffle()
		
		for dir in directions:
			var new_pos = random_room.position + (dir * ROOM_SIZE)
			
			if _is_position_valid(new_pos):
				var new_room = RoomData.new()
				new_room.id = rooms.size()
				new_room.position = new_pos
				_register_room(new_room)
				
				# Connect rooms
				random_room.connections.append(new_room.id)
				new_room.connections.append(random_room.id)
				return true
	
	# Fallback - force place adjacent to start if needed
	if rooms.size() < 4:
		var dir = directions[randi() % directions.size()]
		var new_pos = rooms[0].position + (dir * ROOM_SIZE)
		var new_room = RoomData.new()
		new_room.id = rooms.size()
		new_room.position = new_pos
		_register_room(new_room)
		rooms[0].connections.append(new_room.id)
		new_room.connections.append(rooms[0].id)
		return true
	
	return false

func _is_position_valid(pos: Vector2) -> bool:
	# Only check for direct overlaps
	return not dungeon_map.has(pos)


func _ensure_connectivity() -> void:
	var visited := []
	var queue := [0]  # Start from room 0
	
	while queue.size() > 0:
		var current_id = queue.pop_front()
		if current_id in visited:
			continue
		visited.append(current_id)
		
		for neighbor_id in rooms[current_id].connections:
			queue.append(neighbor_id)
	
	# Add connections if needed
	if visited.size() < rooms.size():
		print("Adding extra connections...")
		for room in rooms:
			if room.id not in visited:
				# Connect to nearest visited room
				var closest = _find_closest_room(room, visited)
				room.connections.append(closest.id)
				closest.connections.append(room.id)
				visited.append(room.id)

func _find_closest_room(from_room: RoomData, valid_ids: Array) -> RoomData:
	var closest: RoomData
	var min_dist = INF
	
	for room in rooms:
		if room.id in valid_ids:
			var dist = from_room.position.distance_to(room.position)
			if dist < min_dist:
				min_dist = dist
				closest = room
	
	return closest

func _count_connections() -> int:
	var count = 0
	for room in rooms:
		count += room.connections.size()
	return count

func _register_room(room: RoomData) -> void:
	rooms.append(room)
	dungeon_map[room.position] = room

func _place_special_rooms() -> void:
	if rooms.size() < 2:
		return  # Need at least 2 rooms for special placement
	
	# Place boss room farthest from start
	var farthest_room := _find_farthest_room(rooms[0])
	farthest_room.room_type = "boss"
	
	if rooms.size() > 2:
		var shop_room = _find_farthest_room(rooms[0], [farthest_room])
		shop_room.room_type = "shop"

func _find_farthest_room(from_room: RoomData, exclude: Array = []) -> RoomData:
	var farthest: RoomData = from_room
	var max_distance := 0.0

	for room in rooms:
		if room in exclude:
			continue
		var dist := from_room.position.distance_to(room.position)
		if dist > max_distance:
			max_distance = dist
			farthest = room

	return farthest
	

func register_room(room: Room):
	if cleared_rooms.has(room.get_path()):
		room.is_cleared = true
		room.lock_doors(false)
	else:
		room.connect("room_cleared", _on_room_cleared.bind(room))

func _on_room_cleared(room: Room):
	cleared_rooms[room.get_path()] = true
