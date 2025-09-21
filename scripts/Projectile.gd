extends Area2D

@export var speed := 420.0
var direction := Vector2.RIGHT

func _ready():
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func set_direction(d: Vector2):
	direction = d.normalized()
	rotation = direction.angle()

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_area_entered(a):
	if a.is_in_group("enemies"):
		if a.has_method("apply_damage"):
			a.apply_damage(1)
		if a.has_method("die"):
			a.die()
		queue_free()

func _on_body_entered(b):
	if b.is_in_group("enemies"):
		if b.has_method("apply_damage"):
			b.apply_damage(1)
		if b.has_method("die"):
			b.die()
		queue_free()
