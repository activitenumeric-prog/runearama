extends CharacterBody2D

signal died

@export var move_speed: float = 180.0
@export var shoot_cooldown: float = 0.18
@export var max_health: int = 5
@export var max_mana: int = 100
@export var mana_per_shot: int = 5
@export var use_mouse_aim: bool = true

var health: int
var mana: int
var _cooldown: float = 0.0

var current_runes: Array[String] = ["BOLT", "ARCANE"]

@onready var spell_system: SpellSystem = get_node_or_null("../SpellSystem") if get_node_or_null("../SpellSystem") else get_node_or_null("./SpellSystem")

func _ready() -> void:
	health = max_health
	mana = max_mana
	_ensure_default_input_actions()

func _physics_process(delta: float) -> void:
	_cooldown = max(0.0, _cooldown - delta)

	var input_vec := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_vec * move_speed
	move_and_slide()

	if Input.is_action_pressed("fire"):
		_try_fire()

func _try_fire() -> void:
	if _cooldown > 0.0:
		return
	if mana < mana_per_shot:
		return
	if spell_system == null:
		push_warning("SpellSystem not found.")
		return

	var dir := _aim_direction()
	if dir.length() <= 0.01:
		return

	spell_system.cast(self, current_runes, global_position, dir)
	_cooldown = shoot_cooldown
	mana = clamp(mana - mana_per_shot, 0, max_mana)

func _aim_direction() -> Vector2:
	if use_mouse_aim:
		var mouse_world := get_global_mouse_position()
		return (mouse_world - global_position).normalized()
	var ax := Vector2(Input.get_action_strength("aim_right") - Input.get_action_strength("aim_left"),
					  Input.get_action_strength("aim_down") - Input.get_action_strength("aim_up"))
	return ax.normalized()

func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	if health == 0:
		_on_death()

func _on_death() -> void:
	emit_signal("died")
	queue_free()

func _ensure_default_input_actions() -> void:
	var to_make := {
		"move_left": KEY_A, "move_right": KEY_D,
		"move_up": KEY_W, "move_down": KEY_S,
		"fire": MOUSE_BUTTON_LEFT,
		"aim_left": KEY_LEFT, "aim_right": KEY_RIGHT,
		"aim_up": KEY_UP, "aim_down": KEY_DOWN,
		"pause": KEY_P
	}
	for action in to_make.keys():
		if not InputMap.has_action(action):
			InputMap.add_action(action)
			if to_make[action] == MOUSE_BUTTON_LEFT:
				var mev := InputEventMouseButton.new()
				mev.button_index = MOUSE_BUTTON_LEFT
				InputMap.action_add_event(action, mev)
			else:
				var ev := InputEventKey.new()
				ev.physical_keycode = to_make[action]
				InputMap.action_add_event(action, ev)
