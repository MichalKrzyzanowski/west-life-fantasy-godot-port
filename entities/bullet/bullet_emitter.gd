extends Node2D

@export var allow_input: bool = true
@export_flags_2d_physics var bullet_collision_mask: int

@onready var Bullet: PackedScene = preload("res://entities/bullet/bullet.tscn")


## bullet is spawned and initialized when shoot action
## is detected
func _input(event: InputEvent) -> void:
	if allow_input && event.is_action_pressed("shoot"):
		emit_bullet()


## create instance of bullet, called when player/enemy shoots
func emit_bullet(target: Node2D = null) -> void:
	var target_position: Vector2
	# set target position to target's global_position if
	# it is not null
	if target:
		target_position = target.global_position
	 # else, target position is mouse global position
	else:
		target_position = get_global_mouse_position()

	# find the direction between the parent entity and target position
	var bullet_dir: Vector2 = (target_position - global_position).normalized()
	var bullet: Area2D = Bullet.instantiate()
	# initialize the bullet
	bullet.init(global_position, bullet_dir, get_parent())
	bullet.collision_mask = bullet_collision_mask
	# spawn the bullet as a child of the scene tree to prevent
	# player movement from affecting bullet movement
	get_tree().root.add_child(bullet)
