extends CanvasLayer

var runes := 0
@onready var rune_label: Label = $MarginContainer/VBoxContainer/HBoxRunes/Label
@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HBoxHP/ProgressBar

func _ready():
    add_to_group("ui_root")
    _refresh()

func set_hp(cur: int, maxv: int):
    hp_bar.max_value = maxv
    hp_bar.value = max(cur, 0)

func add_rune(n: int):
    runes += n
    _refresh()

func _refresh():
    rune_label.text = "Runes: %d" % runes
