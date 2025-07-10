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
@onready var options_panel = get_node("OptionsMenu")
@onready var party_select_screen = preload("res://ui/character_select/party_select.tscn")
@onready var continue_button: Button = get_node("MenuButtons/ContinueButton")
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

# cache the credits scene on first launch of the game since it has a lot of large images
@onready var credits_scene: PackedScene = preload("res://ui/credits/credits.tscn")


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	# disable button if save file not present
	continue_button.disabled = !SaveManager.is_save_present()
	MusicPlayer.play_overworld_theme()


# remaining builtins e.g. _process, _input


# public methods


# private methods
## load the game
func _on_continue_button_pressed() -> void:
	audio_player.play()
	if SaveManager.load_game(SaveManager.SAVE_FILE):
		var fader: AnimationPlayer = get_node(MainUtils.FADER_PATH)
		# TODO: prevent player from moving when loading
		fader.play("fade")
		queue_free()


## go to party select screen
func _on_new_game_button_pressed() -> void:
	audio_player.play()
	await audio_player.finished
	get_tree().change_scene_to_packed(party_select_screen)


## open options panel
func _on_options_button_pressed() -> void:
	audio_player.play()
	options_panel.show()


## quit the game
func _on_exit_button_pressed() -> void:
	audio_player.play()
	await audio_player.finished
	get_tree().quit()


# subclasses
