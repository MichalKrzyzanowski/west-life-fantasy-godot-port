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
@onready var consumables_gui: HFlowContainer = %ConsumablesGui
@onready var description_label: Label = $DescriptionPanel/Label
@onready var party_status_panel: NinePatchRect = $PartyInfoPanel
@onready var party_status_box: HBoxContainer = $PartyInfoPanel/HBoxContainer

# TODO: click action for consumables
# TODO: show description in description box
# TODO: update party list box with current party stats
# TODO: follow update code for party status

	# TODO: remove onready statements here
@onready var mem1 = preload("res://entities/party-members/black_belt/black_belt.tres")
@onready var mem2 = preload("res://entities/party-members/fighter/fighter.tres")
@onready var mem3 = preload("res://entities/party-members/black_mage/black_mage.tres")
@onready var mem4 = preload("res://entities/party-members/thief/thief.tres")
func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	# TODO: remove most of this code
	consumables_gui.on_item_used.connect(_on_item_used)
	consumables_gui.set_inventory(InventoryManager.consumables_inventory)
	PartyManager.add_member(mem1)
	PartyManager.add_member(mem2)
	PartyManager.add_member(mem3)
	PartyManager.add_member(mem4)
	consumables_gui.party = PartyManager.party
	InventoryManager.consumables_inventory.add_item(1, 5)
	InventoryManager.consumables_inventory.add_item(2, 5)
	InventoryManager.consumables_inventory.add_item(3, 5)
	_update_party_hp()


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		match event.keycode:
			KEY_SPACE:
				InventoryManager.consumables_inventory.add_item(1)
			KEY_BACKSPACE:
				InventoryManager.consumables_inventory.remove_item(1)


# public methods


# private methods
func _on_back_button_pressed() -> void:
	hide()


func _on_item_used(item: Item) -> void:
	description_label.text = item.description
	party_status_panel.show()
	_update_party_hp()


func _on_party_info_panel_gui_input(event: InputEvent) -> void:
	if event.is_action_released("hide_party_panel"):
		party_status_panel.hide()


func _update_party_hp() -> void:
	for i: int in PartyManager.party.size():
		var party_member: EntityProperties = PartyManager.party[i]
		var member_hp_status: String = ("%s's\nhealth %s"
		% [party_member.entity_name(), party_member.hp_str()])
		party_status_box.get_child(i).text = member_hp_status


# subclasses
