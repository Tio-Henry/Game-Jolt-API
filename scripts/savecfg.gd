@tool
extends Node

var plugin_dir: String = get_script().resource_path.get_base_dir()

func data_save(data: Dictionary, data_file: String) -> void:
	var file: FileAccess = FileAccess.open(data_file,FileAccess.WRITE)
	file.store_var(data)
	
func data_load(data: Dictionary, data_file: String) -> void:
	var file: FileAccess = FileAccess.open(data_file,FileAccess.READ)
	data.merge(file.get_var(),true)
