extends CharacterBody2D

@export var speed := 200.0
@export var projectile_scene: PackedScene
@export var shoot_cooldown := 0.25
@export var max_hp := 5
@export var invuln_time := 0.6

var hp := 5
var _can_shoot := true
var _invuln := false
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _cam := $Camera2D

func _ready():
	add_to_group("player")
	hp = max_hp
	_ui_set_hp()

func _physics_process(_delta):
	var dir = Vector2(
		int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left")),
		int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	)
	velocity = dir.normalized() * speed
	move_and_slide()

func _process(_delta):
	if _can_shoot and Input.is_action_pressed("shoot"):
		_shoot()

func _shoot():
	if projectile_scene == null:
		return
	_can_shoot = false
	var p = projectile_scene.instantiate()
	var to = get_global_mouse_position()
	var dir = (to - global_position).normalized()
	p.global_position = global_position + dir * 20.0
	p.call("set_direction", dir)
	get_tree().current_scene.add_child(p)
	_play_sfx("res://ressources/sounds/shoot.wav")
	await get_tree().create_timer(shoot_cooldown).timeout
	_can_shoot = true

func apply_damage(amount):
	if _invuln:
		return
	hp -= amount
	_ui_set_hp()
	_hit_feedback()
	if hp <= 0:
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func _hit_feedback():
	_invuln = true
	_play_sfx("res://ressources/sounds/hit.wav")
	if _cam and _cam.has_method("shake"):
		_cam.shake(8.0, 0.15)
	var t = create_tween()
	t.tween_property(_sprite, "modulate", Color(1,0.6,0.6), 0.05)
	t.tween_property(_sprite, "modulate", Color(1,1,1), 0.10)
	await get_tree().create_timer(invuln_time).timeout
	_invuln = false

func collect_rune():
	_play_sfx("res://ressources/sounds/rune.wav")
	var ui = get_tree().get_first_node_in_group("ui_root")
	if ui and ui.has_method("add_rune"):
		ui.add_rune(1)

func _ui_set_hp():
	var ui = get_tree().get_first_node_in_group("ui_root")
	if ui and ui.has_method("set_hp"):
		ui.set_hp(hp, max_hp)

func _play_sfx(path: String):
	if not ResourceLoader.exists(path):
		return
	if not has_node("Sfx"):
		var s = AudioStreamPlayer.new()
		s.name = "Sfx"
		add_child(s)
	$Sfx.stream = load(path)
	$Sfx.play()
