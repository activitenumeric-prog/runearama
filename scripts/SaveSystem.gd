extends Node

const SAVE_PATH: String = "user://savegame.json"
const SETTINGS_PATH: String = "user://settings.json"

var pending_continue: bool = false

# ---------- SAVE / LOAD ----------
func has_save() -> bool:
    return FileAccess.file_exists(SAVE_PATH)

func delete_save() -> void:
    if has_save():
        DirAccess.remove_absolute(SAVE_PATH)

func save_game(data: Dictionary) -> bool:
    var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f == null:
        push_error("SaveSystem: can't open save file for write.")
        return false
    var json_text: String = JSON.stringify(data, "\t")
    f.store_string(json_text)
    f.flush()
    return true

func load_game() -> Dictionary:
    if not has_save():
        return {}
    var f: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
    if f == null:
        return {}
    var txt: String = f.get_as_text()
    var res: Variant = JSON.parse_string(txt)
    if typeof(res) == TYPE_DICTIONARY:
        return res as Dictionary
    return {}

func request_continue() -> void:
    pending_continue = true

# ---------- SETTINGS ----------
func get_settings() -> Dictionary:
    var def: Dictionary = {
        "fullscreen": false,
        "master": 0.8,
        "sfx": 0.8,
        "music": 0.6
    }
    if not FileAccess.file_exists(SETTINGS_PATH):
        return def
    var f: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
    if f == null:
        return def
    var res: Variant = JSON.parse_string(f.get_as_text())
    if typeof(res) != TYPE_DICTIONARY:
        return def
    return (res as Dictionary)

func save_settings(s: Dictionary) -> void:
    var f: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
    var txt: String = JSON.stringify(s, "\t")
    f.store_string(txt)
    f.flush()

func apply_settings(s: Dictionary) -> void:
    # Affichage
    var fs: bool = bool(s.get("fullscreen", false))
    var mode: int = DisplayServer.WINDOW_MODE_FULLSCREEN if fs else DisplayServer.WINDOW_MODE_WINDOWED
    DisplayServer.window_set_mode(mode)

    # Audio (ignorer si les bus n'existent pas)
    _set_bus_db("Master", float(s.get("master", 0.8)))
    _set_bus_db("SFX", float(s.get("sfx", 0.8)))
    _set_bus_db("Music", float(s.get("music", 0.6)))

func _set_bus_db(bus_name: String, vol01: float) -> void:
    var idx: int = AudioServer.get_bus_index(bus_name)
    if idx == -1:
        return
    var db: float = linear_to_db(clamp(vol01, 0.0, 1.0))
    AudioServer.set_bus_volume_db(idx, db)
