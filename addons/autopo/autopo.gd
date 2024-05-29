@tool
extends EditorPlugin

const SETTING_POT := "internationalization/locale/translations_pot_files"
const VALIDS_EXTENSION := ["tscn", "gd"]


var dirs_to_parse : Array[String] = [] #path of all dir to parse
const DIRS_TO_PARSE := "AutoPO/Dirs to parse/"
const DIR_TO_PARSE := "Dir to parse"
var dirs_to_exclude : Array[String] = [] #dir and subdir we don't want to parse
const DIRS_TO_EXCLUDE := "AutoPO/Dirs to exclude/"
const DIR_TO_EXCLUDE := "Dir to exclude"


var all_files_path : Array[String]


func _enter_tree() -> void:
	add_tool_menu_item("Auto POT", parse_all_dir)
	_create_settings()
	_get_settings()
	print(dirs_to_parse)
	print(dirs_to_exclude)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass


func parse_all_dir() -> void:
	print("Start parsing")
	all_files_path = []
	
	for dir_path : String in dirs_to_parse:
		sub_parse_all_dir(dir_path)
	
	save_to_settings(all_files_path)
	print("Parsing done, have a good day")


func sub_parse_all_dir(dir_path : String) -> void:
	if not dir_path in dirs_to_exclude:
		dir_contents_c(dir_path, check_file_for_po, sub_parse_all_dir)


func check_file_for_po(file_path : String) -> void:
	if file_path.get_extension() in VALIDS_EXTENSION:
		add_path_to_save(file_path)


func add_path_to_save(path : String):
	print(path)
	if path not in all_files_path:
		all_files_path.append(path)


func save_to_settings(all_files : Array[String]) -> void:
	var setting : Array = ProjectSettings.get_setting("internationalization/locale/translations_pot_files")
	
	for path : String in all_files:
		if not path in setting:
			setting.append(path)
	
	ProjectSettings.set_setting("internationalization/locale/translations_pot_files", setting)
	ProjectSettings.save()


func dir_contents_c(path : String, call_file : Callable, call_dir : Callable) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			var path_complete = path.path_join(file_name)
			if dir.current_is_dir():
				call_dir.call(path_complete)
			else:
				call_file.call(path_complete)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func add_dir_setting(setting_name : String, base_value) -> void:
	ProjectSettings.set_setting(setting_name, base_value)
	ProjectSettings.add_property_info({
			"name": setting_name,
			"type" : TYPE_STRING,
			"hint": PROPERTY_HINT_DIR,
			"usage": PROPERTY_USAGE_DEFAULT,
		})
	ProjectSettings.set_as_basic(setting_name, true)


func _create_settings() -> void:
	# We iterate to create multiples settings as Godot doesnt support Array of dir in ProjectSetting
	for i in range(1, 17):
		print(i)
		var setting_to_parse_name : String = DIRS_TO_PARSE + DIR_TO_PARSE + " %s" % [i]
		
		if not ProjectSettings.has_setting(setting_to_parse_name):
			add_dir_setting(setting_to_parse_name, "res://")
		
		
		var setting_to_exclude_name : String = DIRS_TO_EXCLUDE + DIR_TO_EXCLUDE + " %s" % [i]
		
		if not ProjectSettings.has_setting(setting_to_exclude_name):
			add_dir_setting(setting_to_exclude_name, "res://addons")

	ProjectSettings.save()


func _get_settings() -> void:
	for i in range(1, 17):
		var dir_to_parse = ProjectSettings.get_setting(DIRS_TO_PARSE + DIR_TO_PARSE + " %s" % [i])
		
		if not dir_to_parse in dirs_to_parse:
			dirs_to_parse.append(dir_to_parse)
			
		var dir_to_exclude = ProjectSettings.get_setting(DIRS_TO_EXCLUDE + DIR_TO_EXCLUDE + " %s" % [i])
		
		if not dir_to_parse in dirs_to_parse:
			dirs_to_parse.append(dir_to_parse)
