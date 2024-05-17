@tool
extends Node2D
## A container that arranges its child Node2Ds in a grid layout


# signals

# enums
## used to define grid sorting options
enum SortBy {
	COLS,
	ROWS,
}

# constants

# @export vars
## max columns in the grid.
## applies only if [param sort_by] is set to COLS
@export var columns: int = 1:
	set(new_columns):
		columns = new_columns
		_auto_update_grid()

## max rows in the grid.
## applies only if [param sort_by] is set to ROWS
@export var rows: int = 1:
	set(new_rows):
		rows = new_rows
		_auto_update_grid()

## horizontal seperation.
## governs the horizontal gap in between grid items
@export var h_seperation: int:
	set(new_h_sep):
		h_seperation = new_h_sep
		_auto_update_grid()

## veritcal seperation.
## governs the vertical gap in between grid items
@export var v_seperation: int:
	set(new_v_sep):
		v_seperation = new_v_sep
		_auto_update_grid()

## governs how grid items are positioned.
## COLS: positions grid items left -> right
## move down to next row if [param columns] reached
## ROWS: positions grid items top -> botton
## move down to next column if [param rows] reached
@export var sort_by: SortBy:
	set(new_sort_by):
		sort_by = new_sort_by
		_auto_update_grid()

## prevent the grid from updating.
## can be set to true during gameplay if
## you need to remove grid objects
## without modifying their position.
## could also be used for manually calling
## [method Grid2D._auto_update_grid]
@export var do_not_update: bool = false:
	set(new_do_not_update):
		do_not_update = new_do_not_update
		if (!do_not_update):
			_auto_update_grid()

# public vars

# private vars

# @onready vars


func _init() -> void:
	pass


## connect child_order_changed signal when grid node enters tree
func _enter_tree() -> void:
	connect("child_order_changed", _on_child_order_changed)


func _ready() -> void:
	pass


# remaining builtins e.g. _process, _input


# public methods


# private methods
## updates grid children
## only run when [param do_not_update] is true
func _auto_update_grid() -> void:
	if do_not_update:
		return

	update_grid()


## selects correct positioning function to use
## based on [param sort_by].
## returns if [param do_not_update] is true
## or there are no children attached to the grid.
func update_grid() -> void:
	# return if no children
	var children: Array = get_children()
	if children.is_empty():
		return

	# use positioning algorithm chosen by user
	match sort_by:
		SortBy.COLS:
			_by_columns(children)
		SortBy.ROWS:
			_by_rows(children)


## positions grid [param children] in left -> right order.
## once [param column] is reached, move onto next row
func _by_columns(children: Array) -> void:
	# return if columns invalid
	if columns < 1:
		return

	# initialize col, rows indices
	var col: int = 0
	var row: int = 0

	# position children
	for i in children.size():
		children[i].position = Vector2(
				col * h_seperation,
				row * v_seperation
		)
		col += 1

		# move to next row
		if col == columns:
			col = 0
			row += 1


## positions grid [param children] in top -> bottom order.
## once [param rows] is reached, move onto next column
func _by_rows(children: Array) -> void:
	# return if rows invalid
	if rows < 1:
		return

	# initialize col, rows indices
	var col: int = 0
	var row: int = 0

	# position children
	for i in children.size():
		children[i].position = Vector2(
				col * h_seperation,
				row * v_seperation
		)
		row += 1

		# move to column row
		if row == rows:
			col += 1
			row = 0


## update children positions when children are
## removed, shuffled, or added
func _on_child_order_changed() -> void:
	print("child changed")
	await get_tree().process_frame
	_auto_update_grid()


# subclasses
