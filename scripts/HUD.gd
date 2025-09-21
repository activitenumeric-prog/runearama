extends CanvasLayer

@onready var health_label: Label = $Control/Health
@onready var mana_label: Label = $Control/Mana
var player: Node = null

func set_player(p: Node) -> void:
	player = p

func _process(_delta: float) -> void:
	if player == null:
		return
	# accès direct aux variables du Player
	health_label.text = "HP: %d/%d" % [player.health, player.max_health]
	mana_label.text = "Mana: %d/%d" % [player.mana, player.max_mana]
