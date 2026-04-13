# 🎮 Game Jolt API for Godot

This plugin is based on the [Game Jolt API Docs](https://gamejolt.com/game-api). It is highly recommended to read both the **Plugin Wiki** and the official **Game Jolt API Docs** for detailed information.

### 🚀 Key Features
* **Full Implementation:** All API functions are currently implemented.
* **Documentation:** The wiki provides a comprehensive list of all functions and practical usage examples.

---
```gdscript
func _ready():
    # Logs in the user with username and token
    await GameJoltAPI.user_login("User", "1234")
    # Adds a trophy by its ID (integer)
    await GameJoltAPI.trophy_add(157345)
```

### 📥 Installation
1. Download or clone this repository.
2. Copy the `addons/game_jolt_api` folder into your project's `res://addons/` directory.
3. Go to **Project Settings > Plugins** and enable "Game Jolt API".

> [!IMPORTANT]  
> This plugin is an independent project and is not affiliated with, endorsed by, or sponsored by Game Jolt or the Game Jolt API.

![Godot v4.x](https://img.shields.io/badge/Godot-v4.x-blue?logo=godot-engine&logoColor=white)
![Version](https://img.shields.io/badge/Version-2.0.0-green)
