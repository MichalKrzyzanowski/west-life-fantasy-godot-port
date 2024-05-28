# @tool
# class_name name
extends Node
# docstring


# signals

# enums

# constants

# @export vars
@export var enable_random_encounters: bool = false
@export var enemy_spawn_table: Array[EntityProperties]

# public vars

# private vars

# @onready vars
@onready var CombatScene := preload("res://scenes/combat/combat.tscn")


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input


# public methods


# private methods
func _trigger_random_encounter() -> void:
	var chance: int = randi_range(1, 100)

	if chance > 75:
		get_tree().paused = true
		var combat_scene := CombatScene.instantiate()
		combat_scene.enemy_data = enemy_spawn_table


# subclasses

