extends Node2D
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


# public methods
func save() -> Dictionary:
	return {
		"filename": get_scene_file_path(),
		"parent": get_parent().get_path(),
	}


# private methods


# subclasses

