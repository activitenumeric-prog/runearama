extends Node2D

enum State { IDLE, LOCKED, CLEAR }

@export var autostart: bool = true

var state: int = State.IDLE
signal room_cleared

var door_left: Node = null
var door_right: Node = null
var spawner: Node = null

func _ready() -> void:
	_detect_by_groups()

	if spawner != null and spawner.has_signal("wave_finished"):
		spawner.connect("wave_finished", Callable(self, "_on_wave_finished"))

	if autostart:
		await get_tree().process_frame
		start_room()

func start_room() -> void:
	state = State.LOCKED
	_lock_doors(true)
	if spawner != null and spawner.has_method("start_wave"):
		spawner.call("start_wave")
	else:
		push_warning("[RoomController] Pas de spawner → on déverrouille par sécurité")
		_on_wave_finished()

func _on_wave_finished() -> void:
	state = State.CLEAR
	_lock_doors(false)
	room_cleared.emit()
	print("[RoomController] Salle clear → portes ouvertes")

func _lock_doors(lock: bool) -> void:
	if door_left != null:
		if lock and door_left.has_method("lock"):
			door_left.call("lock")
		elif (not lock) and door_left.has_method("unlock"):
			door_left.call("unlock")
	else:
		push_warning("[RoomController] Aucune porte gauche détectée")

	if door_right != null:
		if lock and door_right.has_method("lock"):
			door_right.call("lock")
		elif (not lock) and door_right.has_method("unlock"):
			door_right.call("unlock")
	else:
		push_warning("[RoomController] Aucune porte droite détectée")

# ---------- Détection par groupes ----------
func _detect_by_groups() -> void:
	# Portes (les scripts Door.gd ajoutent add_to_group("door") au _ready)
	var doors_var: Array = get_tree().get_nodes_in_group("door")
	var doors: Array[Node] = []
	for d in doors_var:
		doors.append(d as Node)

	if doors.size() > 0:
		var left: Node = doors[0] as Node
		var right: Node = doors[0] as Node
		for d in doors:
			var x: float = _gx(d as Node)
			if x < _gx(left):
				left = d as Node
			if x > _gx(right):
				right = d as Node
		door_left = left
		door_right = right
		print("[RoomController] Portes détectées → gauche:", door_left.name, " (x=", _gx(door_left), "), droite:", door_right.name, " (x=", _gx(door_right), ")")
		if door_left == door_right and doors.size() >= 2:
			push_warning("[RoomController] Deux portes détectées mais même X. Vérifie leurs positions (gauche X<0, droite X>0).")
	else:
		push_warning("[RoomController] Groupe 'door' vide (portes sans script Door.gd ?)")

	# Spawner (les scripts EnemySpawner.gd ajoutent add_to_group('spawner'))
	var spawners_var: Array = get_tree().get_nodes_in_group("spawner")
	var spawners: Array[Node] = []
	for s in spawners_var:
		spawners.append(s as Node)

	if spawners.size() > 0:
		spawner = spawners[0]
		print("[RoomController] Spawner détecté → ", spawner.name)
	else:
		# Fallback : chercher un nœud avec start_wave
		spawner = _find_node_with_method(self, "start_wave")
		if spawner != null:
			print("[RoomController] Spawner détecté (fallback) → ", spawner.name)
		else:
			push_warning("[RoomController] Aucun spawner détecté (groupe 'spawner' vide et aucune méthode start_wave trouvée)")

func _gx(n: Node) -> float:
	var n2: Node2D = n as Node2D
	if n2 != null:
		return n2.global_position.x
	return 0.0

func _find_node_with_method(root: Node, method_name: String) -> Node:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var cur: Node = stack.pop_back()
		var children: Array = cur.get_children()
		for c in children:
			var child: Node = c
			stack.append(child)
			if child.has_method(method_name):
				return child
	return null
