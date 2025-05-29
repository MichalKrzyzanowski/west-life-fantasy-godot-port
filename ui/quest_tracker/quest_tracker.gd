# @tool
# class_name name
extends Control
# docstring


# signals

# enums

# constants
const QuestGui: PackedScene = preload("res://ui/quest_tracker/quest_gui.tscn")

# @export vars
@export_group("quest gui")
@export var use_verbose_description: bool = false
@export_color_no_alpha var complete_color: Color

# public vars

# private vars

# @onready vars
@onready var quest_list: VBoxContainer = $QuestList
@onready var panel: ColorRect = $Panel


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	# quest_list.resized.connect(_resize_panel)
	QuestManager.on_tracked_quests_changed.connect(_on_tracked_quests_changed)
	_on_tracked_quests_changed()


# remaining builtins e.g. _process, _input


# public methods


# private methods
func _resize_panel() -> void:
	panel.set_size(quest_list.get_combined_minimum_size(), true)


func _on_tracked_quests_changed() -> void:
	for quest_index: int in QuestManager.tracked_quests:
		print("tracked index: ", quest_list)
		# create label and set text to quest description
		var quest_qui: Label = QuestGui.instantiate()
		var quest: Quest = QuestManager.quest_list[QuestManager.tracked_quests[quest_index]]
		quest_qui.quest = quest
		quest_qui.use_verbose_description = use_verbose_description
		quest_qui.complete_color = complete_color
		quest_list.add_child(quest_qui)

	_resize_panel()


# subclasses
