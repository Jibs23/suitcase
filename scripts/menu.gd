extends Control

func _init():
	Logic.menu = self

func _on_start_pressed() -> void:
	Logic.audio_manager.play_sound("select", false)
	LevelManager.load_level(0)

func _on_quit_pressed() -> void:
	print("Quitting game...")
	get_tree().quit()

func hide_menu() -> void:
	visible = false

func show_menu() -> void:
	visible = true

func toggle_menu() -> void:
	visible = !visible