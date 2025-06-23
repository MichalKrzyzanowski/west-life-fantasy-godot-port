# @tool
# class_name name
extends Control
# docstring


# signals
## emitted when exit button is clicked
signal on_exit()

# enums
## enum class that represents state of the clinic
enum ClinicState {
	STANDBY, ## initial state, when player enters shop
	REVIVE_AVAILABLE, ## when at least one party member is dead
	REVIVE, ## when dead party member is clicked
}

# constants

# @export vars
## cost to revive a dead party member
@export var revive_cost: int = 40
## clinic name
@export var clinic_name: String
## toggles clinic legacy exit functionality
## which includes exiting the clinic by pressing
## left mouse button anywhere on the screen
## if no party members can be revived
@export var legacy_mode: bool = false

# public vars

# private vars
# current state of clinic
var _clinic_state: ClinicState = ClinicState.STANDBY:
	set(new_state):
		_clinic_state = new_state
		match _clinic_state:
			ClinicState.STANDBY:
				_enter_standby_state()
			ClinicState.REVIVE_AVAILABLE:
				_enter_revive_available_state()
			ClinicState.REVIVE:
				_enter_revive_state()

## reference to currently selected dead member button
var _selected_dead_member_button: Button

# @onready vars
@onready var options_panel: NinePatchRect = $OptionsPanel
# option lists
@onready var dead_party_list: VBoxContainer = $OptionsPanel/DeadPartyList
@onready var confirm_selection_list: VBoxContainer = $OptionsPanel/ConfirmSelectionList
# labels
@onready var gold_label: Label = $GoldLabel/Label
@onready var title_label: Label = $TitlePanel/Label
@onready var info_label: Label = $InfoPanel/Label

@onready var exit_button: Button = $ExitButton

# theme assets that are applied to newly created dead party member button
@onready var empty_button_theme: Theme = preload("res://ui/common/theme/empty_button.tres")
@onready var arial_bold_font: Font = preload("res://ui/common/font/arialbd.ttf")


# func _init() -> void:
# 	pass


# func _enter_tree() -> void:
# 	pass


## sets up clinic name, signals, state, etc.
func _ready() -> void:
	if legacy_mode:
		exit_button.hide()

	title_label.text = clinic_name
	PartyManager.on_gold_changed.connect(_update_gold_text)

	_update_gold_text()
	_enter_standby_state()
	_update_dead_party_members()


# remaining builtins e.g. _process, _input
## used only in when legacy mode is enabled
func _input(event: InputEvent) -> void:
	if !legacy_mode:
		return

	match _clinic_state:
		ClinicState.STANDBY:
			# legacy: exit if left click detected while no party members are dead
			if event.is_action_pressed("exit_clinic") && is_visible_in_tree():
				_exit_clinic()


# public methods


# private methods
## add dead party members to list
func _update_dead_party_members() -> void:
	for i: int in PartyManager.party.size():
		var member: EntityProperties = PartyManager.party[i]
		if !member.is_alive():
			_add_dead_member_button(i, member.name)

	# switch state when 1 or more party members are dead
	if dead_party_list.get_child_count() > 0:
		_clinic_state = ClinicState.REVIVE_AVAILABLE


## adds new button to dead party members options list.
## button holds metadata of party [param member_id] and
## pressed signal is connected. button text is set to [param member_name]
func _add_dead_member_button(member_id: int, member_name: String) -> void:
	# button setup
	var button: Button = Button.new()
	button.theme = empty_button_theme
	button.text = member_name
	button.add_theme_font_override("font", arial_bold_font)
	button.add_theme_font_size_override("font_size", 30)

	# connect signals and setup metadata
	button.pressed.connect(_on_dead_member_button_pressed.bind(button))
	button.set_meta("member_id", member_id)

	# add to dead party list
	dead_party_list.add_child(button)


## stores [param button_ref] into private variable and
## switches state to [constant ClinicState.REVIVE]
func _on_dead_member_button_pressed(button_ref: Button) -> void:
	_selected_dead_member_button = button_ref
	_clinic_state = ClinicState.REVIVE


## updates gold text label with current party gold
func _update_gold_text() -> void:
	gold_label.text = "%d G" % PartyManager.gold


## enter initial state.
## changes clinic info text and hides options box
func _enter_standby_state() -> void:
	info_label.text = "You do not need my help now."
	options_panel.hide()


## called when one or more party members are dead.
## changes clinic info text and shows options box
func _enter_revive_available_state() -> void:
	info_label.text = "Who shall be revived...."
	options_panel.show()
	dead_party_list.show()
	confirm_selection_list.hide()


## called when dead party member is clicked.
## shows yes/no prompt
func _enter_revive_state() -> void:
	confirm_selection_list.show()
	dead_party_list.hide()


## cleans up clinic by resetting state to standby.
## called when exiting the clinic
func _exit_clinic() -> void:
	_selected_dead_member_button = null
	_clinic_state = ClinicState.STANDBY
	on_exit.emit()


## revives dead party member, if player can afford it
func _on_confirm_button_pressed() -> void:
	if !_selected_dead_member_button:
		printerr("dead member button is not selected")
		return

	# fetch button member_id metadata
	var member_id: int = _selected_dead_member_button.get_meta("member_id", -1)
	if member_id < 0:
		printerr("invalid member id")
		return

	# revive dead member
	if PartyManager.can_afford(revive_cost):
		PartyManager.spend_gold(revive_cost)
		PartyManager.party[member_id].revive()

	# remove dead member button
	dead_party_list.remove_child(_selected_dead_member_button)
	_selected_dead_member_button.queue_free()

	if dead_party_list.get_child_count() > 0:
		_clinic_state = ClinicState.REVIVE_AVAILABLE
	else:
		_clinic_state = ClinicState.STANDBY


## called when player declines party member revival i.e. selects no
func _on_decline_button_pressed() -> void:
	_clinic_state = ClinicState.REVIVE_AVAILABLE


# subclasses
