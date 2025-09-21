class_name SpellSystem
extends Node

@export var projectile_scene: PackedScene

var spell_defs := {
	"BOLT+ARCANE": {"damage": 1, "speed": 420.0, "pierce": 0, "homing": false},
	"BOLT+FIRE":   {"damage": 2, "speed": 400.0, "pierce": 0, "homing": false},
	"ORB+ARCANE":  {"damage": 1, "speed": 260.0, "pierce": 1, "homing": false},
	"SEEK+ARCANE": {"damage": 1, "speed": 320.0, "pierce": 0, "homing": true},
	"DEFAULT":     {"damage": 1, "speed": 360.0, "pierce": 0, "homing": false}
}

func resolve_combination(runes: Array[String]) -> Dictionary:
	var key := "+".join(runes)
	return spell_defs.get(key, spell_defs["DEFAULT"])

func cast(caster: Node2D, runes: Array[String], origin: Vector2, dir: Vector2) -> void:
	if projectile_scene == null:
		push_error("SpellSystem.projectile_scene is not set. Assign a Projectile.tscn in the inspector.")
		return

	var spec := resolve_combination(runes)
	var p: Area2D = projectile_scene.instantiate()

	p.global_position = origin
	p.direction = dir.normalized()
	p.damage  = int(spec.damage)
	p.speed   = float(spec.speed)
	p.pierce  = int(spec.pierce)
	p.homing  = bool(spec.homing)
	p.from_player = true

	var parent := caster.get_parent()
	if parent:
		parent.add_child(p)
	else:
		caster.get_tree().current_scene.add_child(p)
