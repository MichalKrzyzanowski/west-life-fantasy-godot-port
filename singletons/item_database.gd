# @tool
# class_name name
extends Node
# docstring


# signals

# enums

# constants
## location where base game items are stored
const ITEMS_DIR: String = "res://items"
# TODO: add path to mod items
# TODO: add modded item parsing & loading
## file/dir names to be ignored when parsing [constant ITEMS_DIR]
const IGNORE_ENTRIES: Array[String] = [
	"common",
	"items_template.json",
]
## fields that must be present in [Item] for it to be
## added to item database.
const MANDATORY_ITEM_FIELDS: Array[String] = [
	"id",
	"name",
]

# @export vars

# public vars
## main [Dictionary] for item database.
## holds all items, currently only base game
## items are supported.
var data: Dictionary = {}

# private vars
## holds callbacks for creating different types of [Item]
var _item_type_callbacks: Dictionary = {
	"consumable": func() -> Consumable: return Consumable.new("consume"),
	"gear": func() -> Gear: return Gear.new(),
	"weapon": func() -> Gear: return Gear.new("equip_weapon"),
	"armour": func() -> Gear: return Gear.new("equip_armour"),
}

# @onready vars


# _init
func _init() -> void:
	pass


# _enter_tree
func _enter_tree() -> void:
	pass


# _ready
func _ready() -> void:
	_populate_database()


# remaining builtins e.g. _process, _input


# public methods
## load an item resource directly from [param resource_path].
func add_item(resource_path: String) -> void:
	var item_res: Item = load(resource_path)
	if !item_res:
		printerr("failed to load item resource: %s" % resource_path)
		return

	if data.has(item_res.id):
			printerr('tres_item_parse: duplicate id: %d found for item "%s"'
					% [item_res.id, item_res.name])
			return

	data[item_res.id] = item_res
	print("added item: %s" % item_res.name.capitalize())


## parse a json file with [param json_path] and load all valid items.
## preferred method of adding items, useful for creating items in bulk
func add_item_bulk(json_path: String) -> void:
	var json_string: String = FileAccess.get_file_as_string(json_path)
	if json_string.is_empty():
		printerr("failed to open json file: %s" % json_path)
		return

	var json: JSON = JSON.new()

	if json.parse(json_string) != OK:
			print("JSON parse error: ",
			json.get_error_message(),
			" in ",
			json_string,
			" at line ",
			json.get_error_line())
			return

	var json_data: Dictionary = json.get_data()
	for key: String in json_data.keys():
		var item_dat: Dictionary = json_data[key]

		# make sure item has mandatory fields
		if !MANDATORY_ITEM_FIELDS.all(func(field: String) -> bool: return field in item_dat.keys()):
			printerr("invalid item: missing either id and/or name fields")
			continue

		# skip item if item with same id is already present in data
		if data.has(item_dat["id"]):
			printerr('json_item_parse: duplicate id: %d found for item "%s"'
					% [item_dat["id"], item_dat["name"]])
			continue

		# if type field is not present, create a generic Item type
		var new_item: Item
		if !item_dat.has("type") || !_item_type_callbacks.has(item_dat["type"]):
			print('type was not specified for item "%s". defaulting to type Item'
					% item_dat["name"])
			new_item = Item.new()
			new_item.load(item_dat)
			data[new_item.id] = new_item
			print("added item: %s" % new_item.name.capitalize())
			continue

		new_item = _item_type_callbacks[item_dat["type"]].call()
		new_item.load(item_dat)
		data[new_item.id] = new_item
		print("added item: %s" % new_item.name.capitalize())


## fetch item with [param id] from [member data] dict.
## returns [Item] or [code]null[/code] if [param id] is not in [member data] dict
func get_item(id: int) -> Item:
	if !data.has(id):
		return null
	return data[id]


## fetch all item ids
func get_ids() -> Array:
	return data.keys()


# private methods
## item database initialization.
## only populates item database with base game items,
## mdded items are ignored.
func _populate_database() -> void:
	print("populating item database")
	_parse_dir(ITEMS_DIR)
	print("finished populating item database")
	for i in data.keys():
		print("[%d]%s" % [data[i].id, data[i].name.capitalize()])


## iterate over [param dir_path] and it's subdirs.
## every item not in [constant IGNORE_ENTRIES] is parsed.
## json files are iterated over and [Item] data loaded.
## loaded [Item] is added to [member data].
## [Item] resources are added to [member data].
func _parse_dir(dir_path: String) -> void:
	var dir: DirAccess = DirAccess.open(dir_path)

	print("parsing %s/" % dir_path)

	if !dir:
		printerr("could not find dir: %s" % dir_path)
		return

	var current_dir: String = dir.get_current_dir()

	dir.list_dir_begin()

	var current_file: String = dir.get_next()
	while current_file != "":
		# ignore files
		if current_file in IGNORE_ENTRIES:
			print("ignoring %s/" % current_file)
			current_file = dir.get_next()
			continue
		# parse subdir
		elif dir.current_is_dir():
			_parse_dir("%s/%s" % [current_dir, current_file])
			current_file = dir.get_next()
			continue

		# act on file
		# json: load all files from json file (bulk-loading)
		# res: load file from resource (single-load)
		if current_file.ends_with(".json"):
			add_item_bulk("%s/%s" % [current_dir, current_file])
		elif current_file.ends_with(".tres"):
			add_item("%s/%s" % [current_dir, current_file])

		current_file = dir.get_next()

	print("leaving %s/" % current_dir)

	dir.list_dir_end()


# subclasses
