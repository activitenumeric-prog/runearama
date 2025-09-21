extends CanvasLayer

@onready var health_label: Label = $Control/Health
@onready var mana_label: Label = $Control/Mana
var player: Node = null

func set_player(p: Node) -> void:
    player = p

func _process(_delta: float) -> void:
    if player == null:
        return
    if player.has_variable("health") and player.has_variable("max_health"):
        health_label.text = "HP: %d/%d" % [player.health, player.max_health]
    if player.has_variable("mana") and player.has_variable("max_mana"):
        mana_label.text = "Mana: %d/%d" % [player.mana, player.max_mana]
