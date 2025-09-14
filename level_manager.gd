extends Node

var levels: Array = [
	preload("res://scenes/Board.tscn")
]

var level_container: Node
var active_level: Node2D

func load_level(level_index: int) -> void:
	level_container = get_tree().get_nodes_in_group("LevelContainer")[0]
	level_container.add_child(levels[level_index].instantiate())
	active_level = level_container.get_child(0)
	Logic.background.set_background_game()
	Logic.menu.hide_menu()
