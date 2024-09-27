# @tool
class_name BaseMap
extends Node2D
# docstring


# signals

# enums

# constants

# @export vars
@export var deferred_load: bool = false

# public vars

# private vars
var _previous_locale: LocaleData

# @onready vars
@onready var fader: AnimationPlayer = get_node(MainUtils.FADER_PATH)
@onready var default_position: Marker2D = get_node("PlayerPosition")


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	pass


# public methods
func get_previous_locale() -> LocaleData:
	return _previous_locale


func set_previous_locale(locale: LocaleData) -> void:
	_previous_locale = locale


func get_default_position() -> Vector2:
	return default_position.position if default_position else Vector2()


## saves data as dictionary for JSON format
func save() -> Dictionary:
	var save_dict: Dictionary = {
		"filename": get_scene_file_path(),
		"parent": get_parent().get_path(),
		"deferred_load": deferred_load,
	}
	if _previous_locale:
		save_dict["previous_locale"] = _previous_locale.save()
	return save_dict


## load data from JSON savefile
func load(data: Dictionary) -> void:
	deferred_load = data["deferred_load"]
	if data.has("previous_locale"):
		_previous_locale = LocaleData.new()
		_previous_locale.load(data["previous_locale"])


# private methods
func _on_transition_area_on_transition_start() -> void:
	pass
	# fader.play_backwards("fade")
	# await fader.animation_finished


# subclasses
