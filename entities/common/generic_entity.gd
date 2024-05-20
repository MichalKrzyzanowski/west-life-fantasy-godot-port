extends Area2D
# docstring


# signals

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

# private vars

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	# TODO: remove this when godot devs update _init behaviour when initializing
	# after resource export
	if entity_properties && entity_properties.stats:
		entity_properties.stats.has_died.connect(_has_entity_died)
	pass
	#entity_properties.stats.init()


# remaining builtins e.g. _process, _input


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
	$UI/Control/HPBar.hide()


func set_sprite_texture(texture: Texture) -> void:
	if sprite:
		sprite.texture = texture


# private methods
func _has_entity_died() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


# subclasses

