extends Sprite2D

var animation_player: AnimationPlayer

func _ready():
	visible = false
	animation_player = $AnimationPlayer
	animation_player.play("intro_paper")

func play_intro_sound():
	Logic.audio_manager.play_sound("paper", false)
