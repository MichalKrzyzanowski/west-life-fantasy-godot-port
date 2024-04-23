extends CharacterBody2D

@export var speed := 5.0
@export var gil : int = 500

@onready var sprite := get_node("Sprite2D") as Sprite2D


func _process(_delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed

	_flip_sprite(input_dir)
	move_and_slide()


func _flip_sprite(input_dir : Vector2):
	if input_dir.x > 0:
		sprite.flip_h = false
	if input_dir.x < 0:
		sprite.flip_h = true
