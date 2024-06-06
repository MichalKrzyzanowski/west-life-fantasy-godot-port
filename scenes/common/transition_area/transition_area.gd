# @tool
# class_name name
extends Area2D
# docstring


# signals

# enums

# constants

# @export vars
@export var shape: Shape2D
@export var texture: Texture

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
func _on_body_entered(body: Node2D) -> void:
	print("transition")


# subclasses
