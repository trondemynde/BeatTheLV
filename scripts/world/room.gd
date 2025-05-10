extends Node2D

signal door_entered(direction: String)  # "top", "right", "bottom", "left"

@onready var door_areas := {
	"top": $DoorTop/DoorTopArea,
	"right": $DoorRight/DoorRightArea,
	"bottom": $DoorBottom/DoorBottomArea,
	"left": $DoorLeft/DoorLeftArea,
}

func _ready():
	# Connect only existing doors
	for direction in door_areas:
		var door = door_areas[direction]
		if door:
			door.connect("body_entered", _on_door_entered.bind(direction))
		else:
			push_warning("Door %s is missing in room %s" % [direction, name])

func _on_door_entered(body: Node, direction: String):
	if body.is_in_group("player"):
		emit_signal("door_entered", direction)
		
