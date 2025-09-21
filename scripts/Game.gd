extends Node2D

@onready var pause_layer: CanvasLayer = $PauseOverlay
@onready var gameover_layer: CanvasLayer = $GameOverOverlay
@onready var hud: CanvasLayer = $HUD
@onready var player: Node2D = $Player
@onready var replay_button: Button = $GameOverOverlay/GOPanel/ReplayButton
@onready var minimap: Control = $HUD_Minimap/Map
@onready var room: Node2D = $Room
@onready var dungen: DungeonGen = (get_node_or_null("DungeonGen") as DungeonGen)

var current_room_grid: Vector2i

func _ready() -> void:
	if pause_layer:    pause_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	if gameover_layer: gameover_layer.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	if replay_button:  replay_button.process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	var s: Dictionary = SaveSystem.get_settings()
	SaveSystem.apply_settings(s)

	if player and player.has_signal("died"):
		player.connect("died", Callable(self, "_on_player_died"))
	if hud and hud.has_method("set_player"):
		hud.set_player(player)
	_hide_overlays()
	if replay_button:
		replay_button.pressed.connect(_on_replay_pressed)

	# --- Générer un petit donjon et alimenter la minimap ---
	if dungen == null:
		dungen = DungeonGen.new()
		add_child(dungen)
	dungen.width = 5
	dungen.height = 5
	dungen.max_steps = 12
	dungen.dungeon_seed = 0
	dungen.generate()

	# Position grille de départ (centre)
	current_room_grid = Vector2i(int(dungen.width/2.0), int(dungen.height/2.0))

	if minimap and minimap.has_method("set_map"):
		minimap.call("set_map", dungen.rooms, current_room_grid)

	# Quand la salle est terminée, on marque "cleared" sur la mini-map
	if room and room.has_signal("room_cleared"):
		room.connect("room_cleared", Callable(self, "_on_room_cleared"))

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
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_room_cleared() -> void:
	if minimap and minimap.has_method("set_cleared_at"):
		minimap.call("set_cleared_at", current_room_grid, true)

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
			"version": "0.3",
			"timestamp": Time.get_unix_time_from_system()
		}
	}
