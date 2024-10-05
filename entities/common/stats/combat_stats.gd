class_name CombatStats
extends Resource


signal on_level_up()
signal on_hp_changed()
signal on_xp_changed()
signal on_hp_depleted()

## max character hp, increased upon level up
@export var max_hp: int:
	set(new_max_hp):
		max_hp = new_max_hp
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

## character level
@export var level: int = 1
## xp the character drops upon death, mainly used for enemy entities
@export var xp_drop: int
## gold the character drops upon death, mainly used for enemy entities
@export var gil_drop: int

# current xp, used for leveling character up
var xp: int:
	set = set_xp

# current hp, character dies if hp reaches 0
var hp: float:
	set = set_hp

# xp required for the next level
var required_xp: int = 100

var has_hp_depleted: bool = false

# defence multiplier, used for blocking
var defence_multiplier: int = 1

# max level
var _max_level: int = 9999


## stats initializer
func init() -> void:
	# TODO: update to _init after godot engine changes
	print("init stats")
	# fully heals character
	hp = max_hp


## convert stats object to string
func _to_string() -> String:
	return "%d/%dhp\n%ddmg\nlvl:%d\n%d/%dxp" \
	% [hp, max_hp, attack, level, xp, required_xp]


## xp setter, checks if character can level up
## only update xp if level cap has not been reached
## emits [CombatStats.on_xp_changed]
func set_xp(new_xp: int) -> void:
	if has_hp_depleted:
		return

	if level == _max_level:
		return

	xp = max(0, new_xp)
	on_xp_changed.emit()
	print("new xp: %d" % xp)
	if (xp >= required_xp):
		level_up()


## hp setter, emits [CombatStats.on_hp_changed]
func set_hp(new_hp: float) -> void:
	if has_hp_depleted:
		return

	hp = clamp(new_hp, 0, max_hp)
	on_hp_changed.emit()
	if hp == 0:
		has_hp_depleted = true
		on_hp_depleted.emit()


## level up character by increasing:
## [param attack]
## [param max_hp]
## [param required_xp]
## emits [CombatStats.on_level_up]
func level_up() -> void:
	# check if required xp will overflow, hard capping the level
	if required_xp + (required_xp / 100.0 * scaler_required_xp) < 0:
		_max_level = level
		required_xp = 0
		xp = 0
		return
	attack += scaler_attack
	max_hp += scaler_hp

	level += 1
	# only update required xp if xp scaling is not 0
	if scaler_required_xp > 0:
		required_xp += floor(required_xp / 100.0 * scaler_required_xp)
	xp = 0
	on_level_up.emit()


## saves data as dictionary for JSON format
func save() -> Dictionary:
	return {
		"max_hp": max_hp,
		"hp": hp,
		"level": level,
		"max_level": _max_level,
		"required_xp": required_xp,
		"xp": xp,
		"attack": attack,
		"defence": defence,
	}


## load data from JSON savefile
func load(data: Dictionary) -> void:
	# TODO: convert this mess into a list
	if data.has("max_hp"):
		max_hp = data["max_hp"]
	if data.has("hp"):
		hp = data["hp"]
	if data.has("level"):
		level = data["level"]
	if data.has("max_level"):
		_max_level = data["max_level"]
	if data.has("required_xp"):
		required_xp = data["required_xp"]
	if data.has("xp"):
		xp = data["xp"]
	if data.has("attack"):
		attack = data["attack"]
	if data.has("defence"):
		defence = data["defence"]
