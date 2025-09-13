extends Control

#var game_scene: PackedScene = preload("insert scene path here!!")

func _on_start_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	print("Quitting game...")
	get_tree().quit()
