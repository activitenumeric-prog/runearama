extends Node2D

@onready var pause_layer: CanvasLayer = $PauseOverlay
@onready var gameover_layer: CanvasLayer = $GameOverOverlay
@onready var hud: CanvasLayer = $HUD
@onready var player: Node2D = $Player

func _ready() -> void:
    if player and player.has_signal("died"):
        player.connect("died", Callable(self, "_on_player_died"))
    if hud and hud.has_method("set_player"):
        hud.set_player(player)
    _hide_overlays()

func _unhandled_input(event):
    if event.is_action_pressed("pause"):
        get_tree().paused = not get_tree().paused
        pause_layer.visible = get_tree().paused

func _on_player_died() -> void:
    gameover_layer.visible = true
    get_tree().paused = true

func _hide_overlays() -> void:
    pause_layer.visible = false
    gameover_layer.visible = false
