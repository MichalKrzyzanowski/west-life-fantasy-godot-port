class_name CombatStats
extends Resource


signal leveled_up()
signal hp_changed()
signal xp_changed()

## max character hp, increased upon level up
@export var max_hp: float
## base character damage dealt during combat, increased upon level up
@export var attack: float
## base character defence, reduces damage taken during combat
@export var defence: float

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
@export_range(1, 99) var level: int
## xp the character drops upon death, mainly used for enemy entities
@export var xp_drop: int
## gold the character drops upon death, mainly used for enemy entities
@export var gold_drop: int

# current xp, used for leveling character up
var xp: int:
	set = set_xp

# current hp, character dies if hp reaches 0
var hp: float:
	set = set_hp

# xp required for the next level
var _required_xp: int = 100
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
	% [hp, max_hp, attack, level, xp, _required_xp]


## xp setter, checks if character can level up
## only update xp if level cap has not been reached
## emits [CombatStats.xp_changed]
func set_xp(new_xp: int) -> void:
	if level == _max_level:
		return
	xp = new_xp
	xp_changed.emit()
	print("new xp: %d" % xp)
	if (xp >= _required_xp):
		level_up()


## hp setter, emits [CombatStats.hp_changed]
func set_hp(new_hp: float) -> void:
	hp = new_hp
	hp_changed.emit()


## level up character by increasing:
## [param attack]
## [param max_hp]
## [param _required_xp]
## emits [CombatStats.leveled_up]
func level_up() -> void:
	# check if required xp will overflow, hard capping the level
	if _required_xp + (_required_xp / 100.0 * scaler_required_xp) < 0:
		_max_level = level
		_required_xp = 0
		xp = 0
		return
	leveled_up.emit()
	attack += scaler_attack
	max_hp += scaler_hp
	# fully heal character
	hp = max_hp

	level += 1
	# only update required xp if xp scaling is not 0
	if scaler_required_xp > 0:
		_required_xp += floor(_required_xp / 100.0 * scaler_required_xp)
	xp = 0


## saves data as dictionary for JSON format
func save() -> Dictionary:
	return {
		"hp": hp,
		"max_hp": max_hp,
		"level": level,
		"max_level": _max_level,
		"xp": xp,
		"required_xp": _required_xp,
		"attack": attack,
		"defence": defence,
	}


## load data from JSON savefile
func load(data) -> void:
	hp = data["hp"]
	max_hp = data["max_hp"]
	level = data["level"]
	_max_level = data["max_level"]
	xp = data["xp"]
	_required_xp = data["required_xp"]
	attack = data["attack"]
	defence = data["defence"]
