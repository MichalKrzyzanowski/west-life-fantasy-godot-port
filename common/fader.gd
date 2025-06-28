# @tool
# class_name name
extends AnimationPlayer
# docstring


# signals

# enums

# constants

# @export vars

# public vars
var keep_paused: bool = false

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


# private methods
func _on_animation_started(anim_name: StringName) -> void:
	print("%s started" % anim_name)
	get_tree().paused = true


func _on_animation_finished(anim_name: StringName) -> void:
	print("%s finished" % anim_name)
	if keep_paused:
		return
	get_tree().paused = false


# subclasses
