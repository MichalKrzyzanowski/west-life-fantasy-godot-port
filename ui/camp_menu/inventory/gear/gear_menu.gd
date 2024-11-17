# @tool
# class_name name
extends Control
# docstring


# signals

# enums
enum GearActionState {
	EQUIP = 0,
	UPGRADE,
	DROP,
	NONE,
}

# constants

# @export vars

# public vars

# private vars
var _gear_action_state: GearActionState = GearActionState.NONE

# @onready vars
@onready var gui_inventories: VBoxContainer = $Inventories
@onready var action_buttons: NinePatchRect = $ActionsPanel
@onready var equip_button: Button = $ActionsPanel/EquipButton
@onready var drop_button: Button = $ActionsPanel/DropButton

	# TODO: remove onready statements here
@onready var mem1 = preload("res://entities/party-members/black_belt/black_belt.tres")
@onready var mem2 = preload("res://entities/party-members/fighter/fighter.tres")
@onready var mem3 = preload("res://entities/party-members/black_mage/black_mage.tres")
@onready var mem4 = preload("res://entities/party-members/thief/thief.tres")
var _invs: Array[Inventory] = []

func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	# TODO: most of this is test code, remove after testing finished
	PartyManager.add_member(mem1)
	InventoryManager.create_party_inventory()
	PartyManager.add_member(mem2)
	InventoryManager.create_party_inventory()
	PartyManager.add_member(mem3)
	InventoryManager.create_party_inventory()
	PartyManager.add_member(mem4)
	InventoryManager.create_party_inventory()

	# initialize inventories for each gui inventory in the scene
	for i: int in gui_inventories.get_child_count():
		# TODO: remove temp code
		InventoryManager.get_party_inventory(i).add_item(31)
		InventoryManager.get_party_inventory(i).add_item(32)
		var gui_inventory: HFlowContainer = gui_inventories.get_child(i).get_gui_inventory()
		var inv_party_ref: Array[EntityProperties]= [PartyManager.get_member(i)]
		gui_inventory.set_inventory(InventoryManager.get_party_inventory(i), inv_party_ref)
		gui_inventory.on_item_gui_clicked.connect(_on_item_clicked)

# remaining builtins e.g. _process, _input


# public methods


# private methods
## returns all gear action toggle buttons to unpressed state
func _unpress_action_buttons() -> void:
	for button: Button in action_buttons.get_children():
		button.set_pressed_no_signal(false)


## handles gear action to use after any item is clicked.
## equip: uses the item, gear defaults to equiping
## drop: removes 1 item from clicked item's stack
## does nothing if no gear action is selected
func _on_item_clicked(inventory: Inventory, item_id: int) -> void:
	var item: Item = inventory.get_item(item_id)
	match (_gear_action_state):
		GearActionState.EQUIP:
			print("equip gear action")
			inventory.use_item(item_id)
		GearActionState.DROP:
			print("drop gear action")
			inventory.remove_item(item_id)
		_:
			print("no gear action")


## sets gear action to equip when equip button is toggled on
func _on_equip_button_toggled(toggled_on: bool) -> void:
	_unpress_action_buttons()
	_gear_action_state = GearActionState.NONE
	equip_button.set_pressed_no_signal(toggled_on)
	if toggled_on:
		_gear_action_state = GearActionState.EQUIP


## sets drop action to equip when drop button is toggled on
func _on_drop_button_toggled(toggled_on: bool) -> void:
	_unpress_action_buttons()
	_gear_action_state = GearActionState.NONE
	drop_button.set_pressed_no_signal(toggled_on)
	if toggled_on:
		_gear_action_state = GearActionState.DROP


## hides current scene i.e. return to previous menu
func _on_back_button_pressed() -> void:
	hide()


# subclasses
