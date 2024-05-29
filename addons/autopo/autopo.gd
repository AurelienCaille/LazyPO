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
	print("LazyPO loaded")


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass


# Starts the parsing process for all directories specified in `dirs_to_parse`.
#
# Collects all file paths and saves them to settings.
func parse_all_dir() -> void:
	print("Start parsing")
	all_files_path = []
	
	for dir_path : String in dirs_to_parse:
		sub_parse_all_dir(dir_path)
	
	save_to_settings(all_files_path)
	print("Parsing done, have a good day")


# Recursively parses the specified directory, calling appropriate functions for files and directories.
#
# If the directory is not in `dirs_to_exclude`, it lists its contents and calls `check_file_for_po`
# for each file and `sub_parse_all_dir` for each subdirectory.
#
# Args:
#     dir_path (String): The path of the directory to parse.
func sub_parse_all_dir(dir_path : String) -> void:
	if not dir_path in dirs_to_exclude:
		dir_contents_c(dir_path, check_file_for_po, sub_parse_all_dir)


# Checks if a file's extension is valid.
#
# If valid, adds the file path to the list of paths to save.
#
# Args:
#     file_path (String): The path of the file to check.
func check_file_for_po(file_path : String) -> void:
	if file_path.get_extension() in VALIDS_EXTENSION:
		add_path_to_save(file_path)


# Adds a file path to the list of paths to save.
#
# Ensures the path is not already in the list before adding.
#
# Args:
#     path (String): The file path to add.
func add_path_to_save(path : String):
	if path not in all_files_path:
		all_files_path.append(path)


# Saves the list of file paths to project settings.
#
# Ensures no duplicate paths are saved.
#
# Args:
#     all_files (Array[String]): The list of file paths to save.
func save_to_settings(all_files : Array[String]) -> void:
	var setting : Array = ProjectSettings.get_setting("internationalization/locale/translations_pot_files")
	
	for path : String in all_files:
		if not path in setting:
			setting.append(path)
	
	ProjectSettings.set_setting("internationalization/locale/translations_pot_files", setting)
	ProjectSettings.save()


# Recursively lists the contents of a directory.
#
# Calls `call_file` for each file and `call_dir` for each directory.
#
# Args:
#     path (String): The path of the directory to list.
#     call_file (Callable): The function to call for each file.
#     call_dir (Callable): The function to call for each directory.
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


# Adds a directory setting to the project settings.
#
# Configures it to be displayed as a directory path.
#
# Args:
#     setting_name (String): The name of the setting.
#     base_value (String): The base value of the setting.
func add_dir_setting(setting_name : String, base_value) -> void:
	ProjectSettings.set_setting(setting_name, base_value)
	ProjectSettings.set_initial_value(setting_name, base_value)
	ProjectSettings.add_property_info({
			"name": setting_name,
			"type" : TYPE_STRING,
			"hint": PROPERTY_HINT_DIR,
			"usage": PROPERTY_USAGE_DEFAULT,
		})
	ProjectSettings.set_as_basic(setting_name, true)


# Creates the necessary settings in the ProjectSettings.
#
# Iterates to create multiple settings as Godot doesn't support arrays of directories in ProjectSettings.
func _create_settings() -> void:
	for i in range(1, 17):
		var setting_to_parse_name : String = DIRS_TO_PARSE + DIR_TO_PARSE + " %s" % [i]
		
		if not ProjectSettings.has_setting(setting_to_parse_name):
			add_dir_setting(setting_to_parse_name, "res://")
		
		
		var setting_to_exclude_name : String = DIRS_TO_EXCLUDE + DIR_TO_EXCLUDE + " %s" % [i]
		
		if not ProjectSettings.has_setting(setting_to_exclude_name):
			add_dir_setting(setting_to_exclude_name, "res://addons")

	ProjectSettings.save()


# Retrieves the settings from the ProjectSettings.
#
# Populates the `dirs_to_parse` and `dirs_to_exclude` arrays with the settings.
func _get_settings() -> void:
	for i in range(1, 17):
		var dir_to_parse = ProjectSettings.get_setting(DIRS_TO_PARSE + DIR_TO_PARSE + " %s" % [i])
		
		if not dir_to_parse in dirs_to_parse:
			dirs_to_parse.append(dir_to_parse)
			
		var dir_to_exclude = ProjectSettings.get_setting(DIRS_TO_EXCLUDE + DIR_TO_EXCLUDE + " %s" % [i])
		
		if not dir_to_parse in dirs_to_parse:
			dirs_to_parse.append(dir_to_parse)
