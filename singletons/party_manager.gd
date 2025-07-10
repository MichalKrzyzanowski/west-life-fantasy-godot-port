extends Node
# docstring


# signals
signal on_gold_changed()
signal on_orbs_updated()

# enums

# constants

# @export vars

# public vars
var gold: int = 500:
	set(new_gold):
		gold = new_gold
		on_gold_changed.emit()
var party: Array[EntityProperties]
## list of bools denoting if any of the four orbs are obtained
var orbs: Array[bool] = [false, false, false, false]

# private vars

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	add_to_group("persist")


# remaining builtins e.g. _process, _input


# public methods
## de initializes party manager
func deinit() -> void:
	party.clear()


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
## [param gold_cost]
func can_afford(gold_cost: int) -> bool:
	return gold - gold_cost >= 0


## spend [param gold_cost] of party gold
func spend_gold(gold_cost: int) -> void:
	gold -= gold_cost


## sets [param value] to orb state at [param index].
## emits [signal on_orbs_updated]
func update_orb(index: int, value: bool) -> void:
	orbs.set(index, value)
	on_orbs_updated.emit()


func save() -> Dictionary:
	return {
		"name": name,
		"parent": get_parent().get_path(),
		"party_data": party.map(func(a): return a.save()),
		"orbs": orbs,
		"gold": gold,
	}


func load(data: Dictionary) -> void:
	for item in data["party_data"]:
		var entity_props: EntityProperties = EntityProperties.new()
		entity_props.stats = CombatStats.new()
		entity_props.load(item)
		add_member(entity_props)
	orbs.assign(data["orbs"])
	gold = data["gold"]


# private methods


# subclasses
