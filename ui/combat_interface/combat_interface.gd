# @tool
# class_name name
extends Control
# docstring


# signals
signal on_enemy_select_enabled(state: bool)

# enums

# constants

# @export vars

# public vars
var block_action_select: bool = false

# private vars

# @onready vars
@onready var party: Control = $Party

# combat info labels
@onready var info_label: Label = $CombatInfoPanel/BattleInfoLabel
@onready var rewards_label: Label = $CombatInfoPanel/RewardsLabel
@onready var gold_xp_label: Label = $CombatInfoPanel/GoldXpValueLabel
@onready var gear_label: Label = $CombatInfoPanel/GearLabel

@onready var attack_button: Button = $ActionsPanel/AttackButton
@onready var block_button: Button = $ActionsPanel/BlockButton
@onready var flee_button: Button = $ActionsPanel/FleeButton


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	info_label.text = "choose action"


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_attack_mode"):
		press_attack_button()


# public methods
## pass information to the character boxes so they can be initialized
func init_party_stat_boxes(party_list: Array) -> void:
	if !party:
		party = $Party

	var party_boxes = party.get_children()
	for i in range(0, party_boxes.size()):
		if i >= party_list.size() || i >= party_boxes.size():
			return
		party_boxes[i].party_member = party_list[i]


## simulate attack button pressed, used for shortcuts
func press_attack_button() -> void:
	attack_button.button_pressed = !attack_button.button_pressed
	block_action_select = attack_button.button_pressed


## updates main combat info part of the box.
## if [param info] is empty, default to "choose action"
func update_combat_info(info: String = "") -> void:
	if info == "":
		info_label.text = "choose action"
		return
	info_label.text = info


## updates rewards info part of the combat info box
func update_rewards_info(xp: int, gold: int, got_new_gear: bool = false) -> void:
	rewards_label.show()
	gold_xp_label.text = "%dg\n%dxp" % [gold, xp]
	gold_xp_label.show()

	gear_label.visible = got_new_gear


# private methods
## signal callback triggered when attack button is pressed.
## toggles between "choose action" and "choose enemy" modes
func _on_attack_button_toggled(toggled_on: bool) -> void:
	block_action_select = toggled_on
	print("pressed")
	on_enemy_select_enabled.emit(block_action_select)
	if toggled_on:
		info_label.text = "choose enemy"
	else:
		info_label.text = "choose action"


# subclasses
