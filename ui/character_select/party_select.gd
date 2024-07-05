# @tool
# class_name name
extends Control
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
@onready var character_grid = $CharacterGrid as GridContainer
@onready var desert_scene = preload("res://scenes/desert/desert_map.tscn")
@onready var overworld_player = preload("res://entities/overworld-player/overworld_player.tscn")


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input


# public methods


# private methods


# subclasses


## add all currently selected characters to the party
## move to desert map scene
func _on_continue_button_pressed() -> void:
	for item in character_grid.get_children():
		if item.has_method("add_current_to_party"):
			item.call("add_current_to_party")
	# get_tree().change_scene_to_packed(desert_scene)

	var entry_map = desert_scene.instantiate()
	var player = overworld_player.instantiate()
	# var old_player = entry_map.find_child("OverworldPlayer")
	# entry_map.remove_child(old_player)
	# old_player.queue_free()
	entry_map.add_child(player)
	get_tree().root.add_child(entry_map)
	queue_free()
