# @tool
class_name Quest
extends Resource
# docstring


# signals
## emitted when quest is finished
signal on_quest_finished()
## emitted when current task is completed and changed
signal on_task_changed()

# enums
## quest state
enum QuestState {
	NOT_STARTED, ## quest is not started i.e. not picked up from NPC
	IN_PROGRESS, ## quest is in progress i.e. started
	FINISHED, ## quest is finished i.e. all tasks completed
}

# constants

# @export vars
## quest id (unused)
@export var id: int = -1
## quest title
@export var title: String
## quest description
@export var description: String
## array of tasks required to be completed in
## order to finish the quest
@export var task_list: Array[Task] = []
## type of quest
@export_storage var type: String = "standard"

@export_group("rewards")
@export var items: Array[Reward]

# public vars

# private vars
## index of current task
var _current_task_index: int = 0
## current quest state
var _quest_state: QuestState = QuestState.NOT_STARTED:
	set(new_state):
		_quest_state = new_state
		match (_quest_state):
			QuestState.IN_PROGRESS:
				print("quest: %s in progress" % title)
			QuestState.FINISHED:
				pass

# @onready vars


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


# func _ready() -> void:
# 	pass


# remaining builtins e.g. _process, _input


# public methods
## starts the quest. checks if quests has
## at least one task and connects [signal Task.on_task_complete]
## signal to [method _on_current_task_completed].
## [member _quest_state] is set to [enum QuestState.IN_PROGRESS]
func start() -> bool:
	check_completion_status()
	if is_finished():
		printerr("quest has no tasks!")
		return false

	# set in progress state and connect on_task_complete Task signal
	_quest_state = QuestState.IN_PROGRESS
	connect_on_task_complete_signal()

	return true


## get current task.
## returns null if no tasks available or
## all task are complete
func current_task() -> Task:
	if _current_task_index < task_list.size():
		return task_list.get(_current_task_index)

	return null


## add new task
func add_task(task: Task) -> void:
	task_list.append(task)


## connects [signal Task.on_task_complete] signal
func connect_on_task_complete_signal() -> void:
	if !current_task():
		return

	if !task_list[_current_task_index].on_task_complete.is_connected(_on_current_task_completed):
		task_list[_current_task_index].on_task_complete.connect(_on_current_task_completed)


## check if quest has no more tasks left
## to do. quest is marked as [enum QuestState.FINISHED] if
## no more tasks available
func check_completion_status() -> void:
	if _current_task_index == task_list.size():
		_update_quest_status()


## checks if quest is [enum QuestState.IN_PROGRESS]
func is_in_progress() -> bool:
	return _quest_state == QuestState.IN_PROGRESS


## checks if quest is [enum QuestState.FINISHED]
func is_finished() -> bool:
	return _quest_state == QuestState.FINISHED


# private methods
## updates quest status such as state, adding rewards, etc.
## called when all tasks are completed
func _update_quest_status() -> void:
	_quest_state = QuestState.FINISHED
	# add reward items to party inventory
	for reward: Reward in items:
		if !reward:
			continue

		reward.earn()

	on_quest_finished.emit()


## switches to the next task if available
## the quest is marked [enum QuestState.FINISHED] if no more tasks are
## available
func _on_current_task_completed() -> void:
	task_list[_current_task_index].disconnect("on_task_complete", _on_current_task_completed)
	_current_task_index += 1
	check_completion_status()

	if is_finished():
		print("all tasks for quest \"%s\" completed!" % title)
		return

	task_list[_current_task_index].on_task_complete.connect(_on_current_task_completed)
	on_task_changed.emit()


## saves data as dictionary for JSON format
func save() -> Dictionary:
	var task_data_list: Array[Dictionary]
	for task: Task in task_list:
		task_data_list.append(task.save())

	var rewards_list: Array[Dictionary]
	for reward: Reward in items:
		rewards_list.append(reward.save())

	return {
		"title": title,
		"description": description,
		"type": type,
		"task_list": task_data_list,
		"current_task_index": _current_task_index,
		"quest_state": _quest_state,
		"rewards_list": rewards_list,
	}


## load data from JSON savefile
func load(data: Dictionary) -> void:
	title = data["title"]
	description = data["description"]
	type = data["type"]
	_current_task_index = data["current_task_index"]
	_quest_state = data["quest_state"]

	for task_data: Dictionary in data["task_list"]:
		var task: Task

		if task_data.has("target_name"):
			task = SlayTask.new()
			task.load(task_data)
		else:
			task = Task.new()
			task.load(data)

		task_list.append(task)

	for reward_data: Dictionary in data["rewards_list"]:
		var reward: Reward = Reward.new()
		reward.load(reward_data)
		items.append(reward)


## quest string representation
func _to_string() -> String:
	var str_rep: String = "%s\n%s\n%s\n" % [title, description, is_finished()]

	# get quest tasks representation
	for task: Task in task_list:
		str_rep += "%s\n" % task

	return str_rep


# subclasses
