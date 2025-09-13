extends Node
# Manages game logic and references to other managers.

var item_manager: Node2D
var audio_manager: Node

## Returns true if an item is currently selected.
func is_item_selected() -> bool:
	print("is item selected? ", item_manager.selected_item != null)
	return item_manager.selected_item != null