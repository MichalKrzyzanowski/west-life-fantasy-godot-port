extends Node
# docstring


# signals
signal on_gil_changed()

# enums

# constants

# @export vars

# public vars
var gil: int = 500:
	set(new_gil):
		gil = new_gil
		on_gil_changed.emit()
var party: Array[EntityProperties]

# private vars
var _debug_xp_gain: int = 1_000_000_000_000_000_000

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	add_to_group("persist")


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		match event.keycode:
			KEY_1:
				party.map(func (item): item.stats.xp += _debug_xp_gain)
				gil += 1000
			KEY_0:
				# party.all(func (item): print(item.stats))
				for member in party:
					print(member.name)
					print(member.stats)
					print("")


# public methods
## add member_data to party array
func add_member(entity_data: EntityProperties) -> void:
	entity_data.set_party_index(party.size())
	party.append(entity_data)


## get party member by [param index]
func get_member(index: int) -> EntityProperties:
	if index >= party.size():
		return null

	return party[index]


## check if party can afford buying something worth
## [param gil_cost]
func can_afford(gil_cost: int) -> bool:
	return gil - gil_cost >= 0


## spend [param gil_cost] of party gil
func spend_gil(gil_cost: int) -> void:
	gil -= gil_cost


func save() -> Dictionary:
	return {
		"name": name,
		"parent": get_parent().get_path(),
		"party_data": party.map(func(a): return a.save()),
		"gil": gil,
	}


func load(data: Dictionary) -> void:
	for item in data["party_data"]:
		var entity_props := EntityProperties.new()
		entity_props.stats = CombatStats.new()
		entity_props.load(item)
		add_member(entity_props)
	gil = data["gil"]


# private methods


# subclasses
