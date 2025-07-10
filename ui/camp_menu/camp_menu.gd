# @tool
# class_name name
extends Control
# docstring


# signals

# enums

# constants
const ORB_COLORS: Array[Color] = [
	Color.BLUE,
	Color.RED,
	Color(1.0, 0.5, 0.0),
	Color.BLACK,
]

# @export vars

# public vars

# private vars

# @onready vars
@onready var gold_label: Label = $Gold/Label
@onready var options_menu: Control = $OptionsMenu
@onready var items_menu: Control = $ConsumablesMenu
@onready var armour_menu: Control = $ArmourMenu
@onready var weapon_menu: Control = $WeaponMenu
@onready var orb_container: GridContainer = $Orbs/OrbContainer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


func _ready() -> void:
	update_gold()
	update_orbs()
	PartyManager.on_gold_changed.connect(update_gold)
	PartyManager.on_orbs_updated.connect(update_orbs)


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if visible && event.is_action_pressed("exit_menu"):
		print("exit menu")
		SaveManager.save_game(SaveManager.SAVE_FILE)
		GlobalSettings.save_ini()
		hide()
		options_menu.hide()
		items_menu.hide()
		armour_menu.hide()
		weapon_menu.hide()
		get_tree().paused = false


# public methods
func update_gold() -> void:
	gold_label.text = "%d G" % PartyManager.gold


func update_orbs() -> void:
	for i: int in PartyManager.orbs.size():
		if PartyManager.orbs[i]:
			orb_container.get_child(i).modulate = ORB_COLORS[i]


# private methods
func _on_items_pressed() -> void:
	audio_player.play()
	items_menu.show()


func _on_weapons_pressed() -> void:
	audio_player.play()
	weapon_menu.show()


func _on_armour_pressed() -> void:
	audio_player.play()
	armour_menu.show()


func _on_options_pressed() -> void:
	audio_player.play()
	options_menu.show()


# subclasses
