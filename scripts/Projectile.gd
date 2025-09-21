extends Area2D

@export var speed := 520.0             # Vitesse du projectile
var direction := Vector2.RIGHT         # Direction de vol

func _ready():
	area_entered.connect(_on_area_entered)   # Quand on touche une Area2D
	body_entered.connect(_on_body_entered)   # Quand on touche un Body2D

func set_direction(d: Vector2):
	direction = d.normalized()               # Normalise la direction
	rotation = direction.angle()             # Oriente le sprite si besoin

func _physics_process(delta):
	global_position += direction * speed * delta   # Avance tout droit

# --- Nouveau : fonction utilitaire impact ---
func _play_impact_sfx():
	var path := "res://ressources/sounds/impact.wav"   # Chemin du son
	if not ResourceLoader.exists(path):
		return                                         # Pas de fichier → rien
	var s := AudioStreamPlayer2D.new()                 # Lecteur 2D (spatial)
	s.global_position = global_position                # Joue au point d'impact
	s.stream = load(path)                              # Charge le .wav
	get_tree().current_scene.add_child(s)              # Ajoute à la scène
	s.play()                                           # Lance le son
	s.finished.connect(s.queue_free)                   # Auto-nettoyage

# --- Factorisation du hit ennemi ---
func _hit_enemy(target):
	if target.is_in_group("enemies"):                  # S'assure que c'est un ennemi
		if target.has_method("apply_damage"):
			target.apply_damage(1)                     # Inflige 1 dégât
		if target.has_method("die"):
			target.die()                               # Tue l'ennemi (proto)
		_play_impact_sfx()                             # <<< joue le son
		queue_free()                                   # Détruit le projectile

func _on_area_entered(a):
	_hit_enemy(a)                                      # Délègue

func _on_body_entered(b):
	_hit_enemy(b)                                      # Délègue
