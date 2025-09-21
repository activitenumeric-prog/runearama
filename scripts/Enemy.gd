extends CharacterBody2D

@export var speed := 80.0
@export var damage := 1
var target: Node2D

func _ready():
	add_to_group("enemies")                                       # Tag groupe
	target = get_tree().get_first_node_in_group("player")         # Tente de choper le joueur
	if has_node("Hitbox"):
		$Hitbox.body_entered.connect(_on_hitbox_body_entered)     # Dégâts au contact

func _physics_process(delta):
	if not is_instance_valid(target):                             # Si cible perdue/non dispo
		target = get_tree().get_first_node_in_group("player")     # → on réessaye
		if not target:
			return                                                # Toujours rien ? on attend
	var dir = (target.global_position - global_position).normalized()  # Direction vers joueur
	velocity = dir * speed                                        # Vitesse
	move_and_slide()                                              # Déplacement + collision

func _on_hitbox_body_entered(body):
	if body.is_in_group("player") and body.has_method("apply_damage"):
		body.apply_damage(damage)

func die():
	queue_free()
	get_tree().call_group("managers", "on_enemy_killed")
