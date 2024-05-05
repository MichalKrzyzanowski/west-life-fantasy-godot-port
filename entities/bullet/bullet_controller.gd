extends Area2D


const SPEED: float = 200.0
var direction := Vector2()
var bullet_owner: String = ""


## handles bullet movement
func _physics_process(delta: float) -> void:
	var velocity : Vector2 = direction * SPEED * delta
	position += velocity


## bullet initializer.
##
## param [spawn_pos]: position where to spawn bullet
## param [bullet_direction]: direction the bullet should move towards
## param [shot_by]: entity that shot the bullet, will be used on detecting
## player bullet to enemy bullet collisions
func init(spawn_pos: Vector2, bullet_direction: Vector2, shot_by: String) -> void:
	direction = bullet_direction
	position = spawn_pos
	bullet_owner = shot_by
	print("bullet spawned")
	print(direction)


## destroys bullet once it runs out of time
func _on_timer_timeout() -> void:
	queue_free()


## handles collisions with other bullets
func _on_area_entered(area: Area2D) -> void:
	if "bullet_owner" in area:
		print(area.bullet_owner)
		if bullet_owner != area.bullet_owner:
			print("collided with enemy bullet")
			queue_free()


## handles bullet collisions with non-bullet entities
## will be used in the future to determine combat advantage
func _on_body_entered(_body: Node2D) -> void:
	# this will be used to begin combat with player advantage/disadvantage
	# player's bullet hit the enemy or vice versa
	queue_free()
