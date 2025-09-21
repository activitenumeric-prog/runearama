class_name DungeonGen
extends Node

@export var width: int = 5
@export var height: int = 5
@export var max_steps: int = 12
@export var seed: int = 0

# Dictionnaire : { Vector2i : {"type": String, "neighbors": Array[Vector2i]} }
var rooms: Dictionary = {}

# Directions typées
const DIRS: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

signal dungeon_generated(rooms: Dictionary)

func generate() -> void:
	rooms.clear()
	var rng := RandomNumberGenerator.new()
	if seed == 0:
		rng.randomize()
	else:
		rng.seed = seed

	var start: Vector2i = Vector2i(width / 2, height / 2)
	var pos: Vector2i = start
	_ensure_room(pos)

	# IMPORTANT : utiliser range(max_steps) en Godot 4
	for i in range(max_steps):
		var choices: Array[Vector2i] = []
		for d in DIRS:
			var np: Vector2i = pos + d
			if _in_bounds(np):
				choices.append(np)
		if choices.is_empty():
			break
		var next: Vector2i = choices[rng.randi_range(0, choices.size() - 1)]
		_ensure_room(next)
		_link(pos, next)
		pos = next

	if rooms.has(start):
		rooms[start]["type"] = "start"
	var far: Vector2i = _farthest_from(start)
	if rooms.has(far):
		rooms[far]["type"] = "boss"

	dungeon_generated.emit(rooms)

func _ensure_room(p: Vector2i) -> void:
	if not rooms.has(p):
		rooms[p] = {"type": "normal", "neighbors": []}

func _link(a: Vector2i, b: Vector2i) -> void:
	var nbs_a: Array = rooms[a].get("neighbors", [])
	if not nbs_a.has(b):
		nbs_a.append(b)
	rooms[a]["neighbors"] = nbs_a

	_ensure_room(b)
	var nbs_b: Array = rooms[b].get("neighbors", [])
	if not nbs_b.has(a):
		nbs_b.append(a)
	rooms[b]["neighbors"] = nbs_b

func _in_bounds(p: Vector2i) -> bool:
	return p.x >= 0 and p.x < width and p.y >= 0 and p.y < height

func _farthest_from(src: Vector2i) -> Vector2i:
	var q: Array[Vector2i] = [src]
	var dist := {src: 0}
	var last: Vector2i = src
	while not q.is_empty():
		var cur: Vector2i = q.pop_front() # cast implicite OK si l'array est typée
		last = cur
		var neighbors: Array = rooms[cur].get("neighbors", [])
		for nb in neighbors:
			var nbv: Vector2i = nb
			if not dist.has(nbv):
				dist[nbv] = dist[cur] + 1
				q.append(nbv)
	return last
