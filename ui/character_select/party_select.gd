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

	QuestManager.generate_quest()
	QuestManager.generate_quest()
	QuestManager.generate_quest()
	QuestManager.untrack_latest_quest()

	# # TODO: remove after testing
	# var test_quest: Quest = Quest.new()
	# test_quest.title = "greater cactus culling"
	# test_quest.description = "cactus must be slain... again!"

	# # TODO: remove after testing
	# var task: SlayTask = SlayTask.new()
	# # task.description = "slay 1 cactus"
	# task.target_entity_name = "cactus"
	# task.target_slay_count = 2
	# task.set_default_description()
	# test_quest.add_task(task)

	# var second_task: SlayTask = SlayTask.new()
	# # task.description = "slay 1 cactus"
	# second_task.target_entity_name = "cactus"
	# second_task.target_slay_count = 1
	# second_task.description = "slay the final cactus alive!"
	# test_quest.add_task(second_task)

	# # TODO: remove after testing
	# var other_quest: Quest = Quest.new()
	# other_quest.title = "great cactus culling"
	# other_quest.description = "cactus must be slain!"

	# # TODO: remove after testing
	# var other_task: SlayTask = SlayTask.new()
	# other_task.target_entity_name = "cactus"
	# other_task.target_slay_count = 1
	# other_task.set_default_description()
	# other_quest.add_task(other_task)

	# # TODO: remove after testing
	# QuestManager.add_quest(other_quest, true)
	# QuestManager.track_quest(QuestManager.quest_amount() - 1)
	# QuestManager.add_quest(test_quest, true)
	# QuestManager.track_quest(QuestManager.quest_amount() - 1)
	# test_quest.check_completion_status()

	var main_instance = main_scene.instantiate()
	get_tree().root.add_child(main_instance)
	main_instance.set_player_position_to_current_map_default()
	get_node(MainUtils.FADER_PATH).play("fade")
	queue_free()
