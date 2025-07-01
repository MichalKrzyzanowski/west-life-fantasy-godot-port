# @tool
# class_name name
extends Node
# docstring


# signals

# enums

# constants
## name of config file
const CONFIG_FILE: String = "config"
## path to config file
const CONFIG_PATH: String = "user://%s.ini"

# @export vars

# public vars
## music bus volume
var music_volume_linear: float = 0.5
## soundfx bus volume
var soundfx_volume_linear: float = 0.5
## master bus mute flag
var mute_all_audio: bool = false

# private vars

# @onready vars


## load config file on init
func _init() -> void:
	load_ini()


# func _enter_tree() -> void:
# 	pass


# func _ready() -> void:
# 	pass


# remaining builtins e.g. _process, _input


# public methods
## sets master bus mute flag to [param toggled_on]
func toggle_audio(toggled_on: float) -> void:
	mute_all_audio = toggled_on
	AudioServer.set_bus_mute(0, mute_all_audio)


## sets [member music_volume_linear] to [param value].
## updates Music bus volume
func change_music_volume_linear(value: float) -> void:
	music_volume_linear = value
	AudioServer.set_bus_volume_linear(1, music_volume_linear)


## sets [member soundfx_volume_linear] to [param value].
## updates SoundFX bus volume
func change_sound_volume_linear(value: float) -> void:
	soundfx_volume_linear = value
	AudioServer.set_bus_volume_linear(2, soundfx_volume_linear)


## saves data into an ini file
func save_ini() -> void:
	var config: ConfigFile = ConfigFile.new()

	# save audio-related options
	config.set_value("audio", "music_volume", music_volume_linear)
	config.set_value("audio", "soundfx_volume", soundfx_volume_linear)
	config.set_value("audio", "mute_game", mute_all_audio)

	config.save(CONFIG_PATH % CONFIG_FILE)


## load data from ini file
func load_ini() -> void:
	var config: ConfigFile = ConfigFile.new()

	var err: int = config.load(CONFIG_PATH % CONFIG_FILE)

	if err != OK:
		printerr("failed to load %s.ini" % CONFIG_FILE)
		return

	# load audio-related options
	music_volume_linear = config.get_value("audio", "music_volume")
	soundfx_volume_linear = config.get_value("audio", "soundfx_volume")
	mute_all_audio = config.get_value("audio", "mute_game")


# private methods


# subclasses
