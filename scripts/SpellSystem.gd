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
    if spell_defs.has(key):
        return spell_defs[key]
    return spell_defs["DEFAULT"]

func cast(owner: Node2D, runes: Array[String], origin: Vector2, dir: Vector2) -> void:
    if projectile_scene == null:
        push_error("SpellSystem.projectile_scene is not set. Assign a Projectile.tscn in the inspector.")
        return
    var spec := resolve_combination(runes)
    var p: Node2D = projectile_scene.instantiate()
    p.global_position = origin
    if p.has_variable("direction"):
        p.direction = dir.normalized()
    if p.has_variable("damage"):
        p.damage = int(spec.damage)
    if p.has_variable("speed"):
        p.speed = float(spec.speed)
    if p.has_variable("pierce"):
        p.pierce = int(spec.pierce)
    if p.has_variable("homing"):
        p.homing = bool(spec.homing)
    owner.get_tree().current_scene.add_child(p)
