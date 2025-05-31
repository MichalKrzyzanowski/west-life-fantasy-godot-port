# @tool
# class_name name
extends Node
# docstring


# signals
## emitted when a tracked quest is added or removed
signal on_tracked_quests_changed()

# enums

# constants

# @export vars

# public vars
## list of indices of quests that should be tracked
## e.g. displayed by a quest tracker
var tracked_quests: Array[int] = []
## limit to how many quests can be tracked
var tracked_quest_limit: int = 5
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
			KEY_EQUAL:
				print("generating...")
				generate_quest()
			KEY_MINUS:
				print("removing...")
				untrack_latest_quest()


# public methods
## add [param new_quest] to [member quest_list].
## automatically starts [param new_quest] if [param start_quest]
## is true
func add_quest(new_quest: Quest, start_quest: bool = true) -> void:
	if start_quest:
		new_quest.start()

	quest_list.append(new_quest)


## add quest index from [member quest_list] with [param index]
## to [member tracked_quests] list
func track_quest(index: int) -> void:
	# skip tracking if tracked quest limit reached
	if tracked_quests.size() == tracked_quest_limit:
		print("tracked quest limit reached!")
		return

	# track quest if the quest exists
	if quest_list.get(index):
		tracked_quests.append(index)
		on_tracked_quests_changed.emit()


## add newly added quest to [member quest_list]
func track_latest_quest() -> void:
	track_quest(quest_list.size() - 1)


## remove quest [param index] from [member tracked_quests]
func untrack_quest(index: int) -> void:
	tracked_quests.erase(index)
	on_tracked_quests_changed.emit()


## remove newly added quest from [member tracked_quests]
func untrack_latest_quest() -> void:
	tracked_quests.pop_back()
	on_tracked_quests_changed.emit()


func get_tracked_quest_index(index: int) -> int:
	if index >= tracked_quests.size():
		return -1

	return tracked_quests.get(index)


## get quest from [member tracked_quests] at [param index].
## returns null if [param index] is invalid
func get_tracked_quest(index: int) -> Quest:
	return quest_list.get(tracked_quests.get(index))


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


# TODO: remove after testing
func generate_quest() -> void:
	var quest: Quest = Quest.new()
	quest.title = "generated title"
	quest.description = "generated desc"

	var task: SlayTask = SlayTask.new()
	task.description = "generated description"
	task.target_entity_name = "none"
	quest.add_task(task)

	add_quest(quest, true)
	track_latest_quest()


# private methods


# subclasses
