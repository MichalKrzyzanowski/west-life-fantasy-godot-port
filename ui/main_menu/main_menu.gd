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


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	# disable button if save file not present
	continue_button.disabled = !SaveManager.is_save_present()


# remaining builtins e.g. _process, _input


# public methods


# private methods
## load the game
func _on_continue_button_pressed() -> void:
	if SaveManager.load_game(SaveManager.SAVE_FILE):
		queue_free()


## go to party select screen
func _on_new_game_button_pressed() -> void:
	get_tree().change_scene_to_packed(party_select_screen)


## open options panel
func _on_options_button_pressed() -> void:
	options_panel.show()


## quit the game
func _on_exit_button_pressed() -> void:
	get_tree().quit()


# subclasses
