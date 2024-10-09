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
var _entity: EntityProperties

# @onready vars
@onready var name_label := $Panel/Labels/Name as Label
@onready var level_label := $Panel/Labels/Level as Label
@onready var hp_label := $Panel/Labels/HP as Label
@onready var defence_label := $Panel/Labels/Defence as Label
@onready var attack_label := $Panel/Labels/Damage as Label
@onready var weapon_attack_label := $Panel/Labels/WeaponDamage as Label
@onready var image := $Panel/Image/TextureRect as TextureRect
@onready var fallback_texture := preload("res://entities/party-members/fallback/fallback.png") as Texture


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	# connect stats signals if entity exists
	if _entity_exists():
		_entity.stats.on_hp_changed.connect(_on_entity_hp_changed)
		_entity.stats.on_level_up.connect(_on_entity_level_up)
	update_status()


# remaining builtins e.g. _process, _input


# public methods
func update_status() -> void:
	if !_entity_exists():
		return

	image.texture = _entity.texture

	# apply fallback texture if texture is not saved/does not exist
	if !image.texture:
		image.texture = fallback_texture

	# general labels
	name_label.text = _entity.name
	level_label.text = "L %d" % _entity.stats.level

	# attribute labels
	hp_label.text = "HP\n  %d/ %d" \
	% [_entity.stats.hp, _entity.stats.max_hp]

	defence_label.text = "Defence %d" \
	% _entity.stats.defence

	attack_label.text = "Damage %d" \
	% _entity.stats.attack

	# TODO: add weapons
	weapon_attack_label.text = "W.DMG 0"


# private methods
## checks if entity with party_index exists
func _entity_exists() -> bool:
	if !_entity:
		_entity = PartyManager.get_member(party_index)
		# check again to see if PartyManager returned valid object
		if !_entity:
			print("could not find party member at index %d"
			% party_index)
			return false
	return true

# TODO: add on_attack_changed and on_defence_changed signals
# maybe?

## updates hp/max_hp labels when entity hp changes
func _on_entity_hp_changed() -> void:
	hp_label.text = "HP\n  %d/ %d" \
	% [_entity.stats.hp, _entity.stats.max_hp]


## updates level, defence, and attack labels
## if entity levels up
func _on_entity_level_up() -> void:
	level_label.text = "L %d" % _entity.stats.level

	defence_label.text = "Defence %d" \
	% _entity.stats.defence

	attack_label.text = "Damage %d" \
	% _entity.stats.attack


# subclasses
