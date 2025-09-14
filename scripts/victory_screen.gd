extends Node2D


func _init():
	Logic.victory_screen = self

func _ready():
	z_index = 1000

func activate_victory_screen() -> void:
	visible = true
	Logic.audio_manager.stop_music()
	Logic.audio_manager.play_sound("victory", false)
	Logic.speedrun_timer.stop_timer()
	Logic.isWin = true

func deactivate_victory_screen() -> void:
	visible = false
	Logic.speedrun_timer.reset_timer()
	Logic.isWin = false
