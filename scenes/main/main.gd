# @tool
# class_name name
extends Node2D
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
@onready var camp_menu: Control = $UI/CampMenu
@onready var fader: AnimationPlayer = $Fader
@onready var player: CharacterBody2D = $OverworldPlayer
@onready var world: Node = $World


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


## configure root viewport canvas cull mask
## to prevent minimap icons from rendering
func _ready() -> void:
	var root_viewport: Viewport = get_tree().root.get_viewport()
	# cull mask configured to render environment, player,
	# bullets, & enemies
	root_viewport.canvas_cull_mask = 15


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_menu"):
		get_tree().paused = true
		camp_menu.show()


# public methods
func set_player_position_to_current_map_default() -> void:
	var current_map: Node2D = world.get_map()
	if !current_map.has_method("get_default_position"):
		print("no default position marker found in map %s" % current_map.name)
		return

	player.global_position = current_map.call("get_default_position")


## saves data as dictionary for JSON format
func save() -> Dictionary:
	return {
		"filename": get_scene_file_path(),
		"parent": get_parent().get_path(),
	}


## load data from JSON savefile
func load(_data: Dictionary) -> void:
	world.clear()


# private methods


# subclasses
