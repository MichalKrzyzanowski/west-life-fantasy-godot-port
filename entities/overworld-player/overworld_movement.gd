extends CharacterBody2D

# signals
signal on_enemy_hit(body: Node2D, on_advantage: bool)

@export var speed: float = 5.0

var allow_movement: bool = true

@onready var sprite := get_node("Sprite2D") as Sprite2D
@onready var camp_menu := get_node("UI/CampMenu") as Control
@onready var camera := $Camera2D as Camera2D


func _ready() -> void:
	if !get_parent().has_node("Fader"):
		return

	var fader = get_parent().get_node("Fader")
	print("found fader")
	fader.animation_started.connect(_on_fade_begin)
	fader.animation_finished.connect(_on_fade_end)


## physics process function that handles player movement,
## player facing the direction of movement, and collisions
func _physics_process(_delta: float) -> void:
	if !allow_movement:
		return

	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed

	_flip_sprite(input_dir)
	var collision = move_and_collide(velocity)

	if collision:
		# get slide velocity and half it so that sliding along a wall is slower
		velocity = velocity.slide(collision.get_normal()) / 2.0
		move_and_collide(velocity)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = true
		camp_menu.show()


## saves data as dictionary for JSON format
func save() -> Dictionary:
	return {
		"filename": get_scene_file_path(),
		"parent": get_parent().get_path(),
		"position_x": position.x,
		"position_y": position.y,
		"speed": speed,
	}


## load data from JSON savefile
func load(data) -> void:
	position = Vector2(data["position_x"], data["position_y"])
	speed = data["speed"]


## handles flipping horizontally the player sprite to face
## direction of movement
func _flip_sprite(input_dir: Vector2):
	if input_dir.x > 0:
		sprite.flip_h = false
	if input_dir.x < 0:
		sprite.flip_h = true


func _on_fade_begin(_anim_name: String) -> void:
	allow_movement = false


func _on_fade_end(_anim_name: String) -> void:
	allow_movement = true
