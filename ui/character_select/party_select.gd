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

	# TODO: remove after testing
	var test_quest: Quest = Quest.new()
	test_quest.title = "test_quest"
	test_quest.description = "sample description"

	# TODO: remove after testing
	var task: SlayTask = SlayTask.new()
	# task.description = "slay 1 cactus"
	task.target_entity_name = "cactus"
	task.target_slay_count = 2
	task.set_default_description()
	test_quest.add_task(task)

	# TODO: remove after testing
	QuestManager.add_quest(test_quest, true)
	test_quest.check_completion_status()
	QuestManager.track_quest(QuestManager.quest_amount() - 1)
	print(test_quest)

	var main_instance = main_scene.instantiate()
	get_tree().root.add_child(main_instance)
	main_instance.set_player_position_to_current_map_default()
	get_node(MainUtils.FADER_PATH).play("fade")
	queue_free()
