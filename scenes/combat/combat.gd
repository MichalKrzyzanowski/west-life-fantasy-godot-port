# @tool
# class_name name
extends Node2D
# docstring


# signals
signal on_turn_end(party_member: EntityProperties)
signal on_combat_end()

# enums

# constants

# @export vars
## party list, use this instead of saved party if size > 0
@export var party_data: Array[EntityProperties]

## list of enemies to choose from when generating enemies
@export var enemy_data: Array[EntityProperties]

## governs if the party starts first
@export var is_party_advantage: bool
## position to move a party member when it is
## his turn
@export var member_ready_offset: float = 86.0
## time delay between each turn
@export var turn_wait_time: float = 1.5
## max enemies that can spawn
@export var max_enemy_count: int = 9
# TODO: rename to cleaner name
## governs entity spawning logic. if enabled, entities
## are spawned in order of [member enemy_data].
## null entities are used to dictate empty slots in enemy
## positioning
@export var enable_static_entity_spawn: bool = false

# public vars
# combat status trackers
var has_party_won: bool = false
var has_party_fled: bool = false
# ready member reference
var current_member: Node2D

# overworld references to entities involved in combat.
# only used for non-random encounters
var overworld_player: Node2D
var overworld_enemy: Node2D

# private vars
## reference to party_grid.get_children
var _party: Array
## reference to enemy_grid.get_children
var _enemies: Array
## order in which turns are played out
var _battle_order: Array
var _is_enemy_select_enabled: bool = false
# index of the currently ready member
var _current_party_index: int = 0
## checks if combat is over in the middle of a turn
## e.g. when escaping, when looking for a valid target
var _is_combat_over_early: bool = false
# awards
var _xp_reward: int = 0
var _gil_reward: int = 0

# @onready vars
@onready var GenericEntity := preload(
		"res://entities/common/entity/generic_entity.tscn")
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
	# set input processing off until combat end
	set_process_input(false)

	# connect to interface signals
	interface.on_enemy_select_enabled.connect(_on_enemy_select_enabled)
	interface.block_button.pressed.connect(_on_block_button_pressed)
	interface.flee_button.pressed.connect(_on_flee_button_pressed)

	# make sure there is at least one party member and enemy available
	assert(!party_data.is_empty(), "no party members present")
	assert(!enemy_data.is_empty(), "no enemies available to spawn")

	# add party to the grid
	_init_party(party_data)

	# spawn enemies and add them to the grid
	if enable_static_entity_spawn:
		pass
		_spawn_enemies()
	else:
		_spawn_randow_enemies()

	# generate awards
	_init_rewards()

	# organise battle order
	_setup_battle_order()

	# initialise current party member and move into ready position
	for index: int in _party.size():
		if _party[index].is_alive:
			_current_party_index = index
			current_member = _party[index]
			break

	_move_entity_ready_position()


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	# free combat scene when combat end is met
	if event.is_action_released("exit_combat"):
		on_combat_end.emit()
		queue_free()


# public methods


# private methods
## initialise party members from [param data].
## creates an instance of generic_entity based on
## [param data] properties and attach them to designated Grid2D
func _init_party(data: Array[EntityProperties]) -> void:
	if !data.is_empty():
		for member_data in data:
			var party_member = GenericEntity.instantiate()
			# TODO: look into _get_property_list for EntityProperties resource
			# to prevent full deep duplication
			party_member.entity_properties = member_data
			# party should not display hp bars
			party_member.hide_ui = true
			party_member.on_flee_successfull.connect(_on_entity_flee)
			party_grid.add_child(party_member)

	# update the grid manually to increase performance
	party_grid.update_grid()
	_party = party_grid.get_children()
	# update combat ui with initialised party
	interface.init_party_stat_boxes(_party)


## generates enemies in order from [member enemy_data].
## null enemies are treated as empty nodes in the grid
func _spawn_enemies() -> void:
	for data: EntityProperties in enemy_data:
		if !data:
			print("null enemy")
			var enemy: Area2D = GenericEntity.instantiate()
			enemy.entity_properties = EntityProperties.new()
			enemy.entity_properties.stats = CombatStats.new()
			enemy_grid.add_child(enemy)
			continue

		var enemy: Area2D = GenericEntity.instantiate()
		enemy.entity_properties = data.duplicate(true)
		enemy.on_entity_clicked.connect(_on_enemy_selected)
		enemy.face_party()
		enemy_grid.add_child(enemy)

	enemy_grid.update_grid()
	_enemies = enemy_grid.get_children()


## generate randomly selected enemies from enemy_data.
## each enemy is an instance of generic_entity
func _spawn_randow_enemies() -> void:
	var enemy_count: int = randi_range(1, max_enemy_count)

	if !enemy_data.is_empty():
		for index in range(0, enemy_count):
			var enemy_index: int = randi() % enemy_data.size()
			var enemy = GenericEntity.instantiate()
			# TODO: look into _get_property_list for EntityProperties resource
			# to prevent full deep duplication
			enemy.entity_properties = enemy_data[enemy_index].duplicate(true)
			enemy.on_entity_clicked.connect(_on_enemy_selected)
			enemy.face_party()
			enemy_grid.add_child(enemy)

	enemy_grid.update_grid()
	_enemies = enemy_grid.get_children()


## setup the turn order that will be followed by _commence_battle func.
## if party is on advantage, party is included at the start of the list,
## vice versa for no party advantage
func _setup_battle_order() -> void:
	if is_party_advantage:
		print("you get to strike first.")
		_battle_order = _party + _enemies
	else:
		print("enemies get to strike first.")
		_battle_order = _enemies + _party


## calculate total gil and xp to be rewarded from
## the spawned enemies
func _init_rewards() -> void:
	for enemy in _enemies:
		_gil_reward += enemy.entity_properties.stats.gil_drop
		_xp_reward += enemy.entity_properties.stats.xp_drop


## called when combat has been finished either by standard means
## (check if any party members or enemies are still alive)
## or when combat was ended early (entity successfully fled, cannot find
## a new target when attacking and current target = null)
func _end_combat() -> void:
	# bring all party members back to default position
	for member in _party:
		_move_entity_default_position(member)
	# disable process for interface
	# we don't want the player from using the interface when combat is over
	interface.process_mode = Node.PROCESS_MODE_DISABLED

	# check win conditions

	# if player has won
	if has_party_won && !has_party_fled:
		# update combat info box and rewards box
		interface.update_combat_info("you won the battle!")
		interface.update_rewards_info(_xp_reward, _gil_reward)
		# add gil reward
		PartyManager.gil += _gil_reward
		# add xp to party
		for member in _party:
			member.entity_properties.stats.xp += _xp_reward
			# remove shot overworld enemy if not null
			if overworld_enemy:
				overworld_enemy.queue_free()
		# check if any enemy slain was required for quests
		for enemy: Area2D in _enemies:
			QuestManager.check_slain_entity(enemy.entity_properties)
	# if player has lost
	elif !has_party_won && !has_party_fled:
		# update combat info box
		interface.update_combat_info("you lost the battle...")
		# remove overworld player if not null
		if overworld_player:
			overworld_player.queue_free()

	# turn on input processing
	# this allows the player to exit the combat scene
	# only after combat has concluded
	set_process_input(true)


## check if either the party or the enemies are wiped.
## returns true if either of the groups has wiped
## if enemies are wiped, has_party_won property = true
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


## signal callback that is triggered when the attack button is clicked.
## this prevents the player from being able to choose other actions when attacking
func _on_enemy_select_enabled(state: bool) -> void:
	_is_enemy_select_enabled = state


## signal callback triggered when block button is clicked.
## sets the current party member action to block
func _on_block_button_pressed() -> void:
	if _is_enemy_select_enabled:
		return

	current_member.set_action("action_block")
	_next_member()


## signal callback triggered when flee button is clicked.
## sets the current party member action to flee
func _on_flee_button_pressed() -> void:
	if _is_enemy_select_enabled:
		return

	current_member.set_action("action_flee")
	_next_member()


## signal callback triggered when entity has successfully fled.
## ends combat early and sets has_party_fled to true, this governs whether
## the player should recieve any awards after combat
func _on_entity_flee(entity: Node2D) -> void:
	# only check if fled if at least 1 party member is present
	if entity in _party:
		_is_combat_over_early = true
		has_party_fled = true
	# if it's an enemy, kill it, simulating escape
	# TODO: implement escape() method for entity
	elif entity in _enemies:
		entity.entity_properties.stats.hp = 0
		_xp_reward = min(0, _xp_reward - entity.entity_properties.stats.xp_drop)
		_gil_reward = min(0, _gil_reward - entity.entity_properties.stats.gil_drop)


## signal callback triggered when an [param entity] is selected as a target for
## another entity. sets action of other entity to attack with [param entity] as target
func _on_enemy_selected(entity: Node2D) -> void:
	if !_is_enemy_select_enabled:
		return

	if entity.entity_properties:
		print(entity.entity_properties.name)

	current_member.set_action("action_attack", entity)

	# move to the next party member and update interface
	print(current_member.action)
	interface.press_attack_button()
	_next_member()


## sets the [param entity] position to ready i.e. slightly moved to the left.
## if [param entity] not preset, use current_member. this is default behaviour
## TODO: change name to be more readable
func _move_entity_ready_position(entity: Node2D = null) -> void:
	if !entity:
		current_member.position.x = 0.0 - member_ready_offset
		return
	entity.position.x -= member_ready_offset


## sets the [param entity] position to default i.e. 0, 0
## if [param entity] not preset, use current_member. this is default behaviour
## TODO: change name to be more readable
func _move_entity_default_position(entity: Node2D = null) -> void:
	if !entity:
		current_member.position.x = 0.0
		return
	entity.position.x = 0


## move to the next party member when selecting party action.
## if all actions selected, commence battle.
## this is a recursive method
func _next_member() -> void:
	# move to the next party member and update previous party member
	# position
	_move_entity_default_position()
	_current_party_index += 1

	# if _party has been exhausted, commence combat.
	## interface process is disabled
	if _current_party_index >= _party.size():
		interface.process_mode = Node.PROCESS_MODE_DISABLED
		interface.update_combat_info("commence battle!")
		_generate_enemy_actions()
		# wait for all turns to be processed.
		# if _commence_battle returns true, the battle has ended
		if await _commence_battle():
			_end_combat()
			return
		# reset current party positions and index
		_reset_battle_status()
		return

	# only call this function on a living party member
	if !_party[_current_party_index].is_alive:
		_next_member()
		return

	# update position of current party member
	current_member = _party[_current_party_index]
	_move_entity_ready_position()


## turns on interface process, updates combat info, and returns to first party
## member, thus looping the battle order until one of the end conditions are met
func _reset_battle_status() -> void:
	interface.process_mode = Node.PROCESS_MODE_INHERIT
	interface.update_combat_info()
	_current_party_index = -1
	_next_member()


## randomly generate enemy actions. only for alive enemies
func _generate_enemy_actions() -> void:
	for enemy in _enemies:
		if !enemy.is_alive:
			continue

		# null action passed in forces the action to be selected at random
		enemy.set_action("", _get_random_entity(_party))


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


## get random entity from [param entities]
func _get_random_entity(entities: Array) -> Node2D:
	return entities[randi() % entities.size()]


## starts calling actions of each entity present
## in _battle_order. returns true if the battle ends early
## e.g. all enemies killed/party wiped
func _commence_battle() -> bool:
	# check if battle ended early
	for entity in _battle_order:
		if _is_combat_over_early:
			return true

		# check party and enemy status before calling next action
		if _is_combat_over():
			return true

		# skip turn if entity is dead
		if !entity.is_alive:
			continue

		# initial call to the entity action.
		# if success_code is 0, the below loop does not trigger and
		# the turn is concluded
		var success_code = entity.call_action()

		# attack action will return -1 if target is null, or becomes null
		# look for a new target
		while success_code != 0:
			if _is_combat_over_early:
				return true

			# make sure the entity has a valid target else, exit combat early
			if entity in _party:
				entity.set_action(entity.action.get_method(),
						_get_next_entity(_enemies))
				success_code = entity.call_action()
			else:
				entity.set_action(entity.action.get_method(),
						_get_next_entity(_party))
				success_code = entity.call_action()

		# only move entity to ready position if entity is
		# a party member and it is attacking
		if (
				entity in _party
				&& entity.action.get_method().contains("attack")
		):
			_move_entity_ready_position(entity)

		# update interface info box with entity action message, which is set after
		# the action is played. a timer is created and awaited for a few seconds
		interface.update_combat_info(entity.action_msg)
		await get_tree().create_timer(turn_wait_time).timeout

		# move to default position if a party member
		if entity in _party:
			_move_entity_default_position(entity)

	# check if combat end conditions have been met
	return _is_combat_over()


# subclasses
