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
@export var overworld_player: CharacterBody2D
@export var counter_increment: int = 1

# public vars

# private vars
var _counter: int = 0
var _counter_end: int = 100

# @onready vars
@onready var CombatScene := preload("res://scenes/combat/combat.tscn")


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input
func _process(_delta: float) -> void:
	if overworld_player && !overworld_player.velocity.is_zero_approx():
		_counter += counter_increment
		print(_counter)
		if _counter >= _counter_end:
			_counter = 0
			_trigger_random_encounter()



# public methods


# private methods
func _trigger_random_encounter() -> void:
	var chance: int = randi_range(1, 100)

	print("chance for combat")

	if chance > 0:
		get_tree().paused = true
		var combat_scene := CombatScene.instantiate()
		overworld_player.camera.enabled = false
		combat_scene.enemy_data = enemy_spawn_table
		combat_scene.party_data = PartyManager.party
		combat_scene.on_combat_end.connect(_on_combat_end)
		add_child(combat_scene)
		get_parent().hide()


func _on_combat_end() -> void:
	get_tree().paused = false
	overworld_player.camera.enabled = true
	get_parent().show()


# subclasses

