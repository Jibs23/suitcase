extends Sprite2D

var bg_title = preload("res://assets/startscreen1.png")
var bg_game = preload("res://assets/Table.png")
var glitter_effect: GPUParticles2D

func _init():
	Logic.background = self

func set_background_game():
	texture = bg_game
	disable_glitter()

func set_background_title():
	texture = bg_title
	enable_glitter()

func disable_glitter():
	for child in get_children():
		if child is GPUParticles2D:
			child.emitting = false

func enable_glitter():
	for child in get_children():
		if child is GPUParticles2D:
			child.emitting = true