extends Node2D


@onready var Bullet = preload("res://entities/bullet/bullet.tscn")


## bullet is spawned and initialized when shoot action
## is detected
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		# find the direction between the player and mouse position
		var bullet_dir = (get_global_mouse_position() - global_position).normalized()
		var bullet = Bullet.instantiate()
		# initialize the bullet
		bullet.init(global_position, bullet_dir, get_parent().name)
		# spawn the bullet as a child of the scene tree to prevent
		# player movement from affecting bullet movement
		get_tree().root.add_child(bullet)
