extends Node2D
## The item class used by all items.
class_name Item2D

@export var item_name: String
@export var item_sprite: Sprite2D
@export var item_shape: Area2D
@export var is_placed: bool = true
@export var item_manager: Node2D

signal clicked(item:Item2D,event:InputEvent)

func _ready():
	item_manager = Logic.item_manager

## Rotates the item clockwise or counter-clockwise. clockwise:bool = true is clockwise and false is counter-clockwise.
func rotate_item(clockwise:bool):
	if clockwise:
		rotation_degrees += 90
		Logic.audio_manager.play_sound(Logic.audio_manager.sfx_library["rotate_cw"])
		print("rotated item clockwise")
	else:
		rotation_degrees -= 90
		Logic.audio_manager.play_sound(Logic.audio_manager.sfx_library["rotate_ccw"])
		print("rotated item counter-clockwise")

func select_item():
	item_manager.selected_item = self
	is_placed = false
	print("selected item: ", self.name)

func unselect_item():
	is_placed = true
	print("unselected item: ", self.name)
	item_manager.selected_item = null

func toggle_selected_item():
	if self == item_manager.selected_item:
		unselect_item()
	else:
		select_item()

func _on_area_2d_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if event is not InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT: return
	if event.pressed:
		## signal goes to input_manager.gd
		emit_signal("clicked", self, event)
