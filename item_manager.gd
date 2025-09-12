extends Node2D

func on_clicked(item):
	print("Item clicked: ", item)

func init():
	set_self_as_manager()

func set_self_as_manager():
	for item in get_children():
		if item.is_class("ItemClass"):
			item.item_manager = self
			#TODO: make signal work porpperly please :)
			item.connect("clicked", Callable(self, "_on_clicked"))

func _on_clicked(item):
	print("Item clicked: ", item)