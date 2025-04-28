extends Area2D
# docstring


# signals
signal on_entity_clicked(node: Node2D)
signal on_flee_successfull(entity: Node2D)

# enums

# constants

# @export vars
## stats of the character, used for combat
@export var entity_properties: EntityProperties:
	set(new_entity_props):
		entity_properties = new_entity_props
		get_sprite().texture = entity_properties.texture

# public vars
var is_alive: bool = true
var hide_ui: bool = false
var action: Callable
var action_msg: String

# shake vars
var trauma: float = 0.0
var trauma_power: float = 3.0
var max_offset: Vector2 = Vector2(2.0, 2.0)
var decay: float = 0.8

# private vars

# @onready vars
@onready var sprite: Sprite2D = $Sprite2D
@onready var ui: CanvasLayer = $UI
@onready var hp_bar: TextureProgressBar = $UI/Control/HPBar
@onready var level_up_sprite: Sprite2D = $LevelUpSprite


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	 # connect signals if entity_properties and stats exist
	if entity_properties && entity_properties.stats:
		entity_properties.stats.on_hp_depleted.connect(_on_entity_hp_depleted)
		entity_properties.stats.on_hp_changed.connect(_on_entity_hp_changed)
		entity_properties.on_revival.connect(_on_entity_revival)
		entity_properties.stats.on_level_up.connect(_on_entity_level_up)
		# entity has been created with 0 hp
		if entity_properties.stats.hp < 1:
			_on_entity_hp_depleted()

		# init hp bar if user choose not to hide the health bars
		if hide_ui:
			hide_hp_bar()
		else:
			assert(hp_bar, "hp bar not found in generic entity")
			hp_bar.max_value = entity_properties.stats.max_hp
			hp_bar.value = entity_properties.stats.hp


# remaining builtins e.g. _process, _input
func _process(delta: float) -> void:
	if sprite && !is_zero_approx(trauma):
		trauma = max(trauma - decay * delta, 0.0)
		shake()


## update ui offset to match entity position after transform change
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			ui.offset = global_position


# public methods
## add strength to the shake effect
func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)


## apply shake effect to the entity
func shake() -> void:
	var total_trauma: float = pow(trauma, trauma_power)
	sprite.offset.x = max_offset.x * total_trauma * randf_range(-1.0, 1.0)
	sprite.offset.y = max_offset.y * total_trauma * randf_range(-1.0, 1.0)


## set the action callback of the entity.
## action is set based on [param action_name] string.
## [param target] is only required by some actions, defaults to null
func set_action(action_name: String = "", target: Node2D = null) -> void:
	# reset defence multiplier i.e. stop blocking
	entity_properties.stats.defence_multiplier = 1
	if action_name == "":
		action_name = select_smart_action()

	# if method with action_name exists, bind target to a new callable
	if has_method(action_name):
		action = Callable(self, action_name).bind(target)
		# call action passive, if it exists
		if has_method("_%s_passive" % action.get_method()):
			call("_%s_passive" % action.get_method())


## ai entity selects action based on hp remaining.
## if hp <= 50%, ai entity will have 60% to defend.
## defaults to attack action
## TODO: future: add cowardice parameter that governs chance to choose flee
## action
func select_smart_action() -> String:
	if (
			entity_properties.stats.hp
			<= entity_properties.stats.hp / 2
	):
		var chance: int = randi_range(1, 100)
		if chance >= 60:
			return "action_block"
	return "action_attack"


## randomly selects action
func select_random_action() -> String:
	var actions: Array = \
			get_method_list().filter(func(i: Dictionary) -> Array: \
			return i["name"].begins_with("action_"))

	var action_type: int = randi() % actions.size()
	return actions[action_type]["name"]


func call_action() -> int:
	return action.call()


func clear_action() -> void:
	action = Callable()


# actions
## attack actions. deals damage to the [param target] based on:
## formula: A-(A/100*(TD*TDM))
## where:
## A: attack
## TD: target defence
## TDM: target defence multiplier
func action_attack(target: Node2D) -> int:
	if !target || !target.is_alive:
		print("target is dead, looking for new target")
		return -1

	var true_attack: int = entity_properties.stats.attack
	if entity_properties.weapon:
		true_attack += entity_properties.weapon.stats.attack
	print("atk: %d\natk (true): %d"
			% [entity_properties.stats.attack, true_attack])

	var attack_formula: int = (
			# attack
			true_attack -
			(
				# damage reduction of the target
				true_attack / 100.0 *
				(
					# defence_multiplier is altered if entity is blocking
					target.entity_properties.stats.defence *
					target.entity_properties.stats.defence_multiplier
				)
			)
	)

	target.entity_properties.stats.hp -= attack_formula
	# shake target entity
	target.add_trauma(1.0)
	# update message, this will be displayed in the combat info box
	action_msg = "%s deals\n%d dmg\nto %s" % \
			[entity_properties.name, attack_formula, target.entity_properties.name]
	return 0


## block action. updates action message, dmg reduction
## is applied in the passive
func action_block(_target: Node2D) -> int:
	action_msg = "%s\nis blocking" % entity_properties.name
	return 0


## flee action. entity has 50% chance to escape battle
func action_flee(_target: Node2D) -> int:
	var success: int = randi_range(1, 100)
	if success > 50:
		action_msg = "%s escape\nattempt successfull" % entity_properties.name
		on_flee_successfull.emit(self)
	else:
		action_msg = "%s escape\nattempt failed" % entity_properties.name
	return 0


## saves data as dictionary for JSON format
func save() -> Dictionary:
	return {
		"entity_properties": entity_properties.save(),
	}


## load data from JSON savefile
func load(data: Dictionary) -> void:
	entity_properties.load(data["entity_properties"])


## get texture stored in [param sprite].
## onready did not work for some reason
func get_sprite() -> Sprite2D:
	if !sprite:
		sprite = get_node("Sprite2D")
	return sprite


func update_sprite() -> void:
	if !sprite:
		sprite = $Sprite2D
	sprite.texture = entity_properties.texture
	print("updating sprite")


func hide_hp_bar() -> void:
	ui.hide()
	ui.process_mode = Node.PROCESS_MODE_DISABLED


func show_hp_bar() -> void:
	ui.show()
	ui.process_mode = Node.PROCESS_MODE_INHERIT


## flips sprite to face the party, used only for enemies
func face_party() -> void:
	if sprite:
		sprite.flip_h = true


func set_sprite_texture(texture: Texture) -> void:
	if sprite:
		sprite.texture = texture


# private methods
# action passives
## apply block multiplier
func _action_block_passive() -> void:
	entity_properties.stats.defence_multiplier = 2


## update hp bar when hp stat is changed
func _on_entity_hp_changed() -> void:
	if !hide_ui:
		hp_bar.value = entity_properties.stats.hp


## hide entity if hp < 1
func _on_entity_hp_depleted() -> void:
	is_alive = false
	hide()
	if !hide_ui:
		hide_hp_bar()
	process_mode = Node.PROCESS_MODE_DISABLED


## revive entity, currently not used
func _on_entity_revival() -> void:
	show()
	if !hide_ui:
		show_hp_bar()
	process_mode = Node.PROCESS_MODE_INHERIT


## update hp bar and show level up sprite on level up
func _on_entity_level_up() -> void:
	if !hide_ui:
		hp_bar.max_value = entity_properties.stats.max_hp
		hp_bar.value = entity_properties.stats.hp
	level_up_sprite.show()


## emit on_entity_clicked signal when clicked. used for selecting target
func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select_enemy"):
		print("entity clicked")
		on_entity_clicked.emit(self)


# subclasses
