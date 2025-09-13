extends Node2D

var selected_item: Item2D = null

func on_clicked(item):
	print("Item clicked: ", item)

func _ready():
	assign_item_signals()
	pass

func _init():
	Logic.item_manager = self

## Assigns signals from items to manager.
func assign_item_signals():
	for item in get_children():
		item.connect("clicked",Callable(self,"_on_item_clicked"))
		print(item," set manager")

## When an item is clicked by the mouse.
func _on_item_clicked(item):
	print("Clicked item: ", item)
	if item == selected_item:
		unset_selected_item()
	else:
		set_selected_item(item)

func _process(_delta):
	if !selected_item: return
	elif selected_item.position != get_viewport().get_mouse_position():
		selected_item.position = get_viewport().get_mouse_position()
		#print(selected_item, get_viewport().get_mouse_position())

func set_selected_item(item_to_select:Item2D):
	selected_item = item_to_select
	selected_item.is_placed = false
	print("selected item: ", selected_item)

func unset_selected_item():
	selected_item.is_placed = true
	selected_item = null
	print("unselected item: ", selected_item)