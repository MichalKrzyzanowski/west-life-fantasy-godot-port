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
