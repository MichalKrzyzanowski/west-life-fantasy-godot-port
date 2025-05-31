# @tool
class_name SlayTask
extends Task
# docstring


# signals

# enums

# constants

# @export vars
## task target name i.e. enemy to slay
@export var target_entity_name: String
## required amount of targets to slay
@export var target_slay_count: int = 1

# public vars

# private vars
## current amount of targets slain
var _current_slay_count: int = 0

# @onready vars


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


# func _ready() -> void:
# 	pass


# remaining builtins e.g. _process, _input


# public methods
## sets [member description] to format:
## "slay x target" where x = [member target_slay_count] and
## target = [member target_entity_name]
func set_default_description() -> void:
	description = "slay %d %s" % [
			target_slay_count, target_entity_name
	]


## checks if [member target_slay_count] has been reached
func target_slay_count_reached() -> bool:
	return _current_slay_count >= target_slay_count


## checks if [param target] is of type [class EntityProperties].
## then, checks if [param target.name] matches [member target_entity_name].
## if the checks pass, [signal on_task_complete] is emitted
func check_completion(target: Variant) -> void:
	# no target name set, skipping
	if !target_entity_name:
		print("no target name specified, skipping task")
		on_task_complete.emit()
		return

	# incorrect target type
	if target is not EntityProperties:
		return

	# target matches target name
	if target.name.to_lower() == target_entity_name.to_lower():
		print("%s matches target: %s" % [target.name, target_entity_name])
		_current_slay_count += 1
		if target_slay_count_reached():
			print("task complete")
			on_task_complete.emit()


# private methods
## slay task string representation
func _to_string() -> String:
	return "%s\ntarget: %s\nslain: %d" % [description, target_entity_name, _current_slay_count]


# subclasses

