extends Area2D
# docstring


# signals

# enums

# constants

# @export vars
## stats of the character, used for combat
@export var stats: CombatStats
## character name
@export var entity_name: String

# public vars
var sprite

# private vars

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	# TODO: remove this when godot devs update _init behaviour when initializing
	# after resource export
	stats.init()


# remaining builtins e.g. _process, _input


# public methods
## saves data as dictionary for JSON format
func save() -> Dictionary:
	return {
		"filename": get_scene_file_path(),
		"parent": PartyManager.get_path(),
		"entity_name": entity_name,
		"combat_stats": stats.save(),
	}


## load data from JSON savefile
func load(data) -> void:
	entity_name = data["entity_name"]
	stats.load(data["combat_stats"])
	add_to_group("persist")


func get_sprite_texture() -> Texture:
	if !sprite:
		sprite = get_node("Sprite2D")
	return sprite.texture


# private methods


# subclasses

