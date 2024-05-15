@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("Grid2D", "Node2D", preload("grid_2d.gd"), preload("icon.svg"))


func _exit_tree() -> void:
	remove_custom_type("Grid2D")
