extends Control

@export var known: bool = true
@export var cleared: bool = false

func set_cleared(v: bool) -> void:
    cleared = v
    queue_redraw()

func _draw() -> void:
    var c: Color
    if cleared:
        c = Color(0.2, 0.9, 0.2)
    else:
        c = Color(0.5, 0.5, 0.5)
    draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.6), false, 1.5)
    draw_circle(size * 0.5, min(size.x, size.y) * 0.25, c)
