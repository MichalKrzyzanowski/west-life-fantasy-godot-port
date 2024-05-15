# @tool
# class_name name
extends Control
# docstring


# signals

# enums

# constants

# @export vars

# public vars

# private vars

# @onready vars
@onready var gil_label := $Gil/Label as Label
@onready var options_menu := $OptionsMenu as Control
@onready var items_menu := $ConsumablesMenu as Control
@onready var armour_menu := $ArmourMenu as Control
@onready var weapon_menu := $WeaponMenu as Control

func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	update_gil()


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("exit_menu"):
		SaveManager.save_game(SaveManager.SAVE_FILE)
		hide()
		options_menu.hide()
		items_menu.hide()
		armour_menu.hide()
		weapon_menu.hide()
		get_tree().paused = false


# public methods
func update_gil() -> void:
	gil_label.text = "%d G" % PartyManager.gil


# private methods
func _on_items_pressed() -> void:
	items_menu.show()


# subclasses


func _on_weapons_pressed() -> void:
	weapon_menu.show()


func _on_armour_pressed() -> void:
	armour_menu.show()


func _on_options_pressed() -> void:
	options_menu.show()
