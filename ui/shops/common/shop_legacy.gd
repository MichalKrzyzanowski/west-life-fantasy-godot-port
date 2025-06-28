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


## sets up legacy sell inventory
func _ready() -> void:
	super()
	# set default legacy inventory gui options
	if target_inventory:
		legacy_inventory_gui.set_inventory(target_inventory, PartyManager.party)

	# connect item gui clicked signal
	legacy_inventory_gui.on_item_gui_clicked.connect(_on_item_clicked)


# remaining builtins e.g. _process, _input


# public methods
## updates [member target_inventory] with [param inventory].
## also updates legacy sell inventory
func set_target_inventory(inventory: Inventory) -> void:
	super(inventory)
	legacy_inventory_gui.set_inventory(target_inventory, PartyManager.party)


# private methods
## handles hiding of legacy sell inventory
func _enter_standby_state() -> void:
	super()
	options_panel.show()
	_toggle_legacy_inventory(false)
	inventory_panel.show()
	title_panel.show()


## handles showing of legacy sell inventory
func _enter_sell_state() -> void:
	options_panel.hide()
	_toggle_legacy_inventory(true)
	inventory_panel.hide()
	title_panel.hide()


## enters legacy sell state
func _on_sell_button_pressed() -> void:
	audio_player.play()
	shop_state = ShopState.SELL
	info_label.text = "Whose item do want to sell?"


## exit legacy shop
func _on_exit_button_pressed() -> void:
	audio_player.play()
	await audio_player.finished
	match shop_state:
		ShopState.STANDBY:
			on_exit.emit()
		ShopState.BUY:
			shop_state = ShopState.STANDBY
			info_label.text = "Thank you!\n...\nSomething else?"


## helper for hiding/showing legacy sell inventory
func _toggle_legacy_inventory(is_shown: bool) -> void:
	for gui: Control in legacy_inventory.get_children():
		gui.visible = is_shown


## called when exiting legacy sell state
func _on_back_button_pressed() -> void:
	audio_player.play()
	info_label.text = "Too bad\n...\nSomething else?"
	shop_state = ShopState.STANDBY


# subclasses
