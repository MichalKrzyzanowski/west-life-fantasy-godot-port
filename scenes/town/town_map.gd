# @tool
# class_name name
extends BaseMap
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
@onready var item_shop_ui: Control = $ShopUI/ItemShop


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	item_shop_ui.set_target_inventory(InventoryManager.consumables_inventory)


# remaining builtins e.g. _process, _input


# public methods


# private methods


# subclasses
