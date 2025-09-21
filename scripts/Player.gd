extends CharacterBody2D

signal died

@export var move_speed: float = 180.0
@export var shoot_cooldown: float = 0.18
@export var max_health: int = 5
@export var max_mana: int = 100
@export var mana_per_shot: int = 5
@export var use_mouse_aim: bool = true

# ✅ Nouveaux réglages
@export var mana_regen_per_sec: float = 12.0   # quantité de mana récupérée par seconde
@export var no_mana_cost: bool = true         # mode debug: tirer sans consommer de mana

var health: int
var mana: int
var _cooldown: float = 0.0

var current_runes: Array[String] = ["BOLT", "ARCANE"]

@onready var spell_system: Node = get_node_or_null("../SpellSystem") if get_node_or_null("../SpellSystem") else get_node_or_null("./SpellSystem")

func _ready() -> void:
	add_to_group("player")
	health = max_health
	mana = max_mana
	_ensure_default_input_actions()

func _physics_process(delta: float) -> void:
	_cooldown = max(0.0, _cooldown - delta)

	# ✅ Regen de mana
	if not no_mana_cost and mana_regen_per_sec > 0.0:
		mana = clamp(mana + int(round(mana_regen_per_sec * delta)), 0, max_mana)

	var move_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if move_vec == Vector2.ZERO:
		var lx := int(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_LEFT))
		var rx := int(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT))
		var uy := int(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_UP))
		var dy := int(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN))
		move_vec = Vector2(float(rx - lx), float(dy - uy)).normalized()

	velocity = move_vec * move_speed
	move_and_slide()

	if Input.is_action_pressed("fire") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_try_fire()

func _try_fire() -> void:
	if _cooldown > 0.0:
		return
	if not no_mana_cost and mana < mana_per_shot:
		return
	if spell_system == null:
		push_warning("SpellSystem not found.")
		return

	var dir := _aim_direction()
	if dir.length() <= 0.01:
		return

	# offset pour ne pas se toucher soi-même au spawn
	var origin := global_position + dir.normalized() * 12.0
	spell_system.call("cast", self, current_runes, origin, dir)
	_cooldown = shoot_cooldown

	if not no_mana_cost:
		mana = clamp(mana - mana_per_shot, 0, max_mana)

func _aim_direction() -> Vector2:
	if use_mouse_aim:
		var mouse_world := get_global_mouse_position()
		return (mouse_world - global_position).normalized()
	var ax := Vector2(
		Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
		Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up")
	)
	return ax.normalized()

func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	if health == 0:
		_on_death()

func _on_death() -> void:
	emit_signal("died")
	queue_free()

func _ensure_default_input_actions() -> void:
	# QWERTY/WASD + AZERTY/ZQSD + flèches + souris
	var maps := {
		"move_left":  [KEY_A, KEY_Q, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up":    [KEY_W, KEY_Z, KEY_UP],
		"move_down":  [KEY_S, KEY_DOWN],
		"fire":       [MOUSE_BUTTON_LEFT],
		"aim_left":   [KEY_LEFT],
		"aim_right":  [KEY_RIGHT],
		"aim_up":     [KEY_UP],
		"aim_down":   [KEY_DOWN],
		"pause":      [KEY_P]
	}
	for action in maps.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for code in maps[action]:
			if typeof(code) == TYPE_INT:
				if code == MOUSE_BUTTON_LEFT:
					var mev := InputEventMouseButton.new()
					mev.button_index = MOUSE_BUTTON_LEFT
					InputMap.action_add_event(action, mev)
				else:
					var ev := InputEventKey.new()
					ev.physical_keycode = code
					ev.keycode = code
					InputMap.action_add_event(action, ev)
