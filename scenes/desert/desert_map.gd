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
@onready var tavern_scene: PackedScene = preload("res://scenes/tavern/tavern.tscn")


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


# func _ready() -> void:
# 	pass


# remaining builtins e.g. _process, _input


# public methods


## saves data as dictionary for JSON format


## load data from JSON savefile


# private methods
func _enter_tavern(_body: Node2D) -> void:
	get_node(MainUtils.MAIN_SCENE_PATH).queue_free()

	# deinit singletons
	InventoryManager.deinit()
	QuestManager.deinit()
	PartyManager.deinit()

	get_tree().change_scene_to_packed(tavern_scene)


# subclasses
