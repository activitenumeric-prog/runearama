extends CharacterBody2D

@export var speed := 120.0
@export var aggro_radius := 200.0
@onready var stats = $Stats
var player_reference: Node2D = null
signal killed

func _ready():
    stats.died.connect(_on_dead)

func _physics_process(delta):
    if not player_reference: return
    var to_player = player_reference.global_position - global_position
    if to_player.length() <= aggro_radius:
        velocity = to_player.normalized() * speed
    else:
        velocity = Vector2.ZERO
    move_and_slide()

func _on_dead():
    killed.emit()
    queue_free()