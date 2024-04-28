extends CharacterBody2D


@export var speed := 5.0
@export var gil : int = 500

@onready var sprite := get_node("Sprite2D") as Sprite2D


## physics process function that handles player movement,
## player facing the direction of movement, and collisions
func _physics_process(_delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed

	_flip_sprite(input_dir)
	var collision = move_and_collide(velocity)
	if collision:
		# get slide velocity and half it so that sliding along a wall is slower
		velocity = velocity.slide(collision.get_normal()) / 2.0
		move_and_collide(velocity)


## handles flipping horizontally the player sprite to face
## direction of movement
func _flip_sprite(input_dir : Vector2):
	if input_dir.x > 0:
		sprite.flip_h = false
	if input_dir.x < 0:
		sprite.flip_h = true