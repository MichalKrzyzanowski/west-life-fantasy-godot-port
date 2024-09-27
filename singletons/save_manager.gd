# @tool
# class_name name
extends Node
# docstring


# signals

# enums

# constants
const SAVE_FILE = "save_1"
const SAVE_PATH = "user://saves/%s.save"

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
# func _input(event: InputEvent) -> void:
# 	if event is InputEventKey && event.pressed:
# 		match event.keycode:
# 			KEY_2:
# 				save_game("debug")
# 			KEY_3:
# 				load_game("debug")


# function for acting on notifications
# mainly used to save game as the game is quit
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			print("quiting game")
			# SaveManager.save_game("save_1")
			get_tree().quit()


# public methods
## save game with [param savefile_name]
## saves node from persist group
## nodes are staged, meaning parents of other
## nodes are saved first
func save_game(savefile_name: String) -> void:
	print("saving to file: %s.save" % savefile_name)

	# create saves folder if it does not exist already
	if !DirAccess.dir_exists_absolute("user://saves"):
		DirAccess.make_dir_absolute("user://saves")

	var savefile := FileAccess.open(SAVE_PATH % savefile_name, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("persist")

	# this will be used for marking already saved nodes
	# to prevent nodes from being saved twice
	var marked: Dictionary = {}

	# save each node
	for node in save_nodes:
		save_node(node, marked, savefile)
	print("save complete")


## helper that saves the [param node] if it has 'save' method
## [param marked] is used to store saved nodes
## [param savefile] is the reference to the open savefile
func save_node(node, marked: Dictionary, savefile: FileAccess) -> void:
	print("saving %s" % node.name)
	if marked.has(node.name):
		print("node '%s' is already saved, skipping" % node.name)
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


## load game from [param savefile_name] file
## first, free all nodes in persist group
## nodes are first renamed to prevent conflicts
## then, call 'load' method on new node
func load_game(savefile_name: String) -> bool:
	print("loading from file: %s.save" % savefile_name)
	if !FileAccess.file_exists(SAVE_PATH % savefile_name):
		print("could not find %s.save file" % savefile_name)
		return false

	# free all persist nodes
	var save_nodes = get_tree().get_nodes_in_group("persist")
	for node in save_nodes:
		# only rename and free objects that were instantiated
		if !node.scene_file_path.is_empty():
			# rename node to prevent future conflicts
			node.name = "%s@%s" % [node.name, str(randi() % 255)]
			node.queue_free()

	var savefile := FileAccess.open(SAVE_PATH % savefile_name, FileAccess.READ)
	while savefile.get_position() < savefile.get_length():
		var json_string = savefile.get_line()

		var json := JSON.new()

		# parse json result to validate data
		var parse_result = json.parse(json_string)
		if parse_result != OK:
			print("JSON parse error: ",
			json.get_error_message(),
			" in ",
			json_string,
			" at line ",
			json.get_error_line())
			continue

		# load json data
		load_node(json.get_data())

	print("load complete")
	return true


# helper that creates new node based on [param data]
# new node is attached to correct parent and it's 'load'
# method called
func load_node(data) -> void:
	# call load method on nodes that are not instantiated
	if !data.has("filename"):
		print("loading %s" % data["name"])
		var node = get_node("%s/%s" % [data["parent"], data["name"]])
		if node.has_method("load"):
			node.call("load", data)
		return

	print("loading %s" % data["filename"])

	var object_parent = get_node(data["parent"])

	var new_object = load(data["filename"]).instantiate()
	var present_object = object_parent.find_child(new_object.name)

	# if new_object already exists, free existing object
	if present_object:
		# if new_object saved with preserve_on_load flag, do not recreate object
		if data.has("preserve_on_load") && data["preserve_on_load"]:
			print("preserving %s" % present_object.name)
			if present_object.has_method("load"):
				present_object.call("load", data)
			new_object.queue_free()
			return

		print("%s already has node %s" % [object_parent.name, present_object])
		present_object.name = "%s@%s" % [present_object.name, str(randi() % 255)]
		present_object.queue_free()


	if data.has("deferred_load") && data["deferred_load"]:
		object_parent.call_deferred("add_child", new_object)
	else:
		object_parent.add_child(new_object)

	if new_object.has_method("load"):
		new_object.call("load", data)


## helper that returns true if savefile exists
func is_save_present() -> bool:
	return FileAccess.file_exists(SAVE_PATH % SAVE_FILE)


# private methods


# subclasses
