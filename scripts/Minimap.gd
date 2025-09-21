extends Control

@export var cell: int = 12

const COL_BG      := Color(0,0,0,0.6)
const COL_ROOM    := Color(0.55,0.55,0.6,1.0)
const COL_CLEAR   := Color(0.2,0.9,0.2,1.0)
const COL_START   := Color(0.2,0.6,1.0,1.0)
const COL_BOSS    := Color(0.9,0.2,0.2,1.0)
const COL_PLAYER  := Color(1,1,1,1.0)
const COL_LINK    := Color(0.35,0.35,0.45,1.0)

var rooms: Dictionary = {}          # Vector2i -> {"type": String, "neighbors": Array[Vector2i]}
var cleared: Dictionary = {}        # Set simulé: pos -> true
var origin: Vector2i = Vector2i.ZERO

func set_map(_rooms: Dictionary, _origin: Vector2i) -> void:
	rooms = _rooms
	origin = _origin
	queue_redraw()

func set_cleared_at(pos: Vector2i, is_cleared: bool) -> void:
	if is_cleared:
		cleared[pos] = true
	else:
		cleared.erase(pos)
	queue_redraw()

func _draw() -> void:
	# cadre
	draw_rect(Rect2(Vector2.ZERO, size), COL_BG, false, 1.0)

	if rooms.is_empty():
		# Juste un point au centre si pas de carte
		var c := size * 0.5
		draw_circle(c, 3.0, COL_PLAYER)
		return

	# Bornes de la grille
	var minx :=  1_000_000
	var maxx := -1_000_000
	var miny :=  1_000_000
	var maxy := -1_000_000
	for k in rooms.keys():
		var v: Vector2i = k
		if v.x < minx: minx = v.x
		if v.x > maxx: maxx = v.x
		if v.y < miny: miny = v.y
		if v.y > maxy: maxy = v.y

	var grid_w := (maxx - minx + 1)
	var grid_h := (maxy - miny + 1)
	var total_w := float(grid_w * cell)
	var total_h := float(grid_h * cell)
	var off := (size - Vector2(total_w, total_h)) * 0.5

	# Liaisons (couloirs)
	for k in rooms.keys():
		var v: Vector2i = k
		var base := _to_px(v, minx, miny, off) + Vector2(cell * 0.5, cell * 0.5)
		var nbs: Array[Vector2i] = rooms[v].get("neighbors", [] as Array[Vector2i])
		for nb in nbs:
			var nbp := _to_px(nb, minx, miny, off) + Vector2(cell * 0.5, cell * 0.5)
			draw_line(base, nbp, COL_LINK, 1.0)

	# Salles
	for k in rooms.keys():
		var v: Vector2i = k
		var r := Rect2(_to_px(v, minx, miny, off) + Vector2(1, 1), Vector2(cell - 2, cell - 2))
		var t: String = str(rooms[v].get("type", "normal"))
		var color := COL_ROOM
		if cleared.has(v):
			color = COL_CLEAR
		if t == "start":
			color = COL_START
		elif t == "boss":
			color = COL_BOSS
		draw_rect(r, color)

	# Joueur : cercle blanc au centre de la salle courante
	var p := _to_px(origin, minx, miny, off) + Vector2(cell * 0.5, cell * 0.5)
	draw_circle(p, min(3.0, cell * 0.3), COL_PLAYER)

# --- helpers ---
func _to_px(v: Vector2i, minx: int, miny: int, off: Vector2) -> Vector2:
	return off + Vector2((v.x - minx) * cell, (v.y - miny) * cell)
