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
# counters used for triggering encounter chance
var _counter: int = 0
var _counter_end: int = 100

# @onready vars
@onready var CombatScene := preload("res://scenes/combat/combat.tscn")


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	overworld_player.on_enemy_hit.connect(on_player_enemy_hit)


# remaining builtins e.g. _process, _input
func _process(_delta: float) -> void:
	# only increment the counter if the player exists, is moving,
	# and random encounters are enabled
	if (
			enable_random_encounters
			&& overworld_player
			&& !overworld_player.velocity.is_zero_approx()
	):
		# increase counter, trigger combat chance when counter
		# reaches end
		_counter += counter_increment
		if _counter >= _counter_end:
			_counter = 0
			_trigger_random_encounter()



# public methods
## initialises combat scene. if [param enemies] is present,
## said parameter is used for creating enemy pool in combat scene.
func trigger_combat(player_advantage: bool = true,
		player: Node2D = null,
		overworld_enemy: Node2D = null,
		enemies: Array[EntityProperties] = []) -> void:
	get_tree().paused = true
	var combat_scene := CombatScene.instantiate()
	overworld_player.camera.enabled = false

	# use enemies as enemy_data if enemies not empty
	# enemy_spawn_table otherwise
	if !enemies.is_empty():
		combat_scene.enemy_data = enemies
	else:
		combat_scene.enemy_data = enemy_spawn_table

	combat_scene.is_party_advantage = player_advantage
	combat_scene.overworld_player = player
	combat_scene.overworld_enemy = overworld_enemy

	combat_scene.party_data = PartyManager.party
	combat_scene.on_combat_end.connect(_on_combat_end)
	add_child(combat_scene)
	# hide parent, which would be the map itself e.g. desert, town
	get_parent().hide()


# private methods
## 25% chance to trigger combat
func _trigger_random_encounter() -> void:
	var chance: int = randi_range(1, 100)

	print("chance for combat")

	if chance > 75:
		trigger_combat()


## helper that ends combat, unpausing the game
func _on_combat_end() -> void:
	get_tree().paused = false
	overworld_player.camera.enabled = true
	get_parent().show()


## signal callback when an entity is shot. triggers combat with
## advantage decided based on if player/enemy got shot first.
## involved enemy and player are passed into the combat scene
## in order to free the losing party after combat
func on_player_enemy_hit(body: Node2D, on_advantage: bool) -> void:
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.queue_free()

	print("player: %s, enemy: %s" % [overworld_player.name, body.name])
	print("begin combat")
	await get_tree().process_frame
	trigger_combat(on_advantage, overworld_player, body)


# subclasses

