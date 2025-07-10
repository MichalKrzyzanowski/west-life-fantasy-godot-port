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
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	MusicPlayer.play_credits_theme()
	animation_player.play("credits_scroll")


# remaining builtins e.g. _process, _input


# public methods


# private methods


# subclasses
