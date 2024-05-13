# @tool
# class_name name
extends Control
# docstring


# signals

# enums

# constants

# @export vars
## index to use when fetching party member
@export var party_index: int = 0

# public vars

# private vars
var _entity: Node

# @onready vars
@onready var name_label := get_node("Panel/Labels/Name") as Label
@onready var level_label := get_node("Panel/Labels/Level") as Label
@onready var hp_label := get_node("Panel/Labels/HP") as Label
@onready var defence_label := get_node("Panel/Labels/Defence") as Label
@onready var attack_label := get_node("Panel/Labels/Damage") as Label
@onready var weapon_attack_label := get_node("Panel/Labels/WeaponDamage") as Label
@onready var image := get_node("Panel/Image/TextureRect") as TextureRect


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	update_status()


# remaining builtins e.g. _process, _input


# public methods
func update_status() -> void:
	if !_entity:
		_entity = PartyManager.get_member(party_index)
		# check again to see if PartyManager returned valid node
		if !_entity:
			print("could not find party member at index %d"
			% party_index)
			return

	image.texture = _entity.get_sprite_texture()
	var data: Dictionary = _entity.save()

	# general labels
	name_label.text = data["entity_name"]
	level_label.text = "L %d" % data["combat_stats"]["level"]

	# attribute labels
	hp_label.text = "HP\n  %d/ %d" \
	% [data["combat_stats"]["hp"], data["combat_stats"]["max_hp"]]

	defence_label.text = "Defence %d" \
	% data["combat_stats"]["defence"]

	attack_label.text = "Damage %d" \
	% data["combat_stats"]["attack"]

	weapon_attack_label.text = "W.DMG 0"


# private methods


# subclasses

