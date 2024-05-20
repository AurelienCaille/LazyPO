@tool
extends EditorPlugin

const SETTING_POT := "internationalization/locale/translations_pot_files"
const VALIDS_EXTENSION := ["tscn", "gd"]


var dir_to_parse : Array[String] = ["res://"] #path of all dir to parse
var dir_to_exclude : Array[String] = ["res://addons"] #dir and subdir we don't want to parse


var all_files_path : Array[String]


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_tool_menu_item("Auto POT", parse_all_dir)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass


func parse_all_dir() -> void:
	print("Start parsing")
	all_files_path = []
	
	for dir_path : String in dir_to_parse:
		sub_parse_all_dir(dir_path)
	
	save_to_settings(all_files_path)
	print("Parsing done, have a good day")


func sub_parse_all_dir(dir_path : String) -> void:
	if not dir_path in dir_to_exclude:
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
