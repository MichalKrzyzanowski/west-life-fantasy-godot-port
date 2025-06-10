# @tool
class_name MainQuest
extends Quest
# docstring


# signals

# enums

# constants

# @export vars
@export_enum("Blue", "Red", "Orange", "Black") var orb: int = 0

# public vars

# private vars

# @onready vars


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


# func _ready() -> void:
# 	pass


# remaining builtins e.g. _process, _input


# public methods
## check if quest has no more tasks left
## to do. quest is marked as [enum QuestState.FINISHED] if
## no more tasks available.
## updates [member PartyManager.orbs] based on [member orb] index
func check_completion_status() -> void:
	if _current_task_index == task_list.size():
		_quest_state = QuestState.FINISHED
		PartyManager.update_orb(orb, true)
		on_quest_finished.emit()


# private methods


# subclasses

