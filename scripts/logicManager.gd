extends Node
# Manages game logic and references to other managers.

var item_manager: Node2D
var audio_manager: Node
var board: Node2D
var menu: Control
var speedrun_timer: Label
var background: Sprite2D

## Returns true if an item is currently selected.
func is_item_selected() -> bool:
	return item_manager.selected_item != null

func _ready():
	print("item_manager: ", item_manager)
	print("audio_manager: ", audio_manager)
	print("board: ", board)
	print("menu: ", menu)
	print("speedrun_timer: ", speedrun_timer)
	print("background: ", background)