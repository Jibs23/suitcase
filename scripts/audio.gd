extends Node

## Library of sound effects, refference name and resource path.
var sfx_library: Dictionary = {
	#"example_sfx": preload("res://Audio/sfx/example.wav") --- IGNORE ---
	"rotate_cw": preload("res://Audio/sfx/item_rotate_cw.wav"),
	"rotate_ccw": preload("res://Audio/sfx/item_rotate_ccw.wav"),
	"item_pickup": preload("res://Audio/sfx/item_pickup.wav"),
	"item_drop": preload("res://Audio/sfx/item_drop.wav"),
	"error": preload("res://Audio/sfx/error.wav"),
	"paper": preload("res://Audio/sfx/paper.wav")
}

## Library of music tracks, refference name and resource path.
var music_library: Dictionary = {
	#"example_music": preload("res://Audio/music/example.wav") --- IGNORE ---
}

func _init():
	Logic.audio_manager = self
	

## play a sound from the sfx_library. Set random_pitch to true to add a random pitch variation.
func play_sound(sound:String,random_pitch:bool) -> void:
	var sfx = sfx_library.get(sound)
	var streamPlayer: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(streamPlayer)
	streamPlayer.stream = sfx
	if random_pitch:
		streamPlayer.pitch_scale += randf_range(-0.1, 0.1)
	streamPlayer.play()
	await streamPlayer.finished
	streamPlayer.queue_free()
