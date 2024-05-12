extends Control
# docstring


# signals

# enums

# constants

# @export vars
@export var character_data: Array[PackedScene]
@export var character_name_overrides: Array[String]

# public vars

# private vars
var _character_index: int = 0
var _character_list: Array

# @onready vars
@onready var fallback_entity = preload("res://entities/party-members/fallback/fallback.tscn")
@onready var title:Label = get_node("Title")
@onready var image:TextureRect = get_node("Image/TextureRect")


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


## append instances of packed scenes stored in [param character_data]
## to [param _character_list].
## if data is invalid, append [param fallback_entity] instead
func _ready() -> void:
	for character in character_data:
		if _is_valid(character.get_state()):
			_character_list.append(character.instantiate())
		else:
			_character_list.append(fallback_entity.instantiate())
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
func _is_valid(state: SceneState) -> bool:
	for i in range(0, state.get_node_count()):
		for j in range(0, state.get_node_property_count(i)):
			if state.get_node_property_name(i, j) == "stats":
				return true
	return false


## update character box information such as
## title label and image
## validates [param _character_list] first
## overrides name if name override present in
## [param character_name_overrides]
func _update_character_box() -> void:
	if _character_list.is_empty():
		print("no characters to display")
		return

	# apply name override if name override present
	if _character_index < character_name_overrides.size():
		_character_list[_character_index].entity_name = \
		character_name_overrides[_character_index]

		# update node name for easier debugging and clearer
		# savefile
		_character_list[_character_index].name = \
		_character_list[_character_index].entity_name.to_pascal_case()

	title.text = _character_list[_character_index].entity_name
	image.texture = _character_list[_character_index].get_sprite_texture()


# subclasses
