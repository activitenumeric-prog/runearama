extends CanvasLayer

var runes := 0
@onready var rune_label: Label = $MarginContainer/VBoxContainer/HBoxRunes/Label

func _ready():
    add_to_group("ui_root")
    _refresh()

func add_rune(n: int):
    runes += n
    _refresh()

func _refresh():
    rune_label.text = "Runes: %d" % runes