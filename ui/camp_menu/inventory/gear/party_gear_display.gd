# @tool
# class_name name
extends Control
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
@onready var inventory_gui: HFlowContainer = $InventoryPanel/InventoryGui
@onready var party_name_label: Label = $PartyNamePanel/Label


# _init
func _init() -> void:
	pass


# _enter_tree
func _enter_tree() -> void:
	pass


# _ready
func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input


# public methods
## gui inventory getter
func get_gui_inventory() -> HFlowContainer:
	return inventory_gui


## setter for party_name_label text property
func set_party_name_text(entity: EntityProperties) -> void:
	party_name_label.text = entity.name


# private methods


# subclasses
