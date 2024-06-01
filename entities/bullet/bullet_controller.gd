extends Area2D


const SPEED: float = 200.0
var direction := Vector2()
var bullet_owner: Node2D


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
func init(spawn_pos: Vector2, bullet_direction: Vector2, shot_by: Node2D) -> void:
	direction = bullet_direction
	position = spawn_pos
	bullet_owner = shot_by
	print("bullet spawned")
	print(direction)
	add_to_group("bullet")


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
func _on_body_entered(body: Node2D) -> void:
	# this will be used to begin combat with player advantage/disadvantage
	# player's bullet hit the enemy or vice versa
	print("owner: %s, target: %s" % [bullet_owner.name, body.name])
	var player: Node2D
	var enemy: Node2D
	var player_advantage: bool = true

	# player bullet shot enemy
	if "player" in bullet_owner.name.to_lower():
		player = bullet_owner
		# set the other node as a theoretical enemy
		enemy = body
	else:
		# player has been shot
		player = body
		# set the other node as a theoretical enemy
		enemy = bullet_owner
		player_advantage = false

	# if enemy or player is not present, return
	if (
			!"enemy" in enemy.name.to_lower()
			|| !"player" in player.name.to_lower()
	):
		print("enemy or player not present")
		queue_free()
		return

	player.on_enemy_hit.emit(enemy, player_advantage)

