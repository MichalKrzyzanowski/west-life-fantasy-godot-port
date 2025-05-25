# @tool
# class_name name
extends Node
# docstring


# signals

# enums

# constants

# @export vars

# public vars
## list of indices of quests that should be tracked
## e.g. displayed by a quest tracker
var tracked_quests: Array[int] = []
## total list of all quests accepted by party
var quest_list: Array[Quest] = []

# private vars

# @onready vars


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


# func _ready() -> void:
# 	pass


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		match event.keycode:
			KEY_Q:
				for i in quest_list:
					print(i)


# public methods
## add [param new_quest] to [member quest_list].
## automatically starts [param new_quest] if [param start_quest]
## is true
func add_quest(new_quest: Quest, start_quest: bool = false) -> void:
	if start_quest:
		new_quest.start()

	quest_list.append(new_quest)


## add quest inxed from [member quest_list] with [param index]
## to [member tracked_quests] list
func track_quest(index: int) -> void:
	if quest_list.get(index):
		tracked_quests.append(index)


## check if slain [param entity] was required by any quest
## task
func check_slain_entity(entity: EntityProperties) -> void:
	for quest: Quest in quest_list:
		# skip quest if its not started
		if !quest.is_in_progress():
			continue
		quest.current_task().check_completion(entity)


## get total quest amount
func quest_amount() -> int:
	return quest_list.size()


# private methods


# subclasses
