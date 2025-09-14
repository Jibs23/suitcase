extends Button


func _on_pressed() -> void:
	Logic.audio_manager.play_sound("select", false)
	Logic.board.reset_game()
