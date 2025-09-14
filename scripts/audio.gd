extends Node

## Library of sound effects, refference name and resource path.
var sfx_library: Dictionary = {
	"rotate_cw": preload("res://Audio/SFX/item_rotate_cw.wav"),
	"rotate_ccw": preload("res://Audio/SFX/item_rotate_ccw.wav"),
	"item_pickup": preload("res://Audio/SFX/item_pickup.wav"),
	"item_drop": preload("res://Audio/SFX/item_drop.wav"),
	"error": preload("res://Audio/SFX/error.wav"),
	"paper": preload("res://Audio/SFX/paper.wav"),
	"victory": preload("res://Audio/SFX/victory.wav"),
	"select": preload("res://Audio/SFX/select.wav")
}

var music_player: AudioStreamPlayer

## Library of music tracks, refference name and resource path.
var music_library: Dictionary = {
	1: preload("res://Audio/Music/song_1.wav"),
	2: preload("res://Audio/Music/song_2.wav"),
	3: preload("res://Audio/Music/song_3.wav")
}

func _init():
	Logic.audio_manager = self

func _ready():
	music_player = $Music
	play_music_random()

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

func play_music_random():
	var random_song = randi_range(1, music_library.size())
	play_music(random_song)

func play_music(track:int) -> void:
	var music = music_library[track]
	if music_player.stream == music:
		push_error("Music track already playing")
		return
	music_player.stop()
	music_player.stream = music
	music_player.play()
	await music_player.finished
	play_music_random()
