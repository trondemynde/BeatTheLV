
# room_data.gd
class_name RoomData
extends RefCounted  # Better for memory management than Object

var id: int
var position: Vector2
var size: Vector2 = Vector2(1190, 648)  # Default room size
var connections: Array[int] = []  # Connected room IDs
var room_type: String = "normal"  # "start", "boss", "shop", "normal"
