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
## direction the enemy wanders in
var _wander_dir: Vector2 = Vector2()
## how long the enemy will wander for
## in a particular direction
var _wander_time: float = 10.0

# @onready vars
# timers
@onready var bullet_delay_timer: Timer = $BulletDelayTimer
@onready var wander_timer: Timer = $WanderTimer

@onready var sprite: Sprite2D = $Sprite2D
@onready var bullet_emitter: Node2D = $BulletEmitter


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


## initializes bullet delay timer
func _ready() -> void:
	bullet_delay_timer.wait_time = shot_delay

	# initialize enemy wander mode
	if ai_state == AIState.WANDER:
		_on_wander_timer_timeout()


# remaining builtins e.g. _process, _input
## handles ai movement logic
func _physics_process(_delta: float) -> void:
	match(ai_state):
		AIState.WANDER:
			_wander_legacy()
		AIState.CHASE:
			_chase_target()


# public methods


# private methods
## orignal game's super advance wander functionality
func _wander_legacy() -> void:
	pass


## moves enemy in wander direction at half
## the normal speed
func _wander() -> void:
	_flip_sprite(_wander_dir)

	var vel: Vector2 = _wander_dir * (speed / 2.0)
	_move(vel)


## calculates target directions & moves towards the target
func _chase_target() -> void:
	if !target:
		return

	# calculate direction facing the target
	var dir_to_target: Vector2 = target.position - position
	dir_to_target = dir_to_target.normalized()
	_flip_sprite(dir_to_target)

	# move enemy towards target
	var vel: Vector2 = dir_to_target * speed
	_move(vel)


## if target i.e. the player has been detected,
## enemy begins to chase the target
func _on_target_detection_area_body_entered(body: Node2D) -> void:
	target = body
	bullet_delay_timer.start()
	ai_state = AIState.CHASE


## if target i.e. the player left the detection zone,
## enemy returns to wander state
func _on_target_detection_area_body_exited(_body: Node2D) -> void:
	target = null
	bullet_delay_timer.stop()
	ai_state = AIState.WANDER


## recalculates wander direction & time when
## [signal wander_timer.timeout] is emitted
func _on_wander_timer_timeout() -> void:
	_wander_dir = _get_new_wander_direction()
	_wander_time = randf_range(_wander_time - 5.0, _wander_time + 5.0)
	wander_timer.start(_wander_time)


## emit bullet towards target if target is available &
## enemy is in chase mode
func _on_bullet_delay_timer_timeout() -> void:
	if ai_state != AIState.CHASE || !target:
		return

	bullet_emitter.emit_bullet(target)
	bullet_delay_timer.start()


## gets random direction
func _get_new_wander_direction() -> Vector2:
	return Vector2(randf_range(-1.0, 2.0), randf_range(-1.0, 2.0)).normalized()


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
