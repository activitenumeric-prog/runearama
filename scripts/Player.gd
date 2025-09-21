extends CharacterBody2D

@export var move_speed: float = 200.0
var input_dir := Vector2.ZERO
var facing := Vector2.DOWN

@onready var stats = $Stats
@onready var caster = $Caster

signal fired

func _physics_process(delta):
	input_dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down")  - Input.get_action_strength("ui_up")
	).normalized()

	if input_dir != Vector2.ZERO:
		facing = input_dir

	velocity = input_dir * move_speed
	move_and_slide()

func _process(delta):
	if Input.is_action_just_pressed("attack"):
		shoot()
	if Input.is_action_just_pressed("cast"):
		caster.cast_current()
	if Input.is_action_just_pressed("switch_spell_next"):
		caster.next_spell()
	if Input.is_action_just_pressed("switch_spell_prev"):
		caster.prev_spell()

func shoot():
	var p = preload("res://scenes/Projectile.tscn").instantiate()
	p.global_position = global_position
	p.dir = facing
	p.damage = 1
	get_tree().current_scene.add_child(p)
	fired.emit()
