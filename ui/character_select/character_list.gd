extends Control
# docstring


# signals

# enums

# constants

# @export vars
@export var character_data: Array[EntityProperties]
@export var character_name_overrides: Array[String]

# public vars

# private vars
var _character_index: int = 0
var _character_list: Array

# @onready vars
# @onready var fallback_entity = preload("res://entities/party-members/fallback/fallback.tscn")
@onready var title = $Title as Label
@onready var image = $Image/TextureRect as TextureRect


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


## append instances of packed scenes stored in [param character_data]
## to [param _character_list].
## if data is invalid, append [param fallback_entity] instead
func _ready() -> void:
	for character in character_data:
		if _is_valid(character):
			_character_list.append(character)
		else:
			#_character_list.append(fallback_entity.instantiate())
			pass
	_update_character_box()


# remaining builtins e.g. _process, _input


# public methods
## move [param _character_index] by [param amount].
## supports cycling array index forward and backwards
func move_character_index(amount: int) -> void:
	# stop if character_data array is null
	if !character_data:
		return
	_character_index = (_character_index + amount + character_data.size()) % character_data.size()
	_update_character_box()


## add currently character to party manager
func add_current_to_party():
	if !_character_list.is_empty():
		PartyManager.add_member(_character_list[_character_index])


# private methods
func _on_previous_char_button_pressed() -> void:
	move_character_index(-1)


func _on_next_char_button_pressed() -> void:
	move_character_index(1)


## validate [param state] of entity node
## by checking if stats export is available
func _is_valid(entity_data: EntityProperties) -> bool:
	return entity_data.stats != null


## update character box information such as
## title label and image
## validates [param _character_list] first
## overrides name if name override present in
## [param character_name_overrides]
func _update_character_box() -> void:
	if _character_list.is_empty():
		print("no characters to display")
		return

	title.text = _character_list[_character_index].name
	image.texture = _character_list[_character_index].texture


# subclasses
