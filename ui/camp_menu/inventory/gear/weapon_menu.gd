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
@onready var gold_label := $UpgradeInfoPanel/GoldLabel as Label
@onready var upgrade_button: Button = $ActionsPanel/UpgradeButton


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


## connects [signal PartyManager.on_gold_changed] signal
## and sets item_filter to "weapon"
func _ready() -> void:
	item_filter = "weapon"
	super()
	update_gold()
	PartyManager.on_gold_changed.connect(update_gold)


# remaining builtins e.g. _process, _input


# public methods
## updates gold label with current party gold
func update_gold() -> void:
	# TODO: change to gold in final release, gil is kept to stay in line with original
	gold_label.text = "Gil: %d" % PartyManager.gold


# private methods
## sets gear action to upgrade when drop button is toggled on
func _on_upgrade_button_toggled(toggled_on: bool) -> void:
	audio_player.play()
	_unpress_action_buttons()
	_gear_action_state = GearActionState.NONE
	upgrade_button.set_pressed_no_signal(toggled_on)
	if toggled_on:
		_gear_action_state = GearActionState.UPGRADE


# subclasses
