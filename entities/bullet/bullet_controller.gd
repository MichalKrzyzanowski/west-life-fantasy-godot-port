extends Area2D


const SPEED := 200.0
var direction := Vector2()
var bullet_owner := ""


func _physics_process(_delta: float) -> void:
	var velocity : Vector2 = direction * SPEED * _delta
	position += velocity


func init(spawn_pos: Vector2, bullet_direction : Vector2, shot_by : String) -> void:
	direction = bullet_direction
	position = spawn_pos
	bullet_owner = shot_by
	print("bullet spawned")
	print(direction)


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if "bullet_owner" in area:
		print(area.bullet_owner)
		if bullet_owner != area.bullet_owner:
			print("collided with enemy bullet")
			queue_free()


func _on_body_entered(body: Node2D) -> void:
	# this will be used to begin combat with player advantage/disadvantage
	# player's bullet hit the enemy or vice versa
	queue_free()
