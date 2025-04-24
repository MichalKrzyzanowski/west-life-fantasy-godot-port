@tool
# class_name name
extends Area2D
# docstring


# signals

# enums

# constants

# @export vars
@export var shape: Shape2D:
	set(new_shape):
		shape = new_shape
		if collision_shape:
			collision_shape.shape = shape

@export var shop_ref: Control

# public vars

# private vars
var fader: AnimationPlayer

# @onready vars
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	collision_shape.shape = shape

	if !Engine.is_editor_hint():
		fader = get_node(MainUtils.FADER_PATH)

		if !shop_ref:
			printerr("shop reference is null")
			return

		if !shop_ref.has_signal("on_exit"):
			printerr("invalid shop reference")
			return

		shop_ref.on_exit.connect(_exit_shop)


# remaining builtins e.g. _process, _input


# public methods


# private methods
func _enter_shop() -> void:
	fader.keep_paused = true
	fader.play_backwards("fade")
	await fader.animation_finished
	shop_ref.show()


func _exit_shop() -> void:
	fader.keep_paused = false
	shop_ref.hide()
	fader.play("fade")


# subclasses
