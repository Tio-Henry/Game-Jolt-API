@tool
extends EditorPlugin

var plugin_dir: String = get_script().resource_path.get_base_dir()

func _enter_tree():
	if not ProjectSettings.has_setting("application/game_jolt_api/game_id"):
		ProjectSettings.set_setting("application/game_jolt_api/game_id", 0)
	if not ProjectSettings.has_setting("application/game_jolt_api/private_key"):
		ProjectSettings.set_setting("application/game_jolt_api/private_key", "")
	add_autoload_singleton("SaveCFG", plugin_dir + "/scripts/savecfg.gd")
	add_autoload_singleton("GameJoltAPI", plugin_dir + "/scripts/game_jolt_api.gd")
	
func _exit_tree():
	remove_autoload_singleton("SaveCFG")
	remove_autoload_singleton("GameJoltAPI")
