extends Node
class_name Stats

@export var max_hp := 5
var hp := 0
signal died
signal hp_changed(curr:int, maxv:int)

func _ready():
    hp = max_hp

func take_damage(amount:int):
    hp = max(hp - amount, 0)
    hp_changed.emit(hp, max_hp)
    if hp == 0:
        died.emit()

func heal(amount:int):
    hp = clamp(hp + amount, 0, max_hp)
    hp_changed.emit(hp, max_hp)