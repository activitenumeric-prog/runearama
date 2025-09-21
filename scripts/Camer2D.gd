extends Camera2D
# Suivi auto du Player, lissage, et recherche tardive via groupe

@export var enable_smoothing := true       # active le lissage
@export var cam_smoothing_speed := 5.0     # vitesse de lissage
@export var extra_margin := 0              # marge aux limites (si tu les utilises plus tard)

var target: Node2D = null                  # référence vers le Player (trouvée à chaud)

func _ready() -> void:
	enabled = true             # active la caméra
	make_current()             # et la rend courante tout de suite
	position_smoothing_enabled = enable_smoothing
	position_smoothing_speed = cam_smoothing_speed

func _process(_delta: float) -> void:
	# Si on n'a pas encore de cible, on essaie de la trouver (spawn tardif)
	if target == null:
		target = get_tree().get_first_node_in_group("player") as Node2D
		# Tu peux logger une seule fois quand ça marche :
		if target != null:
			print("[Camera] Player trouvé :", target.get_path())

	# Suivi simple de la cible (coordonnées globales)
	if target:
		global_position = target.global_position
