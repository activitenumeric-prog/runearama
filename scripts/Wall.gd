extends Node2D

@export var size := Vector2(16,16)

func set_size(s:Vector2):
	size = s
	var shape := RectangleShape2D.new()
	shape.size = size
	$StaticBody2D/CollisionShape2D.shape = shape
	queue_redraw()

func _draw():
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.15,0.15,0.18))
