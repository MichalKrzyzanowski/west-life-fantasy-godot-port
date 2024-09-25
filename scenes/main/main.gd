# @tool
# class_name name
extends Node2D
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
@onready var player: CharacterBody2D = $OverworldPlayer
@onready var world: CharacterBody2D = $OverworldPlayer


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input


# public methods
func get_player() -> CharacterBody2D:
	if !player:
		player = $OverworldPlayer
	return player


# private methods


# subclasses
