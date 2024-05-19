# @tool
# class_name name
extends Node2D
# docstring


# signals

# enums

# constants

# @export vars

# public vars
var player_position := Vector2()

# private vars

# @onready vars
@onready var player = $OverworldPlayer as CharacterBody2D
@onready var CombatScene = preload("res://scenes/combat/combat.tscn")


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		match event.keycode:
			KEY_C:
				print("combat")


# public methods
## saves data as dictionary for JSON format
func save() -> Dictionary:
	player_position = player.position
	return {
		"filename": get_scene_file_path(),
		"parent": get_parent().get_path(),
		"player_position_x": player_position.x,
		"player_position_y": player_position.y,
	}


## load data from JSON savefile
func load(data) -> void:
	player.position = Vector2(data["player_position_x"], data["player_position_y"])


# private methods


# subclasses

