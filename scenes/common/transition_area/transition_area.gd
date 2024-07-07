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
func _wait_for_faders() -> void:
	print(map_ref)
	if map_ref.has_node("Fader"):
		map_ref.fader.play_backwards("fade")
		await map_ref.fader.animation_finished
	else:
		print("no fader present in map")


func _on_body_entered(_body: Node2D) -> void:
	if !map_ref || !map_ref.has_method("get_previous_locale"):
		return

	await _wait_for_faders()

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
	get_tree().root.add_child(new_map)

	var new_player = new_map.find_child("OverworldPlayer")
	if new_player:
		new_player.global_position = locale.entrance_position
	map_ref.queue_free()


# subclasses
