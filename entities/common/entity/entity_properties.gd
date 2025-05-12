class_name EntityProperties extends Resource
# docstring


# signals
signal on_revival()
signal on_gear_changed()

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
## index in party array.
## -1 means entity is not part of a party
var _party_index: int = -1

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
		"party_index": _party_index,
		"gear_ids": get_gear_ids(),
		"combat_stats": stats.save(),
	}


## load data from JSON savefile
func load(data: Dictionary) -> void:
	name = data["name"]
	texture = ResourceLoader.load(data["texture_path"])
	_party_index = data["party_index"]
	stats.load(data["combat_stats"])

	# load equipped gear
	if _party_index < 0:
		return

	# var party_inventory: Inventory = InventoryManager.get_party_inventory(_party_index)
	for gear_id: String in data["gear_ids"]:
		# if party_inventory.has_item(gear_id):
		if InventoryManager.main_inventory.has_item(gear_id):
			# equip_gear(party_inventory.get_item(gear_id))
			equip_gear(InventoryManager.main_inventory.get_item(gear_id))


## restored hp to full
## emits on_revival signal
func revive() -> void:
	if !stats:
		printerr("failed to revive, stats object is null")
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
		on_gear_changed.emit()
		return

	# unset equip flag for currently equipped weapon
	if weapon:
		weapon.is_equipped = false

	# equip new weapon
	weapon = new_weapon
	weapon.is_equipped = true
	on_gear_changed.emit()


# TODO: cleanup if statements
func change_armour(new_armour: Gear) -> void:
	if !new_armour:
		printerr("no armour to equip")
		return

	# if new armour has same id i.e. same armour, unequip armour
	if armour && new_armour.id == armour.id:
		armour.is_equipped = false
		armour = null
		on_gear_changed.emit()
		return

	# unset equip flag for currently equipped armour
	if armour:
		armour.is_equipped = false

	# equip new armour
	armour = new_armour
	armour.is_equipped = true
	on_gear_changed.emit()


func equip_gear(gear: Gear) -> void:
	if gear.type == "weapon":
		change_weapon(gear)
	elif gear.type == "armour":
		change_armour(gear)


## unequip gear with matching [param gear_id]
func unequip_gear(gear_id: String) -> void:
	if weapon && weapon.get_full_id() == gear_id:
		weapon = null
		on_gear_changed.emit()

	elif armour && armour.get_full_id() == gear_id:
		armour = null
		on_gear_changed.emit()


## get currently equipped gear ids
func get_gear_ids() -> Array[String]:
	var gear_ids: Array[String] = []

	if weapon:
		gear_ids.append(weapon.get_full_id())

	if armour:
		gear_ids.append(armour.get_full_id())

	return gear_ids


func set_party_index(index: int) -> void:
	_party_index = index


func get_party_index() -> int:
	return _party_index


## returns true if entity is alive
func is_alive() -> bool:
	return hp() > 0


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
