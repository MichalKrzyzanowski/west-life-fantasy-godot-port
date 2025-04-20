# @tool
# class_name name
extends "shop.gd"
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
@onready var inventory_panel: NinePatchRect = $InventoryPanel
@onready var title_panel: NinePatchRect = $TitlePanel
# legacy inventory
@onready var legacy_inventory: Node = $Inventory
@onready var legacy_inventory_gui: FlowContainer = $Inventory/InventoryPanel/VBoxContainer/ConsumablesGui


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


func _ready() -> void:
	super()
	# set default legacy inventory gui options
	legacy_inventory_gui.set_inventory(target_inventory, PartyManager.party)

	# connect item gui clicked signal
	legacy_inventory_gui.on_item_gui_clicked.connect(_on_item_clicked)


# remaining builtins e.g. _process, _input


# public methods


# private methods
func _enter_standby_state() -> void:
	super()
	options_panel.show()
	_toggle_legacy_inventory(false)
	inventory_panel.show()
	title_panel.show()


func _enter_sell_state() -> void:
	options_panel.hide()
	_toggle_legacy_inventory(true)
	inventory_panel.hide()
	title_panel.hide()


func _on_sell_button_pressed() -> void:
	print("sell button pressed")
	shop_state = ShopState.SELL
	info_label.text = "Whose item do want to sell?"


func _on_exit_button_pressed() -> void:
	match shop_state:
		ShopState.STANDBY:
			print("exit button pressed")
		ShopState.BUY:
			shop_state = ShopState.STANDBY
			info_label.text = "Thank you!\n...\nSomething else?"


func _toggle_legacy_inventory(is_shown: bool) -> void:
	for gui: Control in legacy_inventory.get_children():
		gui.visible = is_shown
	# legacy_title.visible = is_shown
	# legacy_inventory_panel.visible = is_shown
	# legacy_title.visible = is_shown
	# legacy_title.visible = is_shown


func _on_back_button_pressed() -> void:
	info_label.text = "Too bad\n...\nSomething else?"
	shop_state = ShopState.STANDBY


# subclasses
