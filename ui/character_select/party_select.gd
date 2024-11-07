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
@onready var character_grid = $CharacterGrid as GridContainer
@onready var main_scene = preload("res://scenes/main/main.tscn")


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input


# public methods


# private methods


# subclasses


## add all currently selected characters to the party
## move to desert map scene
func _on_continue_button_pressed() -> void:
	for item in character_grid.get_children():
		# if item select from character_grid is valid,
		# add selected chatacter to party and create new inventory
		if item.has_method("add_current_to_party"):
			item.call("add_current_to_party")
			InventoryManager.create_party_inventory()

	InventoryManager.consumables_inventory = Inventory.new()
	# TODO: remove after testing
	InventoryManager.test_populate_inventories()
	for i in InventoryManager._party_inventories:
		print("inventory: ", i)

	print("consumables: ", InventoryManager.consumables_inventory)

	var main_instance = main_scene.instantiate()
	get_tree().root.add_child(main_instance)
	main_instance.set_player_position_to_current_map_default()
	get_node(MainUtils.FADER_PATH).play("fade")
	queue_free()
