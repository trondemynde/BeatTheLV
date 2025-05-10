extends Node2D

@export var room_size := Vector2(1190, 648)

func _ready() -> void:
	add_to_group("rooms")
