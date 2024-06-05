# @tool
# class_name name
extends Control
# docstring


# signals

# enums

# constants

# @export vars
@export var party_member: Node2D:
	set(new_member):
		party_member = new_member
		_init_ui()

# public vars

# private vars

# @onready vars
@onready var name_label := $Panel/NameLabel as Label
@onready var hp_value_label := $Panel/HPValueLabel as Label
@onready var xp_bar := $XpBar as TextureProgressBar


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	if party_member && party_member.stats:
		_init_ui()


# remaining builtins e.g. _process, _input


# public methods


# private methods
## initialise ui based on current entity
func _init_ui() -> void:
	# connect stats related signals
	party_member.entity_properties.stats.on_hp_changed.connect(_on_party_member_hp_changed)
	party_member.entity_properties.stats.on_xp_changed.connect(_on_party_member_xp_changed)
	party_member.entity_properties.stats.on_level_up.connect(_on_party_member_level_up)

	# init hp, name, and xp ui elements
	name_label.text = party_member.entity_properties.name
	hp_value_label.text = str(party_member.entity_properties.stats.hp)
	xp_bar.max_value = party_member.entity_properties.stats.required_xp
	xp_bar.value = party_member.entity_properties.stats.xp


func _on_party_member_hp_changed() -> void:
	hp_value_label.text = str(party_member.entity_properties.stats.hp)


func _on_party_member_xp_changed() -> void:
	xp_bar.value = party_member.entity_properties.stats.xp


func _on_party_member_level_up() -> void:
	xp_bar.max_value = party_member.entity_properties.stats.required_xp


# subclasses

