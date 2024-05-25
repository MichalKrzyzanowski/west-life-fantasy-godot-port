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

# public vars
var rng := RandomNumberGenerator.new()
var current_member: Node2D

# private vars
var _party: Array
var _enemies: Array
var _battle_order: Array
var _is_enemy_select_enabled: bool = false
var _current_party_index: int = 0

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

	# organise battle order
	_setup_battle_order()

	current_member = party_grid.get_child(_current_party_index)
	_member_ready_position()


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		match event.keycode:
			KEY_D:
				party_data[0].stats.hp -= 10
			KEY_S:
				party_data[0].stats.hp += 10
			KEY_X:
				party_data[0].stats.xp += 1000


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
			party_grid.add_child(party_member)

	party_grid.update_grid()
	_party = party_grid.get_children()
	interface.init_party_stat_boxes(data)


func _spawn_enemies() -> void:
	var enemy_count: int = rng.randi_range(1, 9)

	if !enemy_data.is_empty():
		for index in range(0, enemy_count):
			var enemy_index: int = rng.randi_range(0, enemy_data.size() - 1)
			var enemy = GenericEntity.instantiate()
			# TODO: look into _get_property_list for EntityProperties resource
			# to prevent full deep duplication
			enemy.entity_properties = enemy_data[enemy_index].duplicate(true)
			enemy_grid.add_child(enemy)
			enemy.on_entity_clicked.connect(_on_enemy_selected)

	enemy_grid.update_grid()
	_enemies = enemy_grid.get_children()


func _setup_battle_order() -> void:
	if is_party_advantage:
		print("you get to strike first.")
		_battle_order = _party + _enemies
	else:
		print("enemies get to strike first.")
		_battle_order = _enemies + _party

	#print("battle order")
	#for i in _battle_order:
	#	print(i.entity_properties.name)


func _on_enemy_select_enabled(state: bool) -> void:
	_is_enemy_select_enabled = state


func _on_block_button_pressed() -> void:
	if _is_enemy_select_enabled:
		return


func _on_flee_button_pressed() -> void:
	if _is_enemy_select_enabled:
		return


func _on_enemy_selected(node: Node2D) -> void:
	if !_is_enemy_select_enabled:
		return

	if node.entity_properties:
		print(node.entity_properties.name)

	current_member.set_action("attack", node)

	print(current_member.action)
	interface.press_attack_button()
	_next_member()


func _member_ready_position() -> void:
	current_member.position.x -= member_ready_offset


func _member_default_position() -> void:
	current_member.position.x = 0.0


func _next_member() -> void:
	_member_default_position()
	_current_party_index += 1

	if _current_party_index >= party_grid.get_children().size():
		interface.process_mode = Node.PROCESS_MODE_DISABLED
		interface.update_combat_info("commence battle!")
		_generate_enemy_actions()
		await _commence_battle()
		_reset_battle_status()
		return

	current_member = party_grid.get_child(_current_party_index)
	_member_ready_position()


func _reset_battle_status() -> void:
	interface.process_mode = Node.PROCESS_MODE_INHERIT
	interface.update_combat_info()
	_current_party_index = 0
	current_member = party_grid.get_child(_current_party_index)
	_member_ready_position()


func _generate_enemy_actions() -> void:
	for enemy in enemy_grid.get_children():
		# null action passed in forces the action to be selected at random
		enemy.set_action("", _get_random_entity(party_grid.get_children()))


func _get_random_entity(entities: Array) -> Node2D:
	return entities[rng.randi_range(0, entities.size() - 1)]


func _commence_battle() -> void:
	for entity in _battle_order:
		var success_code = entity.call_action()
		# attack action will return -1 if target is null, or becomes null
		# look for a new target
		while success_code != 0:
			if entity in party_grid:
				entity.set_action(entity.action.get_method(),
						_get_random_entity(enemy_grid.get_children()))
				success_code = entity.call_action()
			else:
				entity.set_action(entity.action.get_method(),
						_get_random_entity(party_grid.get_children()))
				success_code = entity.call_action()

		interface.update_combat_info(entity.action_msg)
		await get_tree().create_timer(turn_wait_time).timeout

# subclasses

