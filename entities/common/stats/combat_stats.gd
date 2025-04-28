class_name CombatStats
extends Resource
# docstring


# signals
signal on_level_up()
signal on_hp_changed()
signal on_xp_changed()
signal on_hp_depleted()

# constants
## dictionary of parameters to be loaded in a specific order.
## format: param: property_name
const PARAMETERS_LOAD_ORDER: Dictionary = {
		"level": "level",
		"max_level": "max_level",
		"required_xp": "required_xp",
		"xp": "xp",
		"attack": "attack",
		"scaler_attack": "scaler_attack",
		"defence": "defence",
		"scaler_defence": "scaler_defence",
		"allow_hp_overlimit": "config_allow_hp_overlimit",
		"restore_hp": "config_restore_hp",
		"max_hp": "max_hp",
		"hp": "hp",
		"scaler_hp": "scaler_hp",
		"gil_level_cost": "gil_level_cost",
		"gil_value": "gil_value",
	}

# export vars
## max character hp, increased upon level up
@export var max_hp: int:
	set(new_max_hp):
		max_hp = new_max_hp
		if config_restore_hp:
			hp = max_hp
## base character damage dealt during combat, increased upon level up
@export var attack: int
## base character defence, reduces damage taken during combat
@export var defence: int

@export_group("Stat Scaling", "scaler_")
## hp scaling factor, additive
@export var scaler_hp: int
## hp scaling factor, additive
@export var scaler_attack: int
## hp scaling factor, additive
@export var scaler_defence: int
## hp scaling factor, multiplicative
@export var scaler_required_xp: int

@export_group("Config", "config_")
## allows hp to overflow max hp
@export var config_allow_hp_overlimit: bool = false
## allows hp to be fully restored when max hp is altered.
## e.g. when leveling up, using an item that increases
## max hp only
@export var config_restore_hp: bool = true

@export var extra_level_up_gains: Dictionary

## level
@export var level: int = 1
## max level
@export var max_level: int = 9999
# current hp, character dies if hp reaches 0
@export_storage var hp: int = max_hp:
	set = set_hp
## xp the character drops upon death, mainly used for enemy entities
@export var xp_drop: int
## gold the character drops upon death, mainly used for enemy entities
@export var gil_drop: int
## gil value of the entity/item, mainly used for selling/buying items
@export var gil_value: int
## cost to level up, optional. mainly used for gear upgrading
@export var gil_level_cost: int = 25

# current xp, used for leveling character up
var xp: int:
	set = set_xp

# xp required for the next level
var required_xp: int = 100

# defence multiplier, used for blocking
var defence_multiplier: int = 1



## stats initializer
func init(reset_default_stats: bool = false) -> void:
	# TODO: update to _init after godot engine changes
	print("init stats")
	# set stat value to 0 of stats that have non 0 defaults e.g. max_level.
	# mainly used for items and extra level up gains that requires all stats to be 0
	# except explicitly set stats
	if reset_default_stats:
		max_level = 0
		required_xp = 0


## convert stats object to string
func _to_string() -> String:
	return "%d/%dhp\n%ddmg\nlvl:%d\nmax lvl:%d\n%d/%dxp" \
	% [hp, max_hp, attack, level, max_level, xp, required_xp]


## xp setter, checks if character can level up
## only update xp if level cap has not been reached
## emits [CombatStats.on_xp_changed]
func set_xp(new_xp: int) -> void:
	if hp < 1:
		return

	if has_reached_max_level():
		return

	xp = max(0, new_xp)
	on_xp_changed.emit()
	print("new xp: %d" % xp)
	if (xp >= required_xp):
		level_up()


## hp setter, emits [CombatStats.on_hp_changed]
func set_hp(new_hp: int) -> void:

	if config_allow_hp_overlimit:
		hp = new_hp
	else:
		hp = clamp(new_hp, 0, max_hp)

	on_hp_changed.emit()
	if hp == 0:
		on_hp_depleted.emit()


## level up character by increasing:
## [param attack]
## [param max_hp]
## [param required_xp]
## emits [CombatStats.on_level_up]
func level_up() -> void:
	# check if required xp will overflow, hard capping the level
	if required_xp + (required_xp / 100.0 * scaler_required_xp) < 0:
		max_level = level
		required_xp = 0
		xp = 0
		return

	level += 1
	if extra_level_up_gains.has(level):
		print("extra level up gains at level %d" % level)
		add(extra_level_up_gains[level])
	attack += scaler_attack
	max_hp += scaler_hp

	# only update required xp if xp scaling is not 0
	if scaler_required_xp > 0:
		required_xp += floor(required_xp / 100.0 * scaler_required_xp)
	xp = 0
	on_level_up.emit()


## addition method, since gdscript does not
## support operator overloading
func add(stats: CombatStats) -> void:
	hp += stats.hp
	scaler_hp += stats.scaler_hp
	if stats.max_hp > 0:
		max_hp += stats.max_hp
	attack += stats.attack
	scaler_attack += stats.scaler_attack
	defence += stats.defence
	scaler_defence += stats.scaler_defence
	xp += stats.xp
	gil_level_cost += stats.gil_level_cost
	max_level += stats.max_level


## has entity/item reached max level
func has_reached_max_level() -> bool:
	return level == max_level


## saves data as dictionary for JSON format
func save() -> Dictionary:
	var dict: Dictionary = {
		"max_hp": max_hp,
		"hp": hp,
		"scaler_hp": scaler_hp,
		"level": level,
		"max_level": max_level,
		"required_xp": required_xp,
		"xp": xp,
		"attack": attack,
		"scaler_attack": scaler_attack,
		"defence": defence,
		"scaler_defence": scaler_defence,
		"allow_hp_overlimit": config_allow_hp_overlimit,
		"restore_hp": config_restore_hp,
		"gil_level_cost": gil_level_cost,
		"gil_value": gil_value,
	}

	# convert value of extra_level_up_gains dict to dict format
	var gains_dict: Dictionary = {}
	for key: int in extra_level_up_gains:
		gains_dict[key] = extra_level_up_gains[key].save()

	dict["extra_level_up_gains"] = gains_dict

	return dict


## load data from JSON savefile
func load(data: Dictionary) -> void:
	for param: String in PARAMETERS_LOAD_ORDER.keys():
		if data.has(param):
			set(PARAMETERS_LOAD_ORDER[param], data[param])

	# setup extra level up gains
	if data.has("extra_level_up_gains"):
		load_extra_level_up_gains(data["extra_level_up_gains"])


func load_extra_level_up_gains(data: Dictionary) -> void:
	for key: String in data.keys():
		var stats: CombatStats = CombatStats.new()
		stats.init(true)
		stats.gil_level_cost = 0
		stats.load(data[key])
		extra_level_up_gains[key.to_int()] = stats
