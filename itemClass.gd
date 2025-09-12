extends Node2D
class_name ItemClass

@export var item_shape: Area2D
@export var item_sprite: Sprite2D
@export var is_selected: bool = false
@export var is_placed: bool = false
@export var item_manager: Node2D

signal clicked(item)

func rotate_item(dir:bool):
	if dir:
		rotation_degrees += rad_to_deg(90)
	else:
		rotation_degrees -= rad_to_deg(90)

func _on_area_2d_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			emit_signal("clicked", self)
			# signal goes to the item_manager
