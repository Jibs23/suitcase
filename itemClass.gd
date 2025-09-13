extends Node2D
## The item class used by all items. 
class_name Item2D

@export var item_name: String
@export var item_sprite: Sprite2D
@export var item_shape: Area2D
@export var is_placed: bool = true
@export var item_manager: Node2D

signal clicked(item)

func _ready():
	item_manager = Logic.item_manager

## Rotates the item clockwise or counter-clockwise. dir:bool = true is clockwise and false is counter-clockwise.
func rotate_item(dir:bool):
	if dir:
		rotation_degrees += rad_to_deg(90)
		print(self.name,"was rotated clockwise")
	else:
		rotation_degrees -= rad_to_deg(90)
		print(self.name,"was rotated counter-clockwise")

func _on_area_2d_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if event is not InputEventMouseButton: return
	if event.pressed:
		## signal goes to the item_manager
		emit_signal("clicked", self) 
