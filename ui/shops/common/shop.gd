# @tool
# class_name name
extends Control
# docstring


# signals

# enums
enum ShopState {
	STANDBY,
	BUY,
}

# constants

# @export vars
@export var shop_name: String
@export var shop_inventory: Inventory

# public vars

# private vars
var shop_state: ShopState = ShopState.STANDBY:
	set(new_state):
		shop_state = new_state
		match shop_state:
			ShopState.STANDBY:
				buy_button.text = "Buy"
				exit_button.text = "Exit"
				sell_button.show()
			ShopState.BUY:
				buy_button.text = "Yes"
				exit_button.text = "No"
				sell_button.hide()
				options_panel.show()

var _selected_shop_item: Item
# var _shopkeeper_dialogue: Dictionary[String, String] = {
# 	"welcome": "Welcome",
# 	"buy_mode": "",
# 	"decline": "",
# }

# @onready vars
@onready var shop_inventory_gui: HFlowContainer = $InventoryPanel/InventoryGui
@onready var options_panel: NinePatchRect = $OptionsPanel
# labels
@onready var gil_label: Label = $GilLabel/Label
@onready var title_label: Label = $TitlePanel/Label
@onready var info_label: Label = $InfoPanel/Label
# buttons
@onready var buy_button: Button = $OptionsPanel/OptionsList/BuyButton
@onready var sell_button: Button = $OptionsPanel/OptionsList/SellButton
@onready var exit_button: Button = $OptionsPanel/OptionsList/ExitButton


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	shop_inventory = Inventory.new()
	shop_inventory.add_item(33)
	shop_inventory.add_item(34)
	shop_inventory.add_item(35)
	shop_inventory_gui.enable_item_use_action = false
	shop_inventory_gui.set_inventory(shop_inventory, PartyManager.party)

	PartyManager.on_gil_changed.connect(_update_gil_text)
	shop_inventory_gui.on_item_gui_clicked.connect(_buy_item)

	_update_gil_text()


# remaining builtins e.g. _process, _input


# public methods


# private methods
func _buy_item(inventory: Inventory, item_id: int) -> void:
	_selected_shop_item = inventory.get_item(item_id)
	print("buying %s" % _selected_shop_item.name)
	# TODO: replace with stats.gil_value once implemented
	var gil = 15
	info_label.text = "%d\nGold\nOK?" % gil
	shop_state = ShopState.BUY


func _sell_item(inventory: Inventory, item_id: int) -> void:
	print("selling %s" % inventory.get_item(item_id).name)


func _update_gil_text() -> void:
	gil_label.text = "%d G" % PartyManager.gil


func _on_buy_button_pressed() -> void:
	match shop_state:
		ShopState.STANDBY:
			options_panel.hide()
			info_label.text = "What do you need"
		ShopState.BUY:
			# TODO: add purchase item logic
			shop_state = ShopState.STANDBY
			info_label.text = "Thank you!\nWhat else?"


func _on_sell_button_pressed() -> void:
	print("sell button pressed")


func _on_exit_button_pressed() -> void:
	match shop_state:
		ShopState.STANDBY:
			print("exit button pressed")
		ShopState.BUY:
			shop_state = ShopState.STANDBY
			info_label.text = "Thank you!\n...\nSomething else?"


# subclasses
