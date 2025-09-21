extends Node

func _ready():
	_ensure_input_map()                                  # 1) Garantit que les actions existent
	var player = $"../Player"                            # 2) Raccourci vers le joueur
	if player:
		player.projectile_scene = preload("res://scenes/Projectile.tscn")  # 3) Assigne la scène du tir
	var door1 = $"../Room1/DoorToRoom2"                  # 4) Câble la cible de la porte Room1 → Room2
	if door1:
		door1.target_room_path = NodePath("../Room2")
	var exit_area = $"../Room2/ExitArea"                 # 5) Branche la zone de sortie (victoire)
	if exit_area:
		exit_area.body_entered.connect(_on_exit_body_entered)

func _on_exit_body_entered(body):
	if body.is_in_group("player"):                       # 6) Le joueur traverse → victoire
		get_tree().change_scene_to_file("res://scenes/Victory.tscn")

func _ensure_input_map():
	# 7) Définit les actions clavier (AZERTY + flèches) + souris pour "shoot"
	var mapping := {
		"move_up":    [KEY_W, KEY_UP, KEY_Z],            # ZQSD + flèche Haut
		"move_down":  [KEY_S, KEY_DOWN],
		"move_left":  [KEY_A, KEY_LEFT, KEY_Q],
		"move_right": [KEY_D, KEY_RIGHT],
		"shoot":      [KEY_SPACE],
		"escape":     [KEY_ESCAPE],
	}
	for action in mapping.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)                  # 8) Crée l’action si absente
		# TIP : on garde les éventuels bindings existants, on ajoute juste les manquants
		for k in mapping[action]:
			var ev := InputEventKey.new()
			ev.keycode = k                               # 9) Utilise le keycode (compatible AZERTY)
			InputMap.action_add_event(action, ev)        # 10) Ajoute l’event à l’action
	# Ajoute le clic gauche pour "shoot"
	var mev := InputEventMouseButton.new()
	mev.button_index = MOUSE_BUTTON_LEFT                 # 11) Clic gauche → “shoot”
	InputMap.action_add_event("shoot", mev)
