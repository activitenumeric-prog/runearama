extends CharacterBody2D

@export var max_health: int = 3
@export var move_speed: float = 40.0

# ✅ Nouveaux sons
@export var hit_sound: AudioStream
@export var death_sound: AudioStream

var health: int
var direction: Vector2
@onready var health_bar := $HealthBar

func _ready() -> void:
	add_to_group("enemy")
	health = max_health
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	_update_bar()

func _physics_process(_delta: float) -> void:
	velocity = direction * move_speed
	move_and_slide()

func take_damage(amount: int) -> void:
	health = max(0, health - amount)

	# ✅ jouer le son de hit
	if hit_sound:
		var s := AudioStreamPlayer2D.new()
		s.stream = hit_sound
		add_child(s)
		s.play()

	modulate = Color.RED
	_update_bar()
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE

	if health == 0:
		_on_death()

func _on_death() -> void:
	# ✅ jouer le son de mort
	if death_sound:
		var s := AudioStreamPlayer2D.new()
		s.stream = death_sound
		add_child(s)
		s.play()
	queue_free()

func _update_bar() -> void:
	if health_bar and health_bar.has_method("set_ratio"):
		var r := float(health) / float(max_health)
		health_bar.set_ratio(r)
