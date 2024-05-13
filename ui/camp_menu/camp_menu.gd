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


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit_menu"):
		SaveManager.save_game(SaveManager.SAVE_FILE)
		hide()
		get_tree().paused = false


# public methods


# private methods
func _on_items_pressed() -> void:
	pass

# subclasses
