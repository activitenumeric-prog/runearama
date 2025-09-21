extends "res://scripts/enemy.gd"

@export var max_hp := 14
var hp := 14

func _ready():
	super._ready()
	add_to_group("elite")

func apply_damage(amount):
	hp -= amount
	if hp <= 0:
		_drop_rune()
		get_tree().call_group("managers", "on_elite_killed")
		die()

func _drop_rune():
	var Rune = preload("res://scenes/Rune.tscn")
	var r = Rune.instantiate()
	r.global_position = global_position
	get_tree().current_scene.add_child(r)
