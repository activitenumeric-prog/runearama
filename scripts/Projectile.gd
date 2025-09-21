extends Area2D

@export var speed := 350.0
@export var damage := 1
var dir := Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	global_position += dir * speed * delta

func _on_body_entered(body):
	if body.has_node("Stats"):
		body.get_node("Stats").take_damage(damage)
	queue_free()

func _on_area_entered(a):
	if a.has_node("Stats"):
		a.get_node("Stats").take_damage(damage)
	queue_free()
