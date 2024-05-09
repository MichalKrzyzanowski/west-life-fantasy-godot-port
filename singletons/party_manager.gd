extends Node
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars
var _debug_xp_gain: int = 1_000_000_000_000_000_000

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
				get_children().map(func (item): item.stats.xp += _debug_xp_gain)
			KEY_0:
				# party.all(func (item): print(item.stats))
				for member in get_children():
					print(member.name)
					print(member.stats)
					print("")


# public methods
## add_child wrapper, also adds [param entity] to persist group
func add_member(entity) -> void:
	add_child(entity)
	entity.add_to_group("persist")


# private methods


# subclasses

