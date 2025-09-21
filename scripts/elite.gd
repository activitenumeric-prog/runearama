extends "res://scripts/enemy.gd"   # Hérite de l’ennemi de base

@export var max_hp := 12           # PV élevés
var hp := 12                       # PV courants

func _ready():
    super._ready()                 # Godot 4 : appeler la méthode parente
    add_to_group("elite")          # Tag pour le GameManager

func apply_damage(amount):
    hp -= amount                   # On enlève les PV
    if hp <= 0:                    # Si mort…
        _drop_rune()               #   → déposer une rune
        get_tree().call_group("managers", "on_elite_killed")  # notifier manager
        die()                      #   → détruire l’ennemi

func _drop_rune():
    var Rune = preload("res://scenes/Rune.tscn") # Charge la scène Rune
    var r = Rune.instantiate()                   # Instancie
    r.global_position = global_position          # Place au sol
    get_tree().current_scene.add_child(r)        # Ajoute à la scène
