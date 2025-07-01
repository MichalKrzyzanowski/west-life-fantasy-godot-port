# @tool
# class_name name
extends Control
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
# audio volume sliders
@onready var music_slider: HSlider = $BackgroundPanel/OptionsContainer/MusicVolSlider/Label/HSlider
@onready var sound_slider: HSlider = $BackgroundPanel/OptionsContainer/SFXVolSlider/Label/HSlider

# mute checkbox
@onready var mute_button: CheckBox = $BackgroundPanel/OptionsContainer/MuteAllCheckBox/Label/CheckBox

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	_init_global_audio_settings()


# remaining builtins e.g. _process, _input


# public methods


# private methods
func _on_back_button_pressed() -> void:
	audio_player.play()
	hide()
	GlobalSettings.save_ini()


func _init_global_audio_settings() -> void:
	music_slider.value = GlobalSettings.music_volume_linear
	sound_slider.value = GlobalSettings.soundfx_volume_linear

	mute_button.button_pressed = GlobalSettings.mute_all_audio


func _mute_all_sound(toggled_on: bool) -> void:
	GlobalSettings.toggle_audio(toggled_on)
	MusicPlayer.toggle_pause(toggled_on)


func _change_music_volume(value: float) -> void:
	GlobalSettings.change_music_volume_linear(value)


func _change_sound_volume(value: float) -> void:
	GlobalSettings.change_sound_volume_linear(value)


# subclasses
