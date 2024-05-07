# @tool
# class_name name
extends Node
# docstring


# signals

# enums

# constants

# @export vars
# public vars

# private vars

# @onready vars


func _init() -> void:
	pass


func _enter_tree() -> void:
	pass


func _ready() -> void:
	for i in get_tree().get_nodes_in_group("persist"):
		print(i.name)


# remaining builtins e.g. _process, _input
func _input(event: InputEvent) -> void:
	if event is InputEventKey && event.pressed:
		match event.keycode:
			KEY_2:
				save_game("debug")
			KEY_3:
				load_game("debug")


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			print("quiting game")
			for i in get_tree().get_nodes_in_group("persist"):
				print(i.name)
			get_tree().quit()


# public methods
func save_game(savefile_name: String) -> void:
	print("saving to file: %s.save" % savefile_name)
	var savefile := FileAccess.open("user://%s.save" % savefile_name, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for node in save_nodes:
		if node.scene_file_path.is_empty():
			print("node '%s' is not an instanced scene, skipping" % node.name)
			continue

		if !node.has_method("save"):
			print("missing method 'save' in node '%s', skipping" % node.name)
			continue

		var data = node.call("save")
		var json_string = JSON.stringify(data)
		savefile.store_line(json_string)

	print("save complete")


func load_game(savefile_name: String) -> void:
	if !FileAccess.file_exists("user://%s.save" % savefile_name):
		print("could not find %s.save file" % savefile_name)
		return

	var save_nodes = get_tree().get_nodes_in_group("persist")
	for node in save_nodes:
		node.queue_free()

	var savefile := FileAccess.open("user://%s.save" % savefile_name, FileAccess.READ)
	while savefile.get_position() < savefile.get_length():
		var json_string = savefile.get_line()

		var json := JSON.new()

		var parse_result = json.parse(json_string)
		if parse_result != OK:
			print("JSON parse error: ",
			json.get_error_message(),
			" in ",
			json_string,
			" at line ",
			json.get_error_line())
			continue

		var data = json.get_data()

		var new_object = load(data["filename"]).instantiate()
		get_node(data["parent"]).add_child(new_object)

		if new_object.has_method("load"):
			new_object.call("load", data)


# private methods


# subclasses

