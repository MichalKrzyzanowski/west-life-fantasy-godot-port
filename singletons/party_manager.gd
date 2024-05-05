extends Node
# docstring


# signals

# enums

# constants

# @export vars

# public vars
var party: Array

# private vars

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		match event.keycode:
			KEY_1:
				party.map(func (item): item.stats.xp += 14)
			KEY_0:
				party.all(func (item): print(item.stats))


# public methods


# private methods


# subclasses

