@tool
# class_name name
extends Area2D
# docstring


# signals

# enums

# constants

# @export vars
## shape of triggerzone
@export var shape: Shape2D:
	set(new_shape):
		shape = new_shape
		if collision_shape:
			collision_shape.shape = shape

## list of entities and order of spawn in combat
@export var entities: Array[EntityProperties]
## enables/disables combat start on entering the triggerzone
@export var disabled: bool = true
## automatically begins tracking of quest
@export var track_quest: bool = false
## enables static collider which prevents player from passing through
## the triggerzone
@export var enable_invisible_wall: bool = true
## quest tied to the encounter
@export var quest: Quest
## quest required to be completed in order to begin the encounter
@export var prerequisite_quest: Quest

# public vars
## CombatManager ref
var combat_manager: Node = null

# private vars

# @onready vars
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var invisible_wall: StaticBody2D = $StaticBody2D
@onready var static_collider: CollisionShape2D = $StaticBody2D/CollisionShape2D


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


## initializes triggerzone collision shape & both quest & prerequisite quest
func _ready() -> void:
	collision_shape.shape = shape

	if !Engine.is_editor_hint():
		# TODO: very sloppy, rework before final merge (maybe make CombatManager a singleton? or a unique node?)
		combat_manager = get_node("../../CombatManager")
		if enable_invisible_wall:
			# update shape of static collider
			static_collider.shape = shape.duplicate()
			static_collider.shape.size -= Vector2(1, 1)
		else:
			invisible_wall.hide()

		# initialize quest
		if quest:
			_initialize_quest()
		# initialize prerequisite_quest
		if prerequisite_quest:
			_initialize_prerequisite_quest()
		else:
			enable_boss_encounter()


# remaining builtins e.g. _process, _input


# public methods
## hides the whole encounter object
func disable_boss_encounter() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED


## allows the player to begin combat encounter after collision
func enable_boss_encounter() -> void:
	disabled = false


# private methods
## checks if current quest is already saved in the QuestManager, otherwise
## the quest is added to the QuestManager. [signal Quest.on_quest_finished] is connected
func _initialize_quest() -> void:
	var temp_quest: Quest = QuestManager.get_quest(quest)

	# update current quest to found quest in QuestManager quest_list, add it
	# to QuestManager quest_list otherwise
	if temp_quest:
		quest = temp_quest
	else:
		QuestManager.add_quest(quest, true)

	# hide encounter if current quest is already completed
	if quest.is_finished():
		disable_boss_encounter()

	# track quest if [member track_quest] is set
	if track_quest:
		QuestManager.track_quest(QuestManager.get_quest_index(quest))

	# connect [signal Quest.on_quest_finished] signal
	quest.on_quest_finished.connect(disable_boss_encounter)


## checks if current prerequisite quest is already saved in the QuestManager, otherwise
## [signal Quest.on_quest_finished] is connected
func _initialize_prerequisite_quest() -> void:
	var temp_quest: Quest = QuestManager.get_quest(prerequisite_quest)

	# update prerequisite quest to found quest in QuestManager quest_list
	if temp_quest:
		prerequisite_quest = temp_quest

	# enable encounter if prerequisite quest is already completed
	if prerequisite_quest.is_finished():
		enable_boss_encounter()

	# connect [signal Quest.on_quest_finished] signal
	prerequisite_quest.on_quest_finished.connect(enable_boss_encounter)


## begin combat encounter on collision with triggerzone
func _on_body_entered(_body: Node2D) -> void:
	if disabled:
		printerr("boss disabled")
		return

	if entities.size() == 0:
		printerr("no entities present, cannot begin boss battle")
		return

	if combat_manager:
		await get_tree().process_frame
		combat_manager.trigger_combat(true, null, entities, true)
		return

	printerr("combat manager missing, cannot begin boss battle")


# subclasses
