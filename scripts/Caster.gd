extends Node

@export var spells: Array[Spell]
@export var max_mana := 20
var mana := 0
var current := 0
var cd_timer := 0.0

signal mana_changed(curr:int, maxv:int)
signal spell_changed(index:int, total:int, name:String)

func _ready():
	mana = max_mana
	_emit_spell_changed()

func _process(delta):
	cd_timer = max(cd_timer - delta, 0.0)

func cast_current():
	if spells.is_empty():
		return
	var s: Spell = spells[current]
	if mana < s.mana_cost or cd_timer > 0.0:
		return
	mana -= s.mana_cost
	mana_changed.emit(mana, max_mana)

	var proj = s.projectile_scene.instantiate()
	if proj is Node2D:
		proj.global_position = owner.global_position
	proj.dir = owner.facing
	proj.speed = s.speed
	proj.damage = s.damage

	get_tree().current_scene.add_child(proj)
	cd_timer = s.cooldown

func next_spell():
	if spells.is_empty():
		return
	current = (current + 1) % spells.size()
	_emit_spell_changed()

func prev_spell():
	if spells.is_empty():
		return
	current = (current - 1 + spells.size()) % spells.size()
	_emit_spell_changed()

func _emit_spell_changed():
	var n := spells.size()
	var nm := spells[current].name if n > 0 else ""
	spell_changed.emit(current, n, nm)
