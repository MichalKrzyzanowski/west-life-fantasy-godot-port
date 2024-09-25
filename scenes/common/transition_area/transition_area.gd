@tool
# class_name name
extends Area2D
# docstring


# signals
signal on_transition_start

# enums

# constants

# @export vars
@export var shape: Shape2D:
	set(new_shape):
		shape = new_shape
		if collision_shape:
			collision_shape.shape = shape

@export var texture: Texture:
	set(new_texture):
		texture = new_texture
		if sprite:
			sprite.texture = texture

@export var origin_locale: LocaleData
@export var target_locale: LocaleData
@export var map_ref : Node2D

# public vars

# private vars

# @onready vars
@onready var collision_shape := $CollisionShape2D as CollisionShape2D
@onready var sprite := $Sprite2D as Sprite2D
# TODO: move to _ready()
@onready var world: Node = get_node(MainUtils.WORLD_PATH)
@onready var overworld_player: CharacterBody2D = get_node(MainUtils.PLAYER_PATH)
@onready var fader: AnimationPlayer = get_node(MainUtils.FADER_PATH)


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	collision_shape.shape = shape
	sprite.texture = texture


# remaining builtins e.g. _process, _input


# public methods


# private methods
func _await_fader() -> void:
	if fader:
		fader.play_backwards("fade")
		await fader.animation_finished


func _on_body_entered(_body: Node2D) -> void:
	if !map_ref || !map_ref.has_method("get_previous_locale"):
		return

	fader.keep_paused = true
	await _await_fader()

	var locale: LocaleData
	# if target locale is missing, get the saved previous map
	if !target_locale:
		locale = map_ref.call("get_previous_locale")
	else:
		locale = target_locale

	var new_map = load(locale.scene_file).instantiate()
	# set previous map for new map, for backtracking purposes
	if origin_locale && new_map.has_method("set_previous_locale"):
		new_map.call("set_previous_locale", origin_locale)

	await get_tree().process_frame

	# var new_player = new_map.find_child("OverworldPlayer")
	# if new_player:
		# new_player.global_position = locale.entrance_position
	if locale:
		overworld_player.global_position = locale.entrance_position
	elif new_map.has_method("get_default_position"):
		overworld_player.global_position = new_map.call("get_default_position")
	else:
		overworld_player.global_position = Vector2()

	# get_tree().root.add_child(new_map)
	# map_ref.queue_free()
	world.replace_map(new_map)
	fader.keep_paused = false


# subclasses
