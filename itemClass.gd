extends Node2D
class_name ItemClass

var item_shape
var item_sprite

func rotate_item(dir:bool):
	if dir:
		rotation_degrees += rad_to_deg(90)
	else:
		rotation_degrees -= rad_to_deg(90)