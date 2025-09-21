extends Area2D

@export var speed: float = 420.0
@export var damage: int = 1
@export var lifetime: float = 1.6
@export var pierce: int = 0
@export var homing: bool = false
@export var homing_turn_rate: float = 6.0

var direction: Vector2 = Vector2.RIGHT
var _time: float = 0.0
var _hits: int = 0
var target: Node2D = null

func _ready() -> void:
    monitoring = true
    connect("body_entered", _on_body_entered)
    connect("area_entered", _on_area_entered)

func _physics_process(delta: float) -> void:
    _time += delta
    if _time >= lifetime:
        queue_free()
        return

    if homing and is_instance_valid(target):
        var desired := (target.global_position - global_position).normalized()
        direction = direction.slerp(desired, clamp(homing_turn_rate * delta, 0.0, 1.0)).normalized()

    global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
    _try_damage(body)

func _on_area_entered(area: Area2D) -> void:
    _try_damage(area)

func _try_damage(node: Node) -> void:
    if node == null or node == self:
        return
    if not node.has_method("take_damage"):
        return
    node.call_deferred("take_damage", damage)

    if _hits < pierce:
        _hits += 1
    else:
        queue_free()
