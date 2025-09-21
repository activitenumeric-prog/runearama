extends Control

@onready var start_btn: Button = $Center/VBox/Start
@onready var cont_btn: Button = $Center/VBox/Continue
@onready var opt_btn: Button = $Center/VBox/Options
@onready var quit_btn: Button = $Center/VBox/Quit
@onready var options_panel: Panel = $OptionsPanel

func _ready() -> void:
    start_btn.pressed.connect(_on_start)
    cont_btn.pressed.connect(_on_continue)
    opt_btn.pressed.connect(_on_options)
    quit_btn.pressed.connect(_on_quit)
    options_panel.visible = false
    cont_btn.disabled = not FileAccess.file_exists("user://savegame.json")

func _on_start() -> void:
    get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_continue() -> void:
    get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_options() -> void:
    options_panel.visible = not options_panel.visible

func _on_quit() -> void:
    get_tree().quit()
