# @tool
# class_name name
extends "res://ui/camp_menu/inventory/gear/gear_menu.gd"
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
@onready var gil_label := $UpgradeInfoPanel/GilLabel as Label
@onready var upgrade_button: Button = $ActionsPanel/UpgradeButton


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	item_filter = "weapon"
	super()
	update_gil()
	PartyManager.on_gil_changed.connect(update_gil)


# remaining builtins e.g. _process, _input


# public methods
func update_gil() -> void:
	gil_label.text = "Gil: %d" % PartyManager.gil


# private methods
func _on_upgrade_button_toggled(toggled_on: bool) -> void:
	_unpress_action_buttons()
	_gear_action_state = GearActionState.NONE
	upgrade_button.set_pressed_no_signal(toggled_on)
	if toggled_on:
		_gear_action_state = GearActionState.UPGRADE


# subclasses
