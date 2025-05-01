# @tool
# class_name name
extends Control
# docstring


# signals

# enums
## enum class representing gear interaction
## state. each state changes behaviour of click action
## on a gear item
enum GearActionState {
	EQUIP = 0, ## equips clicked gear
	UPGRADE, ## upgrades clicked gear
	DROP, ## removes clicked gear from inventory
	NONE, ## default state, nothing happens when item is clicked
}

# constants

# @export vars

# public vars
## gear item filter, defaults to "armour"
var item_filter: String = "armour"

# private vars
## current gear action state defaults to [constant GearActionState.NONE]
var _gear_action_state: GearActionState = GearActionState.NONE

# @onready vars
@onready var gui_inventories: VBoxContainer = $Inventories
@onready var action_buttons: NinePatchRect = $ActionsPanel
@onready var equip_button: Button = $ActionsPanel/EquipButton
@onready var drop_button: Button = $ActionsPanel/DropButton


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


## initializes each party member's inventory gui display
func _ready() -> void:
	# initialize inventories for each gui inventory in the scene
	for i: int in gui_inventories.get_child_count():
		gui_inventories.get_child(i).set_party_name_text(PartyManager.get_member(i))

		var gui_inventory: HFlowContainer = gui_inventories.get_child(i).get_gui_inventory()
		gui_inventory.set_item_filter(item_filter)

		var inv_party_ref: Array[EntityProperties] = [PartyManager.get_member(i)]
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
	match (_gear_action_state):
		GearActionState.EQUIP:
			print("equip gear action")
			inventory.use_item(item_id)
		GearActionState.DROP:
			print("drop gear action")
			inventory.remove_item(item_id)
		GearActionState.UPGRADE:
			print("upgrade gear action")
			inventory.upgrade_item(item_id)
		_:
			print("no gear action")


## sets gear action to equip when equip button is toggled on
func _on_equip_button_toggled(toggled_on: bool) -> void:
	_unpress_action_buttons()
	_gear_action_state = GearActionState.NONE
	equip_button.set_pressed_no_signal(toggled_on)
	if toggled_on:
		_gear_action_state = GearActionState.EQUIP


## sets gear action to equip when drop button is toggled on
func _on_drop_button_toggled(toggled_on: bool) -> void:
	_unpress_action_buttons()
	_gear_action_state = GearActionState.NONE
	drop_button.set_pressed_no_signal(toggled_on)
	if toggled_on:
		_gear_action_state = GearActionState.DROP


## hides current scene i.e. return to previous menu
func _on_back_button_pressed() -> void:
	_unpress_action_buttons()
	hide()


# subclasses
