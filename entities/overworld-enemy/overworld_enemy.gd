# @tool
# class_name name
extends CharacterBody2D
# docstring


# signals

# enums
## behaviour states of the enemy
enum AIState {
	WANDER, ## enemy picks random direction and moves towards it
	CHASE, ## enemy moves towards target while shooting periodically
}

# constants

# @export vars
## movement speed
@export var speed: float = 0.5
## time to wait before shooting
@export var shot_delay: float = 1.0

# public vars
## target to chase
var target: Node2D = null
## current ai behaviour state
var ai_state: AIState = AIState.WANDER

# private vars

# @onready vars
@onready var bullet_delay_timer: Timer = $BulletDelayTimer
@onready var sprite: Sprite2D = $Sprite2D


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


## initializes bullet delay timer
func _ready() -> void:
	bullet_delay_timer.wait_time = shot_delay


# remaining builtins e.g. _process, _input
func _physics_process(_delta: float) -> void:
	match(ai_state):
		AIState.WANDER:
			_wander()
		AIState.CHASE:
			_chase_target()


# public methods


# private methods
func _wander() -> void:
	pass


## calculates target directions & moves towards the target
func _chase_target() -> void:
	if !target:
		return

	# calculate direction facing the target
	var dir_to_target: Vector2 = target.position - position
	dir_to_target = dir_to_target.normalized()
	_flip_sprite(dir_to_target)

	# move enemy towards target
	var velocity: Vector2 = dir_to_target * speed
	_move(velocity)


## if target i.e. the player has been detected,
## enemy begins to chase the target
func _on_target_detection_area_body_entered(body: Node2D) -> void:
	target = body
	ai_state = AIState.CHASE


## if target i.e. the player left the detection zone,
## enemy returns to wander state
func _on_target_detection_area_body_exited(body: Node2D) -> void:
	target = null
	ai_state = AIState.WANDER


## moves the enemy using param [param vel]
func _move(vel: Vector2) -> void:
	var collision: KinematicCollision2D = move_and_collide(vel)

	if collision:
		# get slide velocity and half it so that sliding along a wall is slower
		# just like in the original :)
		velocity = velocity.slide(collision.get_normal()) / 2.0
		move_and_collide(velocity)


## handles flipping horizontally the player sprite to face
## [param direction] of movement
func _flip_sprite(direction: Vector2) -> void:
	if direction.x > 0:
		sprite.flip_h = true
	if direction.x < 0:
		sprite.flip_h = false


# subclasses
