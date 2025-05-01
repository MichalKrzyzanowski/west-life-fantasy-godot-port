# @tool
# class_name name
extends Panel
# docstring


# signals
signal on_item_clicked(item_id: int)

# enums
## enum class used by display options bitflags
enum ItemDisplayOptions {
	IS_EQUIPPED = 1 << 0,
	AMOUNT = 1 << 1,
	LEVEL = 1 << 2,
}

# constants

# @export vars
## sets which information is displayed e.g. amount, level, etc.
@export_flags("is_equipped", "amount", "level") var item_display_opt: int = 0
@export var default_name: String = "----"

# public vars
## item reference
var item: Item:
	set(new_item):
		item = new_item
		if item == null:
			_set_defaults()
			update_label_text()
			return

		_update_item_display()

		update_label_text()


# private vars
var _current_item_name: String = default_name

# @onready vars
@onready var button: Button = $Button


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


## initialize item display button
func _ready() -> void:
	_set_defaults()
	update_label_text()


# remaining builtins e.g. _process, _input


# public methods
func set_default_name(default: String) -> void:
	default_name = default


## updates button text with current item name
func update_label_text() -> void:
	button.text = _current_item_name


# private methods
## initializes name to default
func _set_defaults() -> void:
	_current_item_name = default_name


## wraps all update methods
func _update_item_display() -> void:
	_current_item_name = item.name.capitalize()

	# updates item name based on bitflags
	if item_display_opt & ItemDisplayOptions.IS_EQUIPPED:
		update_item_equip()
	if item_display_opt & ItemDisplayOptions.LEVEL:
		update_item_level()
	if item_display_opt & ItemDisplayOptions.AMOUNT:
		update_item_amount()


## emit [signal on_item_clicked] when button is pressed.
## signal is only sent if item is present
func _on_pressed() -> void:
	if !item:
		printerr("no item present, cannot send signal")
		return
	on_item_clicked.emit(item.id)


## add xN to item name if amount > 1 (e.g. name x4)
func update_item_amount() -> void:
	if item.amount > 1:
		_current_item_name += " x%d" % item.amount


## add E: characters to begining of item name if item is equipped.
## only applies for gear e.g. E:sword
func update_item_equip() -> void:
	if item is Gear && item.is_equipped:
		_current_item_name = "E:%s" % _current_item_name


## add + N to item name if level > 1 (e.g. name + 2)
func update_item_level() -> void:
	if item.stats.level > 1:
		_current_item_name = "%s + %d" % [
				_current_item_name,
				item.stats.level - 1
		]


# subclasses
