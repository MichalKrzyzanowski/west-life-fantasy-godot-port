# @tool
class_name LocaleData
extends Resource
# docstring


# signals

# enums

# constants

# @export vars
@export var entrance_position: Vector2
@export_file var scene_file: String


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
## saves data as dictionary for JSON format
func save() -> Dictionary:
	return {
		"entrance_position_x": entrance_position.x,
		"entrance_position_y": entrance_position.y,
		"scene_file": scene_file,
	}


## load data from JSON savefile
func load(data: Dictionary) -> void:
	entrance_position = Vector2(data["entrance_position_x"], data["entrance_position_y"])
	scene_file = data["scene_file"]


# private methods


# subclasses

