extends Node2D

@export var enemy_scene: PackedScene
@export var count: int = 4
@export var radius: float = 60.0

var spawned: Array[Node2D] = []
signal wave_finished

func _ready() -> void:
	add_to_group("spawner")
	await get_tree().process_frame

func start_wave() -> void:
	clear_wave()
	if enemy_scene == null:
		push_warning("EnemySpawner: enemy_scene non défini")
		wave_finished.emit()
		return
	var parent_node: Node = get_parent()
	if parent_node == null:
		push_error("EnemySpawner: parent introuvable")
		wave_finished.emit()
		return
	for i in range(count):
		var e: Node2D = enemy_scene.instantiate()
		var ang: float = TAU * float(i) / max(1.0, float(count))
		e.global_position = global_position + Vector2(cos(ang), sin(ang)) * radius
		parent_node.call_deferred("add_child", e)
		spawned.append(e)
	await get_tree().create_timer(0.25).timeout
	_watch_wave()

func _watch_wave() -> void:
	while true:
		var alive: Array[Node2D] = []
		for n in spawned:
			if is_instance_valid(n):
				alive.append(n)
		spawned = alive
		if spawned.is_empty():
			wave_finished.emit()
			return
		await get_tree().create_timer(0.2).timeout

func clear_wave() -> void:
	for n in spawned:
		if is_instance_valid(n):
			n.queue_free()
	spawned.clear()
