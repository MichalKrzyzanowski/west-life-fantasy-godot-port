# @tool
# class_name name
extends Control
# docstring


# signals
signal on_enemy_select_enabled(state: bool)

# enums

# constants

# @export vars
#@export var party_data: Array:
#	set(new_party_data):
#		party_data = new_party_data
#		print("combat interface")
#		if !party:
#			party = $Party
#
#		for i in range(0, party_data.size()):
#			if (
#					i >= party.get_children().size()
#					|| i >= party_data.size()
#			):
#				return
#
#			print("in")
#			party.get_child(i).party_member = party_data[i].entity_properties

# public vars
var block_action_select: bool = false

# private vars

# @onready vars
@onready var party := $Party as Control
@onready var info_label := $CombatInfoPanel/BattleInfoLabel as Label
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
func init_party_stat_boxes(party_data: Array[EntityProperties]) -> void:
	if !party:
		party = $Party

	var party_boxes = party.get_children()
	for i in range(0, party_boxes.size()):
		if i >= party_data.size() || i >= party_boxes.size():
			return
		party_boxes[i].party_member = party_data[i]


func press_attack_button() -> void:
	attack_button.button_pressed = !attack_button.button_pressed
	block_action_select = attack_button.button_pressed


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
