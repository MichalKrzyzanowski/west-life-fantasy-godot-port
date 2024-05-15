@tool
extends Node2D
## A container that arranges its child Node2Ds in a grid layout


# signals

# enums
enum SortBy {
	COLS,
	ROWS,
}

# constants

# @export vars
@export var columns: int = 1:
	set(new_columns):
		columns = new_columns
		_position_children()

@export var rows: int = 1:
	set(new_rows):
		rows = new_rows
		_position_children()

@export var v_seperation: int:
	set(new_v_sep):
		v_seperation = new_v_sep
		_position_children()

@export var h_seperation: int:
	set(new_h_sep):
		h_seperation = new_h_sep
		_position_children()

@export var sort_by: SortBy:
	set(new_sort_by):
		sort_by = new_sort_by
		_position_children()

# public vars

# private vars
var _is_ready: bool = false

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	_position_children()
	_is_ready = true


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		match event.keycode:
			KEY_A:
				var node = Sprite2D.new()
				node.texture = load("res://entities/party-members/fallback/fallback.png")
				add_child(node)
			KEY_D:
				if get_child_count() > 0:
					var node = get_child(0)
					remove_child(node)
					node.queue_free()


# public methods


# private methods
func _position_children() -> void:
	var children: Array = get_children()
	if children.is_empty():
		return

	match sort_by:
		SortBy.COLS:
			_by_columns(children)
		SortBy.ROWS:
			_by_rows(children)


func _by_columns(children: Array) -> void:
	if columns < 1:
		return

	var col: int = 0
	var row: int = 0

	for i in children.size():
		children[i].position = Vector2(
				col * h_seperation,
				row * v_seperation)
		col += 1

		if col == columns:
			col = 0
			row += 1


func _by_rows(children: Array) -> void:
	if rows < 1:
		return

	var col: int = 0
	var row: int = 0

	for i in children.size():
		children[i].position = Vector2(
				row * h_seperation,
				col * v_seperation)
		col += 1

		if col == rows:
			col = 0
			row += 1


func _on_child_order_changed() -> void:
	if _is_ready:
		_position_children()


# subclasses
