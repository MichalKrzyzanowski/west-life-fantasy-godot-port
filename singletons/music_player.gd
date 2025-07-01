# @tool
# class_name name
extends AudioStreamPlayer
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
# themes
@onready var overworld_theme: AudioStreamMP3 = preload("res://audio/music/overworld_theme.mp3")
@onready var battle_theme: AudioStreamMP3 = preload("res://audio/music/battle_theme.mp3")
@onready var credits_theme: AudioStreamMP3 = preload("res://audio/music/credits_theme.mp3")


## set bus to use & set process_mode to always
func _init() -> void:
	bus = "Music"
	process_mode = Node.PROCESS_MODE_ALWAYS


# func _enter_tree() -> void:
# 	pass


# func _ready() -> void:
# 	pass


# remaining builtins e.g. _process, _input


# public methods
## helper for playing overworld theme
func play_overworld_theme() -> void:
	_play_stream(overworld_theme)


## helper for playing battle theme
func play_battle_theme() -> void:
	_play_stream(battle_theme)


## helper for playing credits theme
func play_credits_theme() -> void:
	_play_stream(credits_theme)


## pauses/unpauses stream based on [param toggled_on]
func toggle_pause(toggled_on: bool) -> void:
	stream_paused = toggled_on


# private methods
## helper method for changing & playing new themes
func _play_stream(audio_stream: AudioStream) -> void:
	stop()
	stream = audio_stream
	play()
	# mute pause stream if master bus is muted
	toggle_pause(AudioServer.is_bus_mute(0))


# subclasses
