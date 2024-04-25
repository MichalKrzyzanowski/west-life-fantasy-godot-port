extends Node2D


@onready var bullet_scene = preload("res://entities/bullet/bullet.tscn")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		var bullet_dir = (get_global_mouse_position() - global_position).normalized()
		var bullet = bullet_scene.instantiate()
		bullet.init(global_position, bullet_dir, get_parent().name)
		get_tree().root.add_child(bullet)
