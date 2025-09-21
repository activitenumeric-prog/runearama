extends Control

@onready var hp_bar = $Margin/VBox/HP
@onready var mana_bar = $Margin/VBox/Mana
@onready var label = $Margin/VBox/Label
@onready var score_lbl = $Margin/VBox/Score
@onready var lives_lbl = $Margin/VBox/Lives

func set_score(v:int):
    score_lbl.text = "Score: %d" % v

func set_lives(v:int):
    lives_lbl.text = "Vies: %d" % v

func update_hp(curr:int, maxv:int):
    hp_bar.max_value = maxv
    hp_bar.value = curr

func update_mana(curr:int, maxv:int):
    mana_bar.max_value = maxv
    mana_bar.value = curr

func show_message(t:String):
    label.text = t
    label.modulate.a = 1.0
    await get_tree().create_timer(2.0).timeout
    label.modulate.a = 0.0