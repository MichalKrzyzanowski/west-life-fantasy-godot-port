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
	var marked : Dictionary = {}

	for node in save_nodes:
		save_node(node, marked, savefile)
	print("save complete")


func save_node(node, marked: Dictionary, savefile: FileAccess) -> void:
	print("saving %s" % node.name)
	if marked.has(node.name):
		print("node '%s' is already saved, skipping" % node.name)
		return

	if node.scene_file_path.is_empty():
		print("node '%s' is not an instanced scene, skipping" % node.name)
		return

	if !node.has_method("save"):
		print("missing method 'save' in node '%s', skipping" % node.name)
		return

	if node.get_parent().is_in_group("persist"):
		print("parent is in persist group, saving first")
		save_node(node.get_parent(), marked, savefile)

	var data = node.call("save")
	var json_string = JSON.stringify(data)
	savefile.store_line(json_string)
	marked[node.name] = true


func load_game(savefile_name: String) -> void:
	print("loading from file: %s.save" % savefile_name)
	if !FileAccess.file_exists("user://%s.save" % savefile_name):
		print("could not find %s.save file" % savefile_name)
		return

	var save_nodes = get_tree().get_nodes_in_group("persist")
	for node in save_nodes:
		node.name = "%s@%s" % [node.name, str(randi() % 255)]
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

		load_node(json.get_data())

	print("load complete")


func load_node(data) -> void:
	print("loading %s" % data["filename"])
	var new_object = load(data["filename"]).instantiate()
	var object_parent = get_node(data["parent"])

	# if new_object already exists, free existing object
	# if new_object.is_inside_tree() && object_parent.has_node(new_object.get_path()):
	var present_object = object_parent.find_child(new_object.name)
	if present_object:
		print("%s already has node %s" % [object_parent.name, present_object])
		present_object.name = "%s@%s" % [present_object.name, str(randi() % 255)]
		present_object.queue_free()
		# await get_tree().process_frame

	object_parent.add_child(new_object)

	if new_object.has_method("load"):
		new_object.call("load", data)


# private methods


# subclasses

