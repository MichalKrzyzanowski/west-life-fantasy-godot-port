# @tool
# class_name name
extends Label
# docstring


# signals

# enums

# constants

# @export vars
@export var quest: Quest
@export_color_no_alpha var complete_color: Color
@export var use_verbose_description: bool = false

# public vars

# private vars

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	if !quest:
		printerr("no quest to track!")
		return

	if !use_verbose_description:
		text = quest.description
		return

	update_description_verbose()
	if quest.is_finished():
		set_complete_color()
		return

	quest.on_quest_finished.connect(set_complete_color)
	quest.on_task_changed.connect(update_description_verbose)


# remaining builtins e.g. _process, _input


# public methods
func update_description_verbose() -> void:
	var current_task_description: String = "none"
	var current_task: Task = quest.current_task()

	if current_task:
		current_task_description = current_task.description

	text = "%s\n[%s]\n<%s>" % [quest.title, quest.description, current_task_description]


func set_complete_color() -> void:
	modulate = complete_color


# private methods


# subclasses
