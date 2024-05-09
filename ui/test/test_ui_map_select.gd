# @tool
# class_name name
extends VBoxContainer
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
@onready var new_button = get_node("New")
@onready var continue_button = get_node("Continue")
@onready var current_root = get_parent_control()


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	print(current_root)
	if !current_root:
		print("rhis is the current root")


# remaining builtins e.g. _process, _input


# public methods


# private methods


# subclasses



func _on_new_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/desert/desert_map.tscn")


func _on_continue_pressed() -> void:
	SaveManager.load_game("debug")
	if current_root:
		current_root.queue_free()
	else:
		queue_free()
