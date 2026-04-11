@icon("res://addons/game-jolt-api/gamejolt.png")
extends Node

enum ACTION_TYPE {USER, DATA_STORE, TROPHY, SESSIONS, TIME, SCORES, FRIENDS, OTHER, IMG}
enum OPERATION {ADD, SUBTRACT, MULTIPLY, DIVIDE, APPEND, PREPEND}
enum STATUS {ACTIVE, IDLE, NULL}

var user_file: String = "user://gj-credentials.dat"

var data_user: Dictionary = {
	"username":"",
	"user_token":"",
	"user_id" : 0
}

func _ready() -> void:
	if FileAccess.file_exists(user_file):
		var file: FileAccess = FileAccess.open(user_file, FileAccess.READ)
		var file_data: Dictionary = file.get_var()
		if await user_login(file_data.username, file_data.user_token):
			data_user = file_data

#region Data Functions
func data_fetch(require_user: bool, key: String) -> Variant:
	var code: String = "&key=" + key
	return await connect_api("data_store", require_user, ACTION_TYPE.DATA_STORE, code)

func data_get_keys(require_user: bool, pattern: String = "") -> Variant:
	var code: String = ""
	if pattern != "":
		code = "&pattern=" + pattern
	return await connect_api("data_store/get_keys", require_user, ACTION_TYPE.DATA_STORE,code)

func data_remove(require_user: bool,key: String) -> Variant:
	var code: String = "&key=" + key
	return await connect_api("data_store/remove", require_user, ACTION_TYPE.DATA_STORE,code)

func data_set(require_user: bool, key: String, data: String) -> Variant:
	var code: String = "&key=" + key + "&data=" + data
	return await connect_api("data_store/set", require_user, ACTION_TYPE.DATA_STORE, code)

func data_update(require_user: bool, key: String, operation: OPERATION, value: String) -> Variant:
	var operation_str: Array[String] = ["add", "subtract", "multiply", "divide", "append", "prepend"]
	var code: String = "&key=" + key + "&operation=" + operation_str[operation] + "&value=" + value
	return await connect_api("data_store/update",require_user, ACTION_TYPE.DATA_STORE, code)
#endregion

#region Sessions Functions
func sessions_check() -> Variant:
	return await connect_api("sessions/check", true, ACTION_TYPE.SESSIONS)

func sessions_close(timer: Variant) -> Variant:
	if is_instance_valid(timer):
		if timer is Timer:
			timer.queue_free()
	else:
		return null
	return await connect_api("sessions/close", true, ACTION_TYPE.SESSIONS)

func sessions_open(ping: bool = true) -> Variant:
	var response: Variant = await connect_api("sessions/open", true, ACTION_TYPE.SESSIONS)
	if ping:
		if response:
			var timer: Timer = Timer.new()
			add_child(timer)
			timer.wait_time = 30.0
			timer.start()
			timer.timeout.connect(sessions_ping.bind(STATUS.ACTIVE))
			return [response, timer]
		else:
			return response
	else:
		return response

func sessions_ping(status: STATUS = STATUS.ACTIVE) -> Variant:
	var status_str: Array[String] = ["active","idle",""]
	var code: String = ""
	if status_str[status] != "":
		code = "&status=" + status_str[status]
	return await connect_api("sessions/ping", true, ACTION_TYPE.SESSIONS, code)
#endregion

#region Scores Functions
func scores_add(require_user: bool, score: String, sort: int, table_id: int = 0, guest: String = "", extra_data: String = "") -> Variant:
	var code: String = "&score=" + score + "&sort=" + str(sort)
	if table_id != 0:
		code += "&table_id=" + str(table_id)
	if guest != "":
		code += "&guest=" + guest
	if extra_data != "":
		code += "&extra_data=" + extra_data 
	return await connect_api("scores/add", require_user, ACTION_TYPE.SCORES, code)

func scores_fetch(require_user: bool, table_id: int = 0, limit: int = 0, better_than: int = 0, worse_than: int = 0, guest: String = "") -> Variant:
	var code: String = ""
	if table_id != 0:
		code += "&table_id=" + str(table_id)
	if limit != 0:
		code += "&limit=" + str(limit)
	if better_than != 0:
		code += "&better_than=" + str(better_than)
	if worse_than != 0:
		code += "&worse_than=" + str(worse_than)
	if guest != "":
		code += "&guest=" + guest
	return await connect_api("scores",require_user, ACTION_TYPE.SCORES, code)

func scores_get_rank(sort:int, table_id: int = 0) -> Variant:
	var code: String = "&sort=" + str(sort) 
	if table_id != -0:
		code += "&table_id=" + str(table_id)
	return await connect_api("scores/get-rank", false, ACTION_TYPE.SCORES, code)

func scores_table() -> Variant:
	return await connect_api("scores/tables", false, ACTION_TYPE.SCORES)
#endregion

#region Trophies Functions
func trophy_achieved(achieved: bool) -> Variant:
	var code: String = ""
	code = "&achieved=" + str(achieved)
	return await connect_api("trophies", true, ACTION_TYPE.TROPHY, code)

func trophy_add(trophy_id: int) -> Variant:
	var code: String = "&trophy_id=" + str(trophy_id)
	return await connect_api("trophies/add-achieved", true, ACTION_TYPE.TROPHY, code)

func trophies_info(trophy_id: int = 0) -> Variant:
	var code: String = ""
	if trophy_id != 0:
		code = "&trophy_id=" + str(trophy_id)
	return await connect_api("trophies", true, ACTION_TYPE.TROPHY, code)

func trophy_remove(trophy_id: int) -> Variant:
	var code: String = "&trophy_id=" + str(trophy_id)
	return await connect_api("trophies/remove-achieved", true, ACTION_TYPE.TROPHY, code)
#endregion

#region User Functions
func friends_list() -> Variant:
	return await connect_api("friends", true, ACTION_TYPE.FRIENDS)

func user_auth(username: String, user_token: String) -> Variant:
	var code: String = "&username=" + username + "&user_token=" + user_token
	return await connect_api("users/auth", false, ACTION_TYPE.USER, code)

func username_fetch(username: String) -> Variant:
	var code: String = "&username=" + username
	return await connect_api("users", false, ACTION_TYPE.USER, code)

func user_id_fetch(user_id: int) -> Variant:
	var code: String = "&user_id=" + str(user_id)
	return await connect_api("users", false, ACTION_TYPE.USER, code)

func user_login(username: String, user_token: String) -> bool:
	if await user_auth(username, user_token):
		data_user["username"] = username
		data_user["user_token"] = user_token
		var data: Variant = await username_fetch(username)
		data_user["user_id"] = data["id"]
		SaveCFG.data_save(data_user, user_file)
		return true
	else:
		return false
#endregion

#region Others Functions
func check_internet() -> bool:
	return str(await time_server()) != "error"

func time_server() -> Variant:
	return await connect_api("time", false, ACTION_TYPE.TIME)
#endregion

#region Connections Functions
func connect_api(type: String, require_user: bool, action_type: ACTION_TYPE, code: String = "") -> Variant:
	var game_id: String = str(ProjectSettings.get_setting("application/game_jolt_api/game_id"))
	var private_key: String = ProjectSettings.get_setting("application/game_jolt_api/private_key")
	
	if game_id == "" or private_key == "":
		printerr("To use the Game Jolt API it is necessary to inform the Game ID and Private Key of your Game Jolt project page in Project Settings > General > Application > Game Jolt API.")
		return null
	else:
		var LINK: String = "https://api.gamejolt.com/api/game/v1_2/" + type + "/?game_id=" + game_id
		if require_user:
			if data_user["username"] != "" and data_user["user_token"] != "" and FileAccess.file_exists(user_file):
				LINK += "&username=" + data_user["username"] + "&user_token=" + data_user["user_token"]
			else:
				printerr("Username and User Token is required for this function!")
				return null
		LINK += code
		var LINK_WITH_KEY: String = LINK + private_key
		var LINK_COMPLETE: String = LINK + "&signature=" + LINK_WITH_KEY.sha1_text()
		return await connect_web(LINK_COMPLETE, action_type)

func connect_web(LINK: String, action_type: ACTION_TYPE) -> Variant:
	var https_request: HTTPRequest = HTTPRequest.new()
	add_child(https_request)
	https_request.request(LINK)
	var data: Array = await https_request.request_completed
	https_request.queue_free()
	return data_processing(data, action_type)

func data_processing(data: Array, action_type: ACTION_TYPE) -> Variant:
	if data[0] == 0:
		var json_data: Variant = JSON.parse_string(data[3].get_string_from_utf8())
		var response: Dictionary = json_data["response"]
		if response["success"] == "true":
			var response_data: Variant
			match action_type:
				ACTION_TYPE.USER:
					if response.has("users"):
						response_data = response.users[0]
					else:
						response_data = response.success == "true"
				ACTION_TYPE.DATA_STORE:
					response_data = response
					if response.has("data"):
						response_data = response.data
					if response.has("keys"):
						response_data = response.keys
					if response.size() == 1:
						response_data = response.success == "true"
				ACTION_TYPE.TROPHY:
					if response.has("trophies"):
						response_data = response.trophies
					else:
						response_data = response.success == "true"
				ACTION_TYPE.SESSIONS:
					response_data = response.success == "true"
				ACTION_TYPE.TIME:
					response_data = response
					response_data.erase("success")
				ACTION_TYPE.SCORES:
					if response.has("scores"):
						response_data = response.scores
					if response.has("rank"):
						response_data = response.rank
					if response.has("tables"):
						response_data = response.tables
					if response.size() == 1:
						response_data = response.success == "true"
				ACTION_TYPE.FRIENDS:
					response_data = response.friends
				ACTION_TYPE.OTHER:
					response_data = response
			return response_data
		else:
			if response.has("message"):
				printerr(response.message)
			return response.success == "true"
	else:
		printerr("Connection error",", code: " + str(data[0]))
		return "error"
#endregion
