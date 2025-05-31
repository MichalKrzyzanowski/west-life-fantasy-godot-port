# @tool
# class_name name
extends Control
# docstring


# signals

# enums

# constants
## quest gui scene, used for instantiating
const QuestGui: PackedScene = preload("res://ui/quest_tracker/quest_gui.tscn")

# @export vars
## quest qui related config options
@export_group("quest gui")
## color to set label text when [member quest] is complete
@export var use_verbose_description: bool = false
## displays description with more detail i.e. quest title,
## description, & current task description
@export_color_no_alpha var complete_color: Color

# public vars

# private vars

# @onready vars
@onready var quest_list: VBoxContainer = $QuestList
@onready var panel: ColorRect = $Panel


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


## initializes [member panel] size change & relevant signal connection
func _ready() -> void:
	quest_list.resized.connect(_resize_panel)
	QuestManager.on_tracked_quests_changed.connect(_on_tracked_quests_changed)
	_on_tracked_quests_changed()


# remaining builtins e.g. _process, _input


# public methods


# private methods
## sets [member panel] size to newly-updated [member quest_list] size
func _resize_panel() -> void:
	panel.set_size(quest_list.get_combined_minimum_size(), true)


## updated [member quest_list] children based on [member QuestManager.tracked_quests]
func _on_tracked_quests_changed() -> void:
	var quest_list_size: int = quest_list.get_child_count()

	# loop through all tracked quests
	var index: int = 0
	for i: int in QuestManager.tracked_quests.size():
		var quest_qui: Label

		# initialize quest_gui scene
		# if index is within quest_qui, fetch existing quest_qui
		# otherwise create a new instance of quest_qui
		if i < quest_list_size:
			quest_qui = quest_list.get_child(i)
		else:
			quest_qui = QuestGui.instantiate()

		# fetch quest at index i from QuestManager
		var quest: Quest = QuestManager.get_tracked_quest(i)

		# setup quest_gui quest reference and index
		quest_qui.quest = quest
		quest_qui.quest_index = QuestManager.get_tracked_quest_index(i)

		# setup quest_gui config options
		quest_qui.use_verbose_description = use_verbose_description
		quest_qui.complete_color = complete_color

		# add quest_gui to quest list
		if i >= quest_list_size:
			quest_list.add_child(quest_qui)

		index = i

	# skip removal process if original quest size was 0 before
	# any new quests got tracked
	if quest_list_size == 0:
		return

	quest_list_size = quest_list.get_child_count()

	# edgecase for removal of last remaining quest in
	# quest_list
	if quest_list_size - 1 == 0:
		quest_list.get_child(0).queue_free()
		return

	# loop through & remove extra quest_guis in quest list
	while index < quest_list_size - 1:
		quest_list.get_child(index).queue_free()
		index += 1


# subclasses
