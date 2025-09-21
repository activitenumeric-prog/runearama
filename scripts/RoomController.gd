extends Node2D

enum State { IDLE, LOCKED, CLEAR }

@export var autostart: bool = true
@onready var door_left: Node = $DoorLeft
@onready var door_right: Node = $DoorRight
@onready var spawner: Node = $EnemySpawner

var state: int = State.IDLE

signal room_cleared

func _ready() -> void:
    if spawner and spawner.has_signal("wave_finished"):
        spawner.connect("wave_finished", Callable(self, "_on_wave_finished"))
    if autostart:
        start_room()

func start_room() -> void:
    state = State.LOCKED
    _lock_doors(true)
    if spawner and spawner.has_method("start_wave"):
        spawner.call("start_wave")

func _on_wave_finished() -> void:
    state = State.CLEAR
    _lock_doors(false)
    room_cleared.emit()

func _lock_doors(lock: bool) -> void:
    if door_left:
        if lock and door_left.has_method("lock"):
            door_left.call("lock")
        elif (not lock) and door_left.has_method("unlock"):
            door_left.call("unlock")
    if door_right:
        if lock and door_right.has_method("lock"):
            door_right.call("lock")
        elif (not lock) and door_right.has_method("unlock"):
            door_right.call("unlock")
