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
@onready var party := $Party as Control

# combat info labels
@onready var info_label := $CombatInfoPanel/BattleInfoLabel as Label
@onready var rewards_label := $CombatInfoPanel/RewardsLabel as Label
@onready var gil_xp_label := $CombatInfoPanel/GilXpValueLabel as Label
@onready var gear_label := $CombatInfoPanel/GearLabel as Label

@onready var attack_button := $ActionsPanel/AttackButton as Button
@onready var block_button := $ActionsPanel/BlockButton as Button
@onready var flee_button := $ActionsPanel/FleeButton as Button


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
func init_party_stat_boxes(party_list: Array) -> void:
	if !party:
		party = $Party

	var party_boxes = party.get_children()
	for i in range(0, party_boxes.size()):
		if i >= party_list.size() || i >= party_boxes.size():
			return
		party_boxes[i].party_member = party_list[i]


func press_attack_button() -> void:
	attack_button.button_pressed = !attack_button.button_pressed
	block_action_select = attack_button.button_pressed


func update_combat_info(info: String = "") -> void:
	if info == "":
		info_label.text = "choose action"
		return
	info_label.text = info


func update_rewards_info(xp: int, gil: int, got_new_gear: bool = false) -> void:
	rewards_label.show()
	gil_xp_label.text = "%dg\n%dxp" % [gil, xp]
	gil_xp_label.show()

	gear_label.visible = got_new_gear


# private methods
func _on_attack_button_toggled(toggled_on: bool) -> void:
	block_action_select = toggled_on
	print("pressed")
	on_enemy_select_enabled.emit(block_action_select)
	if toggled_on:
		info_label.text = "choose enemy"
	else:
		info_label.text = "choose action"


# subclasses
