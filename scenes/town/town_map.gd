# @tool
# class_name name
extends Node2D
# docstring


# signals

# enums

# constants

# @export vars
@export var spawn_position: Vector2

# public vars

# private vars
var _previous_locale: LocaleData

# @onready vars
@onready var fader := $Fader as AnimationPlayer


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	fader.play("fade")


# remaining builtins e.g. _process, _input


# public methods
func get_previous_locale() -> LocaleData:
	return _previous_locale


func set_previous_locale(locale: LocaleData) -> void:
	_previous_locale = locale


# private methods


# subclasses

