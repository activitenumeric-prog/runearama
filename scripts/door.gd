extends Node2D

@export var is_locked: bool = true
@onready var collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var sprite: ColorRect = $ColorRect

func _ready() -> void:
    _apply_lock()

func lock() -> void:
    is_locked = true
    _apply_lock()

func unlock() -> void:
    is_locked = false
    _apply_lock()

func _apply_lock() -> void:
    # Collision active si porte verrouillée
    collision.disabled = not is_locked
    # Couleur indicative (rouge fermé, vert ouvert) — sans opérateur ternaire
    var col: Color
    if is_locked:
        col = Color(0.8, 0.1, 0.1, 1.0)
    else:
        col = Color(0.1, 0.8, 0.1, 1.0)
    sprite.color = col
