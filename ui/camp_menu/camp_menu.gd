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
@onready var gil_label := get_node("Gil/Label") as Label
@onready var options_menu := get_node("OptionsMenu") as Control
@onready var items_menu := get_node("ConsumablesMenu") as Control
@onready var armour_menu := get_node("ArmourMenu") as Control

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
		get_tree().paused = false


# public methods
func update_gil() -> void:
	gil_label.text = "%d G" % PartyManager.gil


# private methods
func _on_items_pressed() -> void:
	items_menu.show()


# subclasses


func _on_weapons_pressed() -> void:
	pass # Replace with function body.


func _on_armour_pressed() -> void:
	armour_menu.show()


func _on_options_pressed() -> void:
	options_menu.show()
