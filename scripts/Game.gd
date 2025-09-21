extends Node2D

@onready var pause_layer: CanvasLayer = $PauseOverlay
@onready var gameover_layer: CanvasLayer = $GameOverOverlay
@onready var hud: CanvasLayer = $HUD
@onready var player: Node2D = $Player
@onready var replay_button: Button = $GameOverOverlay/GOPanel/ReplayButton

func _ready() -> void:
	# Appliquer les réglages
	var s: Dictionary = SaveSystem.get_settings()
	SaveSystem.apply_settings(s)

	if player and player.has_signal("died"):
		player.connect("died", Callable(self, "_on_player_died"))
	if hud and hud.has_method("set_player"):
		hud.set_player(player)
	_hide_overlays()
	if replay_button:
		replay_button.pressed.connect(_on_replay_pressed)

	# Continuer ?
	if SaveSystem.pending_continue:
		var data: Dictionary = SaveSystem.load_game()
		_apply_save_data(data)
		SaveSystem.pending_continue = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		pause_layer.visible = get_tree().paused
		if get_tree().paused:
			var d: Dictionary = _build_save_data()
			SaveSystem.save_game(d)

func _on_player_died() -> void:
	gameover_layer.visible = true
	get_tree().paused = true
	SaveSystem.save_game(_build_save_data())

func _on_replay_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _hide_overlays() -> void:
	pause_layer.visible = false
	gameover_layer.visible = false

# ---------- helpers save ----------
func _build_save_data() -> Dictionary:
	if player == null:
		return {}
	# On accède aux champs du Player
	var p := player
	var data: Dictionary = {
		"player": {
			"x": p.global_position.x,
			"y": p.global_position.y,
			"health": int(p.health),
			"max_health": int(p.max_health),
			"mana": int(p.mana),
			"max_mana": int(p.max_mana)
		},
		"meta": {
			"version": "0.2",
			"timestamp": Time.get_unix_time_from_system()
		}
	}
	return data

func _apply_save_data(d: Dictionary) -> void:
	if d.is_empty() or player == null:
		return
	var p: Dictionary = d.get("player", {}) as Dictionary
	var x: float = float(p.get("x", player.global_position.x))
	var y: float = float(p.get("y", player.global_position.y))
	player.global_position = Vector2(x, y)
	if p.has("max_health"): player.max_health = int(p["max_health"])
	if p.has("health"):     player.health     = clamp(int(p["health"]), 0, player.max_health)
	if p.has("max_mana"):   player.max_mana   = int(p["max_mana"])
	if p.has("mana"):       player.mana       = clamp(int(p["mana"]),   0, player.max_mana)
