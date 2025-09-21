extends Node2D
class_name Level

signal enemy_killed
signal level_cleared
signal player_died

@export var width := 48
@export var height := 30
@export var cell_size := 16
@export var walk_steps := 1200
@export var enemies_count := 6

@onready var player = $Player
@onready var enemies_root = $Enemies
@onready var walls_root = $Walls
@export var enemy_scene: PackedScene
@export var wall_scene: PackedScene

var grid := [] # 0=wall, 1=floor

func generate_level():
	# Clear previous
	for c in enemies_root.get_children():
		c.queue_free()
	for c in walls_root.get_children():
		c.queue_free()

	# Generate topology
	grid = _carve_drunkard_walk(width, height, walk_steps)
	_bake_walls(grid)

	# Place player
	var start := _find_floor_near(Vector2i(width/2, height/2))
	player.global_position = _cell_to_pos(start)

	# Spawn enemies
	var spawned := 0
	var tries := 0
	while spawned < enemies_count and tries < enemies_count * 20:
		tries += 1
		var c := Vector2i(randi() % width, randi() % height)
		if _is_floor(c) and c.distance_to(start) > 8:
			var e = enemy_scene.instantiate()
			enemies_root.add_child(e)
			e.global_position = _cell_to_pos(c)
			e.killed.connect(func(): enemy_killed.emit())
			e.player_reference = player
			spawned += 1

	# Hook deaths
	player.get_node("Stats").died.connect(func():
		player_died.emit())

func _carve_drunkard_walk(w:int, h:int, steps:int) -> Array:
	var g := []
	for y in range(h):
		var row := []
		for x in range(w):
			row.append(0) # wall
		g.append(row)
	var pos := Vector2i(w/2, h/2)
	g[pos.y][pos.x] = 1
	for i in range(steps):
		var dir: Vector2i = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)][randi() % 4]
		pos += dir
		pos.x = clamp(pos.x, 1, w-2)
		pos.y = clamp(pos.y, 1, h-2)
		g[pos.y][pos.x] = 1
	return g

func _bake_walls(g:Array) -> void:
	for y in g.size():
		for x in g[y].size():
			if g[y][x] == 0:
				var wall = wall_scene.instantiate()
				walls_root.add_child(wall)
				wall.position = Vector2(x * cell_size, y * cell_size)
				wall.set_size(Vector2(cell_size, cell_size))

func _is_floor(c:Vector2i) -> bool:
	if c.x < 0 or c.y < 0 or c.x >= width or c.y >= height:
		return false
	return grid[c.y][c.x] == 1

func _cell_to_pos(c:Vector2i) -> Vector2:
	return Vector2(c.x * cell_size + cell_size/2, c.y * cell_size + cell_size/2)

func _find_floor_near(center:Vector2i) -> Vector2i:
	if _is_floor(center): return center
	for r in range(1, max(width, height)):
		for dy in range(-r, r+1):
			for dx in range(-r, r+1):
				var p = Vector2i(center.x + dx, center.y + dy)
				if _is_floor(p):
					return p
	return Vector2i(width/2, height/2)

func check_level_clear():
	if enemies_root.get_child_count() == 0:
		level_cleared.emit()
