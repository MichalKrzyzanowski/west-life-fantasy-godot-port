# @tool
# class_name name
extends PanelContainer
# docstring


# signals

# enums

# constants

# @export vars
## overworld player reference
@export var player_ref: CharacterBody2D

# public vars

# private vars

# @onready vars
@onready var subviewport: SubViewport = $SubViewportContainer/SubViewport
@onready var camera: Camera2D = $SubViewportContainer/SubViewport/Camera2D


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


## set world_2d object of minimap viewport to use main world_2d
func _ready() -> void:
	subviewport.world_2d = get_tree().root.world_2d

	# disable processing of minimap if player is not available
	if !player_ref:
		print("player not available, disabling minimap")
		disable_minimap()


# remaining builtins e.g. _process, _input

## minimap camera tracks global position of player
func _process(_delta: float) -> void:
	if player_ref:
		camera.global_position = player_ref.global_position


# public methods
## hides & disables processing of minimap
func disable_minimap() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED



# private methods


# subclasses
