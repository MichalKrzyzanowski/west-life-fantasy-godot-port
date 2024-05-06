extends Node
# docstring


# signals

# enums

# constants

# @export vars

# public vars
var party: Array

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
				party.map(func (item): item.stats.xp += _debug_xp_gain)
			KEY_0:
				# party.all(func (item): print(item.stats))
				for member in party:
					print(member.name)
					print(member.stats)
					print("")


# public methods
## party append wrapper, adds [param entity] to [param party]
func add_member(entity) -> void:
	party.append(entity)


# private methods


# subclasses

