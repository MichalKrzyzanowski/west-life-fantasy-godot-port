extends Area2D
# docstring


# signals
signal on_entity_clicked(node: Node2D)

# enums

# constants

# @export vars
## stats of the character, used for combat
@export var entity_properties: EntityProperties:
	set(new_entity_props):
		entity_properties = new_entity_props
		get_sprite_texture()
		sprite.texture = entity_properties.texture

# public vars
var sprite: Sprite2D
var hide_ui: bool = false
var action: Callable
var action_msg: String

# private vars

# @onready vars
@onready var ui := $UI as CanvasLayer
@onready var hp_bar := $UI/Control/HPBar as TextureProgressBar


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	# TODO: remove this when godot devs update _init behaviour when initializing
	# after resource export
	if entity_properties && entity_properties.stats:
		entity_properties.stats.on_hp_depleted.connect(_on_entity_hp_depleted)
		entity_properties.stats.on_hp_changed.connect(_on_entity_hp_changed)
		entity_properties.on_revival.connect(_on_entity_revival)
		entity_properties.stats.on_level_up.connect(_on_entity_level_up)

		# init hp bar
		if hide_ui:
			hide_hp_bar()
		else:
			assert(hp_bar, "hp bar not found in generic entity")
			hp_bar.max_value = entity_properties.stats.max_hp
			hp_bar.value = entity_properties.stats.hp
	#entity_properties.stats.init()


# remaining builtins e.g. _process, _input
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			ui.offset = global_position


# public methods
func set_action(action_name: String = "", target: Node2D = null) -> void:
	# reset defence multiplier i.e. stop blocking
	entity_properties.stats.defence_multiplier = 1
	if action_name == "":
		action_name = select_smart_action()

	if has_method(action_name):
		action = Callable(self, action_name).bind(target)
		if has_method("_%s_passive" % action.get_method()):
			call("_%s_passive" % action.get_method())


func select_smart_action() -> String:
	if (
			entity_properties.stats.hp
			<= entity_properties.stats.hp / 2
	):
		var chance = randi_range(1, 100)
		if chance >= 60:
			return "action_block"
	return "action_attack"


func select_random_action() -> String:
	var actions: Array = \
			get_method_list().filter(func(i): \
			return i["name"].begins_with("action_"))

	var action_type: int = randi() % actions.size()
	return actions[action_type]["name"]


func call_action() -> int:
	return action.call()


func clear_action() -> void:
	action = Callable()


# actions
func action_attack(target: Node2D) -> int:
	if !target || !target.visible:
		print("target is dead, looking for new target")
		return -1
	print(entity_properties.stats.attack)
	var attack_formula: int = (
			# attack
			entity_properties.stats.attack -
			(
				# damage reduction of the target
				entity_properties.stats.attack / 100.0 *
				(
					# defence_multiplier is altered if entity is blocking
					target.entity_properties.stats.defence *
					target.entity_properties.stats.defence_multiplier
				)
			)
	)

	target.entity_properties.stats.hp -= attack_formula
	action_msg = "%s deals\n%d dmg\nto %s" % \
			[entity_properties.name, attack_formula, target.entity_properties.name]
	return 0


func action_block(_target: Node2D) -> int:
	action_msg = "%s\nis blocking" % entity_properties.name
	return 0


func action_flee(_target: Node2D) -> int:
	print(_target.owner)
	var success: int = randi_range(1, 100)
	if success > 50:
		action_msg = "%s escape\nattempt successfull" % entity_properties.name
	else:
		action_msg = "%s escape\nattempt failed" % entity_properties.name
	return 0


## saves data as dictionary for JSON format
func save() -> Dictionary:
	return {
		"filename": get_scene_file_path(),
		"parent": PartyManager.get_path(),
		"entity_properties": entity_properties.save(),
	}


## load data from JSON savefile
func load(data) -> void:
	entity_properties.load(data["entity_properties"])
	add_to_group("persist")


## get texture stored in [param sprite].
## onready did not work for some reason
func get_sprite_texture() -> Texture:
	if !sprite:
		sprite = get_node("Sprite2D")
	return sprite.texture


func hide_hp_bar() -> void:
	ui.hide()
	ui.process_mode = Node.PROCESS_MODE_DISABLED


func show_hp_bar() -> void:
	ui.show()
	ui.process_mode = Node.PROCESS_MODE_INHERIT


func set_sprite_texture(texture: Texture) -> void:
	if sprite:
		sprite.texture = texture


# private methods
# action passives
func _action_attack_passive() -> void:
	print("%s enables attack passive" % entity_properties.name)


func _action_block_passive() -> void:
	entity_properties.stats.defence_multiplier = 2


## update hp bar when hp stat is changed
func _on_entity_hp_changed() -> void:
	if !hide_ui:
		hp_bar.value = entity_properties.stats.hp


func _on_entity_hp_depleted() -> void:
	hide()
	if !hide_ui:
		hide_hp_bar()
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_entity_revival() -> void:
	show()
	if !hide_ui:
		show_hp_bar()
	process_mode = Node.PROCESS_MODE_INHERIT


func _on_entity_level_up() -> void:
	if !hide_ui:
		hp_bar.max_value = entity_properties.stats.max_hp
		hp_bar.value = entity_properties.stats.hp


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select_enemy"):
		print("entity clicked")
		on_entity_clicked.emit(self)


# subclasses
