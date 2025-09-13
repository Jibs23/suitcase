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
		item.connect("clicked",Callable(InputM,"_on_item_clicked"))

func _process(_delta):
	if !selected_item: return
	elif selected_item.position != get_viewport().get_mouse_position():
		selected_item.position = get_viewport().get_mouse_position()
		#print(selected_item, get_viewport().get_mouse_position())

