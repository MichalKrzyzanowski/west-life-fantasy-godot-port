# @tool
# class_name name
extends Label
# docstring


# signals

# enums

# constants

# @export vars
## tracked quest reference
@export var quest: Quest
## color to set label text when [member quest] is complete
@export_color_no_alpha var complete_color: Color
## displays description with more detail i.e. quest title,
## description, & current task description
@export var use_verbose_description: bool = false

# public vars
## index at which quest is stored in [member QuestManager.quest_index]
var quest_index: int = -1

# private vars

# @onready vars


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


## initializes description display & necessary signal
## connections
func _ready() -> void:
	if !quest:
		printerr("no quest to track!")
		return

	# set default quest description display
	if !use_verbose_description:
		text = quest.description
		return

	update_description_verbose()

	# check if quest is already finished
	if quest.is_finished():
		set_complete_color()
		return

	# connect relevant quest signals
	quest.on_quest_finished.connect(set_complete_color)
	quest.on_task_changed.connect(update_description_verbose)


# remaining builtins e.g. _process, _input


# public methods
## set label text to detailed quest description i.e.
## title, description, & task description
func update_description_verbose() -> void:
	var current_task_description: String = "none"
	var current_task: Task = quest.current_task()

	if current_task:
		current_task_description = current_task.description

	text = "%s\n[%s]\n<%s>" % [quest.title, quest.description, current_task_description]


## complete_color setter
func set_complete_color() -> void:
	modulate = complete_color


# private methods


# subclasses
