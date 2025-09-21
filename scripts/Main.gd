extends Node2D

@onready var level = $Level
@onready var ui = $UI/HUD
var lives := 3
var score := 0

func _ready():
	level.generate_level()
	level.enemy_killed.connect(_on_enemy_killed)
	level.level_cleared.connect(_on_level_cleared)
	level.player_died.connect(_on_player_died)

func _on_enemy_killed():
	score += 10
	ui.set_score(score)
	level.check_level_clear()

func _on_level_cleared():
	score += 100
	ui.show_message("Niveau terminé ! +100 points")
	await get_tree().create_timer(1.0).timeout
	level.generate_level()

func _on_player_died():
	lives -= 1
	ui.set_lives(lives)
	if lives <= 0:
		ui.show_message("Game Over")
		await get_tree().create_timer(2.0).timeout
		lives = 3
		score = 0
		ui.set_score(score)
		ui.set_lives(lives)
	level.generate_level()
