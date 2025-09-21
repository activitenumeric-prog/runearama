extends Node2D

@export var enemy_scene: PackedScene
@export var count: int = 3
@export var radius: float = 60.0

var spawned: Array[Node2D] = []

signal wave_finished

func _ready() -> void:
	await get_tree().process_frame  # laisse la scène s’initialiser

func start_wave() -> void:
	clear_wave()
	if enemy_scene == null:
		push_warning("EnemySpawner: enemy_scene non défini (aucun ennemi)")
		wave_finished.emit()
		return

	var parent_node := get_parent()
	if parent_node == null:
		push_error("EnemySpawner: pas de parent pour ajouter les ennemis")
		wave_finished.emit()
		return

	# Instancie maintenant, AJOUT différé
	for i in range(count):
		var e: Node2D = enemy_scene.instantiate()
		var ang: float = TAU * float(i) / max(1.0, float(count))
		e.global_position = global_position + Vector2(cos(ang), sin(ang)) * radius
		parent_node.call_deferred("add_child", e)   # <-- important
		spawned.append(e)

	# Lance la surveillance après un petit délai (le temps que les add_child se fassent)
	_watch_wave_deferred()

func _watch_wave_deferred() -> void:
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
