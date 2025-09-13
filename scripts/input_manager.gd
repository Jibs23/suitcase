extends Node

func _unhandled_input(event):

	if event.is_action_pressed("item_select"):
		pass
		#TODO: implement keyboard control system for selecting items

	if Logic.is_item_selected():
		if event.is_action_pressed("item_rotate_cw"):
			Logic.item_manager.selected_item.rotate_item(true)
		if event.is_action_pressed("item_rotate_ccw"):
			Logic.item_manager.selected_item.rotate_item(false)

## Called when an item is clicked with the mouse.
func _on_item_clicked(item, event):
	if !event.is_action_pressed("item_select") and event is not InputEventMouseButton: return
	item.toggle_selected_item()
