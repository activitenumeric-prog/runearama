extends CharacterBody2D

@export var max_health: int = 3
@export var move_speed: float = 40.0

# (optionnels) sons
@export var hit_sound: AudioStream
@export var death_sound: AudioStream

var health: int = 0
var direction: Vector2 = Vector2.ZERO

var col: CollisionShape2D
var health_bg: ColorRect
var health_fg: ColorRect

func _ready() -> void:
	add_to_group("enemy")
	health = max_health

	# --- Sprite (visuel simple)
	var spr: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
	if spr == null:
		spr = Sprite2D.new()
		spr.name = "Sprite2D"
		spr.modulate = Color(1.0, 0.3, 0.3, 1.0)
		add_child(spr)

	# --- Collision rectangle 12x12
	col = get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col == null:
		col = CollisionShape2D.new()
		col.name = "CollisionShape2D"
		var rs: RectangleShape2D = RectangleShape2D.new()
		rs.size = Vector2(12.0, 12.0)
		col.shape = rs
		add_child(col)
	elif col.shape == null:
		var rs2: RectangleShape2D = RectangleShape2D.new()
		rs2.size = Vector2(12.0, 12.0)
		col.shape = rs2

	# --- Mini barre de vie
	var hb: Node2D = get_node_or_null("HealthBar") as Node2D
	if hb == null:
		hb = Node2D.new()
		hb.name = "HealthBar"
		hb.position = Vector2(0, -16)
		add_child(hb)

	health_bg = hb.get_node_or_null("Background") as ColorRect
	if health_bg == null:
		health_bg = ColorRect.new()
		health_bg.name = "Background"
		health_bg.color = Color(0, 0, 0, 1)
		health_bg.position = Vector2(-10, 0)
		health_bg.size = Vector2(20, 3)
		hb.add_child(health_bg)

	health_fg = hb.get_node_or_null("Foreground") as ColorRect
	if health_fg == null:
		health_fg = ColorRect.new()
		health_fg.name = "Foreground"
		health_fg.color = Color(0, 1, 0, 1)
		health_fg.position = Vector2(-10, 0)
		health_fg.size = Vector2(20, 3)
		hb.add_child(health_fg)

	# Direction de départ aléatoire
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.randomize()
	direction = Vector2(rng.randf_range(-1.0, 1.0), rng.randf_range(-1.0, 1.0)).normalized()
	_update_bar()

func _physics_process(_delta: float) -> void:
	velocity = direction * move_speed
	move_and_slide()

func take_damage(amount: int) -> void:
	health = max(0, health - amount)

	if hit_sound:
		var s: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		s.stream = hit_sound
		add_child(s)
		s.play()

	modulate = Color(1.0, 0.6, 0.6, 1.0)
	_update_bar()
	await get_tree().create_timer(0.08).timeout
	modulate = Color(1.0, 1.0, 1.0, 1.0)

	if health == 0:
		_on_death()

func _on_death() -> void:
	if death_sound:
		var s: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		s.stream = death_sound
		add_child(s)
		s.play()
	queue_free()

func _update_bar() -> void:
	if health_fg == null or health_bg == null:
		return
	var ratio: float = clamp(float(health) / float(max_health), 0.0, 1.0)
	var w: float = health_bg.size.x * ratio
	var sz: Vector2 = health_fg.size
	sz.x = w
	health_fg.size = sz
	health_fg.position = health_bg.position
