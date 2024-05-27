# @tool
# class_name name
extends Node2D
# docstring


# signals
signal on_turn_end(party_member: EntityProperties)
# enums
# constants
# @export vars
## party list, use this instead of saved party if size > 0
@export var party_data: Array[EntityProperties]

## list of enemies to choose from when generating enemies
@export var enemy_data: Array[EntityProperties]

@export var is_party_advantage: bool
@export var member_ready_offset: float = 86.0
@export var turn_wait_time: float = 1.5
@export var max_enemy_count: int = 9

# public vars
var has_party_won: bool = false
var has_party_fled: bool = false
var rng := RandomNumberGenerator.new()
var current_member: Node2D

# private vars
var _party: Array
var _enemies: Array
var _battle_order: Array
var _is_enemy_select_enabled: bool = false
var _current_party_index: int = 0
var _is_combat_over_early: bool = false
# awards
var _xp_reward: int = 1000
var _gil_reward: int = 0

# @onready vars
@onready var GenericEntity := preload(
		"res://entities/common/generic_entity_experimental.tscn") as PackedScene
#@onready var ShadeNinja := preload("res://entities/common/generic_entity.tscn") as Area2D
# TODO: figure out how to implement static typing for Grid2D plugin type
@onready var party_grid = $PartyGrid
@onready var enemy_grid = $EnemyGrid
@onready var interface := $UI/CombatInterface as Control


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	# randomize rng seed
	rng.randomize()

	set_process_input(false)

	# connect to interface signals
	interface.on_enemy_select_enabled.connect(_on_enemy_select_enabled)
	interface.block_button.pressed.connect(_on_block_button_pressed)
	interface.flee_button.pressed.connect(_on_flee_button_pressed)

	# add party to the grid
	if party_data:
		_init_party(party_data)
	else:
		# TODO: implement using PartyManager party
		print("saved party")

	# spawn enemies and add them to the grid
	_spawn_enemies()

	_init_rewards()

	# organise battle order
	_setup_battle_order()

	current_member = party_grid.get_child(_current_party_index)
	_member_ready_position()


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event.is_action_released("exit_combat"):
		get_tree().quit()


# public methods


# private methods
func _init_party(data: Array[EntityProperties]) -> void:
	if !data.is_empty():
		for member_data in data:
			var party_member = GenericEntity.instantiate()
			# TODO: look into _get_property_list for EntityProperties resource
			# to prevent full deep duplication
			party_member.entity_properties = member_data.duplicate(true)
			party_member.hide_ui = true
			party_member.on_flee_successfull.connect(_on_entity_flee)
			party_grid.add_child(party_member)

	party_grid.update_grid()
	_party = party_grid.get_children()
	interface.init_party_stat_boxes(_party)


func _spawn_enemies() -> void:
	var enemy_count: int = rng.randi_range(1, max_enemy_count)

	if !enemy_data.is_empty():
		for index in range(0, enemy_count):
			var enemy_index: int = randi() % enemy_data.size()
			var enemy = GenericEntity.instantiate()
			# TODO: look into _get_property_list for EntityProperties resource
			# to prevent full deep duplication
			enemy.entity_properties = enemy_data[enemy_index].duplicate(true)
			enemy.on_entity_clicked.connect(_on_enemy_selected)
			enemy_grid.add_child(enemy)

	enemy_grid.update_grid()
	_enemies = enemy_grid.get_children()


func _init_rewards() -> void:
	for enemy in _enemies:
		_gil_reward += enemy.entity_properties.stats.gil_drop
		_xp_reward += enemy.entity_properties.stats.xp_drop


func _end_combat() -> void:
	# bring all party members back to default position
	for member in _party:
		_member_default_position(member)
	# disable process for interface
	interface.process_mode = Node.PROCESS_MODE_DISABLED

	# check win conditions

	# if player has won
	if has_party_won && !has_party_fled:
		interface.update_combat_info("you won the battle!")
		interface.update_rewards_info(_xp_reward, _gil_reward, true)
		for member in _party:
			member.entity_properties.stats.xp += _xp_reward
	# if player has lost
	elif !has_party_won && !has_party_fled:
		interface.update_combat_info("you lost the battle...")

	# turn on input processing
	set_process_input(true)


func _is_combat_over() -> bool:
	var check_one_dead = func(entity): return !entity.is_alive

	# if all party members wiped
	if _party.all(check_one_dead):
		return true

	# if all enemies defeated
	if _enemies.all(check_one_dead):
		has_party_won = true
		return true

	return false


func _setup_battle_order() -> void:
	if is_party_advantage:
		print("you get to strike first.")
		_battle_order = _party + _enemies
	else:
		print("enemies get to strike first.")
		_battle_order = _enemies + _party


func _on_enemy_select_enabled(state: bool) -> void:
	_is_enemy_select_enabled = state


func _on_block_button_pressed() -> void:
	if _is_enemy_select_enabled:
		return

	current_member.set_action("action_block")
	_next_member()


func _on_flee_button_pressed() -> void:
	if _is_enemy_select_enabled:
		return

	current_member.set_action("action_flee")
	_next_member()


func _on_entity_flee(entity: Node2D) -> void:
	if entity in _party:
		_is_combat_over_early = true
		has_party_fled = true
	# if it's an enemy, kill it, simulating escape
	# TODO: implement escape() method for entity
	elif entity in _enemies:
		entity.entity_properties.stats.hp = 0
		_xp_reward = min(0, _xp_reward - entity.entity_properties.stats.xp_drop)
		_gil_reward = min(0, _gil_reward - entity.entity_properties.stats.gil_drop)


func _on_enemy_selected(node: Node2D) -> void:
	if !_is_enemy_select_enabled:
		return

	if node.entity_properties:
		print(node.entity_properties.name)

	current_member.set_action("action_attack", node)

	print(current_member.action)
	interface.press_attack_button()
	_next_member()


func _member_ready_position(member: Node2D = null) -> void:
	if !member:
		current_member.position.x = 0.0 - member_ready_offset
		return
	member.position.x -= member_ready_offset


func _member_default_position(member: Node2D = null) -> void:
	if !member:
		current_member.position.x = 0.0
		return
	member.position.x = 0


func _next_member() -> void:
	_member_default_position()
	_current_party_index += 1

	if _current_party_index >= party_grid.get_children().size():
		interface.process_mode = Node.PROCESS_MODE_DISABLED
		interface.update_combat_info("commence battle!")
		_generate_enemy_actions()
		if await _commence_battle():
			_end_combat()
			return
		_reset_battle_status()
		return

	if !_party[_current_party_index].is_alive:
		_next_member()
		return

	current_member = party_grid.get_child(_current_party_index)
	_member_ready_position()


func _reset_battle_status() -> void:
	interface.process_mode = Node.PROCESS_MODE_INHERIT
	interface.update_combat_info()
	_current_party_index = -1
	_next_member()


func _generate_enemy_actions() -> void:
	for enemy in enemy_grid.get_children():
		if !enemy.is_alive:
			continue

		# null action passed in forces the action to be selected at random
		enemy.set_action("", _get_random_entity(party_grid.get_children()))


## loops through the [param entities] array, looking
## for the next available target.
## target is valid if it is not null and visible
func _get_next_entity(entities: Array) -> Node2D:
	for entity in entities:
		if entity.is_alive:
			return entity
	if entities == _enemies:
		print("enemies")
		has_party_won = true
	_is_combat_over_early = true
	return null


func _get_random_entity(entities: Array) -> Node2D:
	return entities[randi() % entities.size()]


## starts calling actions of each entity present
## in _battle_order. returns true if the battle ends early
## e.g. all enemies killed/party wiped
func _commence_battle() -> bool:
	for entity in _battle_order:
		if _is_combat_over_early:
			return true

		if !entity.is_alive:
			continue

		var success_code = entity.call_action()
		# attack action will return -1 if target is null, or becomes null
		# look for a new target
		while success_code != 0:
			if _is_combat_over_early:
				return true

			if entity in party_grid.get_children():
				entity.set_action(entity.action.get_method(),
						_get_next_entity(enemy_grid.get_children()))
				success_code = entity.call_action()
			else:
				entity.set_action(entity.action.get_method(),
						_get_next_entity(party_grid.get_children()))
				success_code = entity.call_action()

		# only move entity to ready position if entity is
		# a party member and it is attacking
		if (
				entity in party_grid.get_children()
				&& entity.action.get_method().contains("attack")
		):
			_member_ready_position(entity)

		interface.update_combat_info(entity.action_msg)
		await get_tree().create_timer(turn_wait_time).timeout

		if entity in party_grid.get_children():
			_member_default_position(entity)

	return _is_combat_over()


# subclasses
