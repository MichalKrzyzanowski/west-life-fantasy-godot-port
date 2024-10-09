# @tool
# class_name name
extends HFlowContainer
# docstring


# signals

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
## horizontal and vertical seperation constants for inventory_grid
@export var inv_grid_h_seperation: int = 0
@export var inv_grid_v_seperation: int = 0
## scene to be used for displaying item data
@export var item_gui: PackedScene

# public vars
## reference to inventory dictionary that will be displayed
var item_dict: Dictionary

# private vars
var _first_page: int = 0
var _current_page: int = _first_page
var _previous_page: int = _current_page
var _page_count: int = _current_page

var _item_arr: Array


# @onready vars
@onready var inventory_grid: GridContainer = $Inv
@onready var scrollbar: VScrollBar = $VScrollBar


func _enter_tree() -> void:
	pass


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
		inventory_grid.add_child(gui)

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
## update gui inventory page count and scrollbar
func update_inventory() -> void:
	_page_count = ceili(item_dict.size() / (rows * columns * 1.0)) - 1
	scrollbar.max_value = _page_count
	_update_scrollbar_grabber_length()

	# update reference to item array from inventory dictionary
	_item_arr = item_dict.values()
	_update_item_gui()


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
			# inventory_grid.get_child(i).item = null
			continue

		# inventory_grid.get_child(i).item = _item_arr[_page_index(i)]
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


# subclasses
