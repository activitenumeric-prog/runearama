extends Node2D

@onready var pause_layer: CanvasLayer = $PauseOverlay
@onready var gameover_layer: CanvasLayer = $GameOverOverlay
@onready var hud: CanvasLayer = $HUD
@onready var player: Node2D = $Player
@onready var replay_button: Button = $GameOverOverlay/GOPanel/ReplayButton

func _ready() -> void:
	# Ces noeuds doivent continuer à fonctionner quand le jeu est en pause
	if pause_layer:
		pause_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	if gameover_layer:
		gameover_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	if replay_button:
		replay_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	var s: Dictionary = SaveSystem.get_settings()
	SaveSystem.apply_settings(s)

	if player and player.has_signal("died"):
		player.connect("died", Callable(self, "_on_player_died"))
	if hud and hud.has_method("set_player"):
		hud.set_player(player)
	_hide_overlays()
	if replay_button:
		replay_button.pressed.connect(_on_replay_pressed)

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
	# Grâce à PROCESS_MODE_WHEN_PAUSED sur le bouton, ce handler est appelé même en pause
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _hide_overlays() -> void:
	pause_layer.visible = false
	gameover_layer.visible = false

# --- save helpers ---
func _build_save_data() -> Dictionary:
	if player == null:
		return {}
	var p := player
	return {
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
