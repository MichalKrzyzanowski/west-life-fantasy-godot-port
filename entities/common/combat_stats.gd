class_name CombatStats
extends Resource


signal leveled_up()
signal hp_changed()
signal xp_changed()

@export var max_hp: float
@export var attack: float
@export var defence: float

@export var hp_scaler: int
@export var attack_scaler: int
@export var defence_scaler: int

@export var required_xp_scaler: int
@export var level: int = 1
## xp the character drops upon death, mainly used for enemy entities
@export var xp_drop: int

## current xp, used for leveling character up
var xp: int = 0:
	set = set_xp

var hp: float:
	set = set_hp

var _required_xp: int = 100


func _init() -> void:
	hp = max_hp


func set_xp(new_xp: int) -> void:
	xp = new_xp
	print("new xp: %d" % xp)
	if (xp >= _required_xp):
		leveled_up.emit()
		level_up()


func set_hp(new_hp: float) -> void:
	hp = new_hp
	hp_changed.emit()


func level_up() -> void:
	attack += attack_scaler
	max_hp += hp_scaler
	hp = max_hp

	xp -= _required_xp 
	_required_xp += floor(_required_xp * 100.0 / required_xp_scaler)
