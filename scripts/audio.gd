extends Node

## Library of sound effects, refference name and resource path.
var sfx_library: Dictionary = {
	#"example_sfx": preload("res://Audio/sfx/example.wav") --- IGNORE ---
	"rotate_cw": preload("res://Audio/sfx/item_rotate_cw.wav"),
	"rotate_ccw": preload("res://Audio/sfx/item_rotate_ccw.wav"),
}

var music_library: Dictionary = {
	#"example_music": preload("res://Audio/music/example.wav") --- IGNORE ---
}

func _init():
	Logic.audio_manager = self
	

## play a sound from the sfx_library.
func play_sound(sound:String) -> void:
	var sfx = sfx_library.get(sound)
	print("playing sound: ", sfx)
	var streamPlayer: AudioStreamPlayer = AudioStreamPlayer.new()
	add_child(streamPlayer)
	streamPlayer.stream = sfx
	streamPlayer.play()
	await streamPlayer.finished
	streamPlayer.queue_free()
