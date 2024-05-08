extends Node2D
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
	var m = get_node("BlackMage")
	var a = get_node("Fighter")
	var c = get_node("Thief")
	var b = get_node("BlackBelt")
	remove_child(m)
	remove_child(a)
	remove_child(c)
	remove_child(b)
	PartyManager.add_member(m)
	PartyManager.add_member(a)
	PartyManager.add_member(c)
	PartyManager.add_member(b)
	# get_node("CanvasLayer/Panel/AnimationPlayer").play("fade_test")


# remaining builtins e.g. _process, _input


# public methods
func save() -> Dictionary:
	return {
		"filename": get_scene_file_path(),
		"parent": get_parent().get_path(),
		}


# private methods


# subclasses

