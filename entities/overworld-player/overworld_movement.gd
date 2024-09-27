extends CharacterBody2D

# signals
signal on_enemy_hit(body: Node2D, on_advantage: bool)

const LEGACY_MULTIPLIER: float = 1.5

@export var speed: float = 5.0
@export var deferred_load: bool = false
@export var preserve_on_load: bool = false
## enables increased movement speed when moving diagonally
@export var use_legacy_movement: bool = true

@onready var sprite := get_node("Sprite2D") as Sprite2D
@onready var camera := $Camera2D as Camera2D


func _ready() -> void:
	pass


## physics process function that handles player movement,
## player facing the direction of movement, and collisions
func _physics_process(_delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")

	# if else statement to reintroduce bug from original version
	# where player moved faster when moving diagonally, fun
	if use_legacy_movement && (input_dir.x != 0.0 && input_dir.y != 0.0):
		velocity = input_dir * (speed * LEGACY_MULTIPLIER)
	else:
		velocity = input_dir * speed

	_flip_sprite(input_dir)
	var collision = move_and_collide(velocity)

	if collision:
		# get slide velocity and half it so that sliding along a wall is slower
		# just like in the original :)
		velocity = velocity.slide(collision.get_normal()) / 2.0
		move_and_collide(velocity)


## saves data as dictionary for JSON format
func save() -> Dictionary:
	return {
		"filename": get_scene_file_path(),
		"parent": get_parent().get_path(),
		"position_x": position.x,
		"position_y": position.y,
		"speed": speed,
		"flip_h": sprite.flip_h,
		"deferred_load": deferred_load,
		"preserve_on_load": preserve_on_load,
	}


## load data from JSON savefile
func load(data: Dictionary) -> void:
	deferred_load = data["deferred_load"]
	preserve_on_load = data["preserve_on_load"]
	global_position = Vector2(data["position_x"], data["position_y"])
	speed = data["speed"]
	sprite.flip_h = data["flip_h"]


## handles flipping horizontally the player sprite to face
## direction of movement
func _flip_sprite(input_dir: Vector2):
	if input_dir.x > 0:
		sprite.flip_h = false
	if input_dir.x < 0:
		sprite.flip_h = true
