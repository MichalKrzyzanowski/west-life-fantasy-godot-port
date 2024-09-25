# @tool
# class_name name
extends Node
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input


# public methods
func clear() -> void:
	for child: Node in get_children():
		remove_child(child)
		child.queue_free()


func replace_map(map: Node) -> void:
	if get_child_count() > 0:
		clear()

	add_child(map)


func get_map() -> Node:
	if get_child_count() == 0:
		return null
	return get_child(0)


# private methods


# subclasses
