extends CharacterBody2D

@export var speed := 200.0
@export var projectile_scene: PackedScene
@export var shoot_cooldown := 0.25

var hp := 5
var _can_shoot := true

func _ready():
	add_to_group("player")

func _physics_process(delta):
	var dir = Vector2(
		int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left")),
		int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	)
	velocity = dir.normalized() * speed
	move_and_slide()

func _process(delta):
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
	await get_tree().create_timer(shoot_cooldown).timeout
	_can_shoot = true

func apply_damage(amount):
	hp -= amount
	print("PV joueur :", hp)
	if hp <= 0:
		get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func collect_rune():
	var ui = get_tree().get_first_node_in_group("ui_root")
	if ui and ui.has_method("add_rune"):
		ui.call("add_rune", 1)
