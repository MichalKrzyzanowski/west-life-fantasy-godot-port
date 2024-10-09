class_name EntityProperties extends Resource
# docstring


# signals
signal on_revival()

# enums

# constants

# @export vars
## stats of the character, used for combat
@export var stats: CombatStats
## character name
@export var name: String
## character texture. make sure texture is 32x32px and faces
## left for best results
@export var texture: Texture

# public vars

# private vars

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input


# public methods
## saves data as dictionary for JSON format
func save() -> Dictionary:
	return {
		"name": name,
		"texture_path": texture.resource_path,
		"combat_stats": stats.save(),
	}


## load data from JSON savefile
func load(data: Dictionary) -> void:
	name = data["name"]
	texture = ResourceLoader.load(data["texture_path"])
	stats.load(data["combat_stats"])


## restored hp to full and sets has_hp_depleted = true
## emits on_revival signal
func revive() -> void:
	stats.has_hp_depleted = false
	stats.hp = stats.max_hp
	on_revival.emit()


# private methods


# subclasses
