extends Node2D

@export var is_locked: bool = true

@onready var shape_cs: CollisionShape2D   = get_node_or_null("StaticBody2D/CollisionShape2D") as CollisionShape2D
@onready var shape_cp: CollisionPolygon2D = get_node_or_null("StaticBody2D/CollisionPolygon2D") as CollisionPolygon2D
@onready var color_rect: ColorRect        = get_node_or_null("ColorRect") as ColorRect
@onready var sprite2d: Sprite2D           = get_node_or_null("Sprite2D") as Sprite2D

func _ready() -> void:
	add_to_group("door")
	_apply_lock()

func lock() -> void:
	is_locked = true
	_apply_lock()

func unlock() -> void:
	is_locked = false
	_apply_lock()

func _apply_lock() -> void:
	if shape_cs:
		shape_cs.disabled = not is_locked
	elif shape_cp:
		shape_cp.disabled = not is_locked

	var col: Color = Color(0.8, 0.1, 0.1, 1.0) if is_locked else Color(0.1, 0.8, 0.1, 1.0)
	if color_rect:
		color_rect.color = col
	elif sprite2d:
		sprite2d.modulate = col
