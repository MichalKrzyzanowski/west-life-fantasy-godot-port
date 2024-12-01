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
# equipment
@export var weapon: Gear
@export var armour: Gear

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


func change_weapon(new_weapon: Gear) -> void:
	# check if new_weapon is null
	if !new_weapon:
		printerr("no weapon to equip")
		return

	# if new weapon has same id i.e. same weapon, unequip weapon
	if weapon && new_weapon.id == weapon.id:
		weapon.is_equipped = false
		weapon = null
		return

	# unset equip flag for currently equipped weapon
	if weapon:
		weapon.is_equipped = false

	# equip new weapon
	weapon = new_weapon
	weapon.is_equipped = true


# TODO: cleanup if statements
func change_armour(new_armour: Gear) -> void:
	if !new_armour:
		printerr("no armour to equip")
		return

	# if new armour has same id i.e. same armour, unequip armour
	if armour && new_armour.id == armour.id:
		armour.is_equipped = false
		armour = null
		return

	# unset equip flag for currently equipped armour
	if armour:
		armour.is_equipped = false

	# equip new armour
	armour = new_armour
	armour.is_equipped = true


## returns [name].
func entity_name() -> String:
	if !stats:
		return "null"
	return name.to_upper()


## wrapper for [CombatStats.hp] property
func hp() -> float:
	if !stats:
		return -1
	return stats.hp


## returns hp and max hp formatted as a string
func hp_str() -> String:
	if !stats:
		return "null"
	return "%d/%d" % [stats.hp, stats.max_hp]


# private methods


# subclasses
