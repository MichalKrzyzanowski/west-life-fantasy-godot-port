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
var _quest_type_callbacks: Dictionary = {
	"main": func() -> MainQuest: return MainQuest.new(),
}

# @onready vars


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


## add to persist group for save/load
func _ready() -> void:
	add_to_group("persist")


# remaining builtins e.g. _process, _input


# public methods
## de initializes quest manager
func deinit() -> void:
	quest_list.clear()
	tracked_quests.clear()


## add [param new_quest] to [member quest_list].
## automatically starts [param new_quest] if [param start_quest]
## is true
func add_quest(new_quest: Quest, start_quest: bool = true) -> void:
	if has_quest(new_quest):
		printerr("quest already exists!")
		return

	if start_quest:
		new_quest.start()

	quest_list.append(new_quest)


## check if [param quest] is in [member quest_list]
func has_quest(quest: Quest) -> bool:
	var found: int = quest_list.find_custom(_quest_match_title.bind(quest.title))

	return found != -1

## returns [param quest] if it is in [member quest_list],
## null otherwise
func get_quest(quest: Quest) -> Quest:
	var found: int = quest_list.find_custom(_quest_match_title.bind(quest.title))

	if found != -1:
		return quest_list[found]

	return null


## returns index of [param index] if it is in [member quest_list]
func get_quest_index(quest: Quest) -> int:
	return quest_list.find_custom(_quest_match_title.bind(quest.title))


## add quest index from [member quest_list] with [param index]
## to [member tracked_quests] list
func track_quest(index: int) -> void:
	# skip tracking if tracked quest limit reached
	if tracked_quests.size() == tracked_quest_limit:
		print("tracked quest limit reached!")
		return

	if index in tracked_quests:
		print("quest already tracked!")
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


## returns tracked quest index at [param index]
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


## saves data as dictionary for JSON format
func save() -> Dictionary:
	var quest_data_list: Array[Dictionary]

	for quest: Quest in quest_list:
		quest_data_list.append(quest.save())

	return {
		"name": name,
		"parent": get_parent().get_path(),
		"tracked_quests": tracked_quests,
		"quest_list": quest_data_list,
		}


## load data from JSON savefile
func load(data: Dictionary) -> void:
	tracked_quests.assign(data["tracked_quests"])

	for quest_data: Dictionary in data["quest_list"]:
		var quest: Quest
		if !quest_data.has("type") || !_quest_type_callbacks.has(quest_data["type"]):
			print("loading normal quest")
			quest = Quest.new()
			quest.load(quest_data)
			quest_list.append(quest)
			continue
		print("loading main quest")
		quest = _quest_type_callbacks[quest_data["type"]].call()
		quest.load(quest_data)
		quest_list.append(quest)


# private methods
func _quest_match_title(quest: Quest, target_title: String) -> bool:
	return quest.title == target_title


# subclasses
