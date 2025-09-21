extends CharacterBody2D
# Corps 2D avec collisions

@export var move_speed: float = 200.0   # Vitesse en px/s
var input_dir := Vector2.ZERO           # Direction de déplacement (x,y)
var facing := Vector2.DOWN              # Dernière direction utile pour tirer

@onready var stats = $Stats             # Réf. vers tes nœuds (inchangé)
@onready var caster = $Caster

signal fired

func _ready() -> void:
	add_to_group("player")              # ← utile pour que la caméra te retrouve
	# print("[Player] READY at:", global_position)  # (debug optionnel)

func _physics_process(_delta: float) -> void:
	# --- CLAVIER UNIQUEMENT (aucun joystick/axe lu) ---
	# Chaque booléen devient 0 ou 1, on fait droite-gauche / bas-haut
	var x := int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	var y := int(Input.is_action_pressed("ui_down"))  - int(Input.is_action_pressed("ui_up"))
	input_dir = Vector2(x, y)           # ex: (1,0), (-1,0), (0,1), (0,-1), (0,0)

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()  # vitesse constante en diagonale
		facing = input_dir                  # maj de la direction “visée”

	velocity = input_dir * move_speed    # applique la vitesse
	move_and_slide()                     # gère les collisions

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		shoot()
	if Input.is_action_just_pressed("cast"):
		caster.cast_current()
	if Input.is_action_just_pressed("switch_spell_next"):
		caster.next_spell()
	if Input.is_action_just_pressed("switch_spell_prev"):
		caster.prev_spell()

func shoot() -> void:
	var p := preload("res://scenes/Projectile.tscn").instantiate()
	p.global_position = global_position
	p.dir = facing
	p.damage = 1
	get_tree().current_scene.add_child(p)
	fired.emit()
