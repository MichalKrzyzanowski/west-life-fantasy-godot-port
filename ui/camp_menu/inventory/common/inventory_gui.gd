# @tool
# class_name name
extends HFlowContainer
# docstring


# signals
## emitted when item is clicked
signal on_item_gui_clicked(inventory: Inventory, item_id: int)

# enums

# constants

# @export vars
## max rows in gui inventory
@export var rows: int = 1
## max columns in gui inventory
@export var columns: int = 1
## hides the scrollbar
@export var hide_scrollbar: bool = false
## disables scrolling
@export var disable_scrolling: bool = false
## horizontal aseperation constant for inventory_grid
@export var inv_grid_h_seperation: int = 0
## vertical seperation constant for inventory_grid
@export var inv_grid_v_seperation: int = 0
## scene to be used for displaying item data
@export var item_gui: PackedScene
## when true, clicked items call its use method
## which usely means the item will be consumed on use
@export var enable_item_use_action: bool = true
## party reference
@export var party: Array[EntityProperties]

# public vars
## reference to inventory object that will be displayed
var inventory: Inventory
## item filter, inventory will only display items that pass this filter
var item_filter: String = ""

# private vars
## inventory page vars
var _first_page: int = 0
var _current_page: int = _first_page
var _previous_page: int = _current_page
var _page_count: int = _current_page

## inventory array as extracted from [class Inventory] dictionary
var _item_arr: Array

# @onready vars
@onready var inventory_grid: GridContainer = $ItemGrid
@onready var scrollbar: VScrollBar = $VScrollBar


# func _enter_tree() -> void:
# 	pass


## initialize item grid and applies scrollbar setting.
## instantiate scenes used for displaying item info
func _ready() -> void:
	assert(item_gui, "item_gui is null")

	if hide_scrollbar:
		_disable_scrollbar()

	# set gui inventory seperation constants
	inventory_grid.add_theme_constant_override("h_separation", inv_grid_h_seperation)
	inventory_grid.add_theme_constant_override("v_separation", inv_grid_v_seperation)

	# generate rows * columns gui items
	inventory_grid.columns = columns
	var gui_amount: int = rows * columns
	for i: int in gui_amount:
		var gui: Control  = item_gui.instantiate()
		gui.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		inventory_grid.add_child(gui)
		gui.connect("on_item_clicked", _on_item_clicked)

	_init_scrollbar()


# remaining builtins e.g. _process, _input
## gui inventory input. mainly handles scrolling.
## only scroll when mouse cursor is intersecting gui inventory rect
func _input(event: InputEvent) -> void:
	if !_is_inventory_highlighted():
		return

	if event.is_action_released("inventory_scroll_up"):
		_change_page(-1)
	elif event.is_action_released("inventory_scroll_down"):
		_change_page(1)


# public methods
## sets inventory reference and updates inventory
func set_inventory(new_inventory: Inventory, party_ref: Array[EntityProperties] = []) -> void:
	# disconnect on_inventory_update signal if already connected
	# mainly used when changing inventories often
	if inventory && inventory.is_connected("on_inventory_update", _on_inventory_update):
		inventory.disconnect("on_inventory_update", _on_inventory_update)

	inventory = new_inventory
	inventory.set_party_ref(party_ref)
	inventory.on_inventory_update.connect(_on_inventory_update)

	update_inventory()


## update gui inventory page count and scrollbar
func update_inventory() -> void:
	_page_count = ceili(inventory.size() / (rows * columns * 1.0)) - 1
	scrollbar.max_value = _page_count
	_update_scrollbar_grabber_length()

	# update reference to item array from inventory dictionary
	_item_arr = get_inventory_items(item_filter)
	_update_item_gui()


## item_filter setter
func set_item_filter(filter: String) -> void:
	item_filter = filter


## fetch inventory items as array.
## items can be filtered by [param item_type]
func get_inventory_items(item_type: String = "") -> Array:
	if !item_type:
		return inventory.values()
	var filter_lambda: Callable = func(item: Item) -> bool: return item.type == item_type
	return inventory.values().filter(filter_lambda)


## fetch gui inventory children
func get_gui_items() -> Array[Node]:
	return inventory_grid.get_children()


# private methods
## disable scrollbar
func _disable_scrollbar() -> void:
	scrollbar.hide()
	inventory_grid.set_anchors_preset(LayoutPreset.PRESET_FULL_RECT, true)


## initialize scrollbar values (min/max_value, value)
func _init_scrollbar() -> void:
	scrollbar.min_value = _first_page
	scrollbar.max_value = _page_count
	scrollbar.set_value_no_signal(_current_page)
	if disable_scrolling:
		scrollbar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_process_input(false)


## update height of scrollbar grabber based on gui inventory page count
## and minimum size
func _update_scrollbar_grabber_length() -> void:
	var grab: StyleBox = scrollbar.get_theme_stylebox("grabber")
	grab.content_margin_bottom = inventory_grid.get_combined_minimum_size().y / (_page_count + 1)


## update currently-displayed items guis with new item resources
## based on current page
func _update_item_gui() -> void:
	for i: int in inventory_grid.get_child_count():
		var gui_item: Node = inventory_grid.get_child(i)
		if _page_index(i) >= _item_arr.size():
			_set_gui_item_resource(gui_item, null)
			continue

		_set_gui_item_resource(gui_item, _item_arr[_page_index(i)])


## set item property of gui_item, if it exists
func _set_gui_item_resource(gui_item: Node, item: Item) -> void:
	if "item" not in gui_item:
		print('property "item" not found in "gui_item"')
		return
	gui_item.item = item


## change current page by amount
func _change_page(amount: int) -> void:
	_set_page(_current_page + amount)


## set current page to page.
## clamped between first page and page count
func _set_page(page: float) -> void:
	_current_page = clampi(roundi(page), _first_page, _page_count)
	scrollbar.set_value_no_signal(_current_page)

	# if current page has changed, update item gui
	if _current_page != _previous_page:
		_update_item_gui()
		_previous_page = _current_page


## calculate gui inventory index based on
## current page, rows, and columns
func _page_index(index: int) -> int:
	return index + (_current_page * rows * columns)


## check if gui inventory rect is intersected by the mouse pointer
func _is_inventory_highlighted() -> bool:
	var grid_pos: Vector2 = inventory_grid.global_position
	var grid_size: Vector2 = inventory_grid.get_combined_minimum_size()
	grid_size.x = get_rect().size.x

	var grid_rect: Rect2 = Rect2(grid_pos, grid_size)
	var mouse_position: Vector2 = get_viewport().get_mouse_position()

	return grid_rect.has_point(mouse_position)


## handles item click event.
## if [member enable_item_use_action] is true,
## this method emits a signal to allow other classes to
## have custom item use implementations.
## otherwise, this method calls [method inventory.use_item]
func _on_item_clicked(item_id: int) -> void:
	if !inventory.has_item(item_id):
		printerr("no item found with id %d" % item_id)
		return

	if !enable_item_use_action:
		on_item_gui_clicked.emit(inventory, item_id)
		return

	inventory.use_item(item_id)
	update_inventory()


## called when [signal Inventory.on_inventory_update] is emitted
func _on_inventory_update() -> void:
	update_inventory()


# subclasses
