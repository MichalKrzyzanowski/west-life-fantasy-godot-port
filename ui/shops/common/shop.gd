# @tool
# class_name name
extends Control
# docstring


# signals
signal on_exit()

# enums
enum ShopState {
	STANDBY,
	BUY,
	SELL,
}

# constants

# @export vars
@export var shop_name: String
@export var enable_sell_mode: bool = false
## array of item ids to populate the shop with
@export var shop_items: Array[int]
@export var target_inventory: Inventory

# public vars
var shop_inventory: Inventory = Inventory.new()

# private vars
var shop_state: ShopState = ShopState.STANDBY:
	set(new_state):
		shop_state = new_state
		match shop_state:
			ShopState.STANDBY:
				_enter_standby_state()
			ShopState.BUY:
				_enter_buy_state()
			ShopState.SELL:
				_enter_sell_state()

var _selected_shop_item: Item

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
	# set shop name
	title_label.text = shop_name

	# hide sell button is sell mode is disabled
	if !enable_sell_mode:
		sell_button.hide()

	# populate shop items from item ids
	if !shop_items.is_empty():
		shop_inventory.add_items(shop_items)

	# set default inventory_gui options
	shop_inventory_gui.set_inventory(shop_inventory, PartyManager.party)

	# connect relevant gil & item signals
	PartyManager.on_gil_changed.connect(_update_gil_text)
	shop_inventory_gui.on_item_gui_clicked.connect(_on_item_clicked)

	_update_gil_text()


# remaining builtins e.g. _process, _input


# public methods
## updates [member target_inventory] with [param inventory]
func set_target_inventory(inventory: Inventory) -> void:
	target_inventory = inventory


# private methods
func _on_item_clicked(inventory: Inventory, item_id: int) -> void:
	match shop_state:
		ShopState.STANDBY:
			_buy_item(inventory, item_id)
		ShopState.SELL:
			_sell_item(inventory, item_id)


func _buy_item(inventory: Inventory, item_id: int) -> void:
	_selected_shop_item = inventory.get_item(item_id)
	print("buying %s" % _selected_shop_item.name)

	# player cannot afford the item, show a different message.
	# shop state should not change
	if PartyManager.gil < _selected_shop_item.stats.gil_value:
		info_label.text = "You can't\nafford that."
		return

	info_label.text = "%d\nGold\nOK?" % _selected_shop_item.stats.gil_value
	shop_state = ShopState.BUY


func _sell_item(inventory: Inventory, item_id: int) -> void:
	_selected_shop_item = inventory.get_item(item_id)
	print("selling %s" % _selected_shop_item.name)

	if _selected_shop_item.stats.gil_value > 0:
		PartyManager.gil += _selected_shop_item.stats.gil_value / 2.0
	inventory.remove_item(item_id)


func _update_gil_text() -> void:
	gil_label.text = "%d G" % PartyManager.gil


func _enter_standby_state() -> void:
	buy_button.text = "Buy"
	exit_button.text = "Exit"
	if enable_sell_mode:
		sell_button.show()
	buy_button.show()
	exit_button.show()


func _enter_buy_state() -> void:
	buy_button.text = "Yes"
	exit_button.text = "No"
	sell_button.hide()
	options_panel.show()


func _enter_sell_state() -> void:
	buy_button.hide()
	sell_button.hide()
	exit_button.text = "Back"


func _on_buy_button_pressed() -> void:
	match shop_state:
		ShopState.STANDBY:
			options_panel.hide()
			info_label.text = "What do you need"
		ShopState.BUY:
			# spend gil and add item to target inventory e.g. party consumables inventory
			PartyManager.spend_gil(_selected_shop_item.stats.gil_value)
			target_inventory.add_item(_selected_shop_item.id)

			shop_state = ShopState.STANDBY
			info_label.text = "Thank you!\nWhat else?"


func _on_sell_button_pressed() -> void:
	print("sell button pressed")
	title_label.text = "Inventory"
	shop_inventory_gui.set_inventory(target_inventory, PartyManager.party)
	shop_state = ShopState.SELL
	info_label.text = "Whose item do want to sell?"


func _on_exit_button_pressed() -> void:
	match shop_state:
		ShopState.STANDBY:
			print("exit button pressed")
			on_exit.emit()
		ShopState.BUY:
			shop_state = ShopState.STANDBY
			info_label.text = "Thank you!\n...\nSomething else?"
		ShopState.SELL:
			title_label.text = shop_name
			info_label.text = "Too bad\n...\nSomething else?"
			shop_inventory_gui.set_inventory(shop_inventory, PartyManager.party)
			shop_state = ShopState.STANDBY


# subclasses
