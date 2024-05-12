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
@onready var character_grid = get_node("CharacterGrid")
@onready var desert_scene = preload("res://scenes/desert/desert_map.tscn")


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



func _on_continue_button_pressed() -> void:
	for item in character_grid.get_children():
		if item.has_method("add_current_to_party"):
			item.call("add_current_to_party")
	get_tree().change_scene_to_packed(desert_scene)
