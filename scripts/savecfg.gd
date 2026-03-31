@tool
extends Node

var plugin_dir: String = get_script().resource_path.get_base_dir()

var file_cfg: String = "res://addons/Additional-APIs/sys_data.dat"
var sys_data = {
	"gj" : {"game_id" : "", "private_key" : ""}
}

func _ready() -> void:
	if FileAccess.file_exists(SaveCFG.file_cfg):
		SaveCFG.data_load(SaveCFG.sys_data,SaveCFG.file_cfg)

func data_save(data: Dictionary, data_file: String):
	var file = FileAccess.open(data_file,FileAccess.WRITE)
	file.store_var(data)
	
func data_load(data: Dictionary, data_file: String):
	var file = FileAccess.open(data_file,FileAccess.READ)
	data.merge(file.get_var(),true)
