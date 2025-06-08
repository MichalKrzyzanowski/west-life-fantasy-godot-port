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
@export var counter_increment: int = 1

# public vars
var main_menu_scene_path: String = "res://ui/main_menu/main_menu.tscn"

# private vars
# counters used for triggering encounter chance
var _counter: int = 0
var _counter_end: int = 100

# @onready vars
@onready var CombatScene := preload("res://scenes/combat/combat.tscn")
@onready var hud: CanvasLayer = get_node(MainUtils.HUD_PATH)
@onready var overworld_player: CharacterBody2D = get_node(MainUtils.PLAYER_PATH)

func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	if overworld_player:
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
		overworld_enemy: Node2D = null,
		enemies: Array[EntityProperties] = [],
		enable_static_entities: bool = false) -> void:
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
	combat_scene.enable_static_entity_spawn = enable_static_entities
	combat_scene.overworld_player = overworld_player
	combat_scene.overworld_enemy = overworld_enemy

	combat_scene.party_data = PartyManager.party
	# combat_scene.max_enemy_count = 1

	combat_scene.on_combat_end.connect(_on_combat_end)
	add_child(combat_scene)
	# hide parent, which would be the map itself e.g. desert, town
	toggle_hud()
	get_parent().hide()


# TODO: ideally should be part of MainUtils class or Main scene
func toggle_hud() -> void:
	hud.visible = !hud.visible


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

	# return to main menu if battle was lost
	if !overworld_player:
		get_node(MainUtils.MAIN_SCENE_PATH).queue_free()

		# deinit singletons
		InventoryManager.deinit()
		QuestManager.deinit()
		PartyManager.deinit()

		get_tree().change_scene_to_file(main_menu_scene_path)
		return

	# enable main player camera
	overworld_player.camera.enabled = true
	# save game
	SaveManager.save_game(SaveManager.SAVE_FILE)

	toggle_hud()
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
	trigger_combat(on_advantage, body)


# subclasses
