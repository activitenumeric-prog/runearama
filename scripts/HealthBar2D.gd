extends Node2D

@export var width: float = 18.0
@export var height: float = 3.0
@export var y_offset: float = -14.0
var ratio: float = 1.0

func set_ratio(r: float) -> void:
	ratio = clamp(r, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var bg_pos := Vector2(-width * 0.5, y_offset)
	draw_rect(Rect2(bg_pos, Vector2(width, height)), Color(0,0,0,0.6))
	var fill_w := width * ratio
	draw_rect(Rect2(bg_pos, Vector2(fill_w, height)), Color(0,1,0,0.9))
