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
@onready var character_grid = $CharacterGrid as GridContainer
@onready var desert_scene = preload("res://scenes/main/main.tscn")


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input


# public methods


# private methods


# subclasses


## add all currently selected characters to the party
## move to desert map scene
func _on_continue_button_pressed() -> void:
	for item in character_grid.get_children():
		if item.has_method("add_current_to_party"):
			item.call("add_current_to_party")
	get_tree().change_scene_to_packed(desert_scene)
