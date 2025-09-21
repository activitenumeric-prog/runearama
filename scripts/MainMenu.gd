extends Control

@onready var start_btn: Button = $Center/VBox/Start
@onready var cont_btn: Button = $Center/VBox/Continue
@onready var opt_btn: Button = $Center/VBox/Options
@onready var quit_btn: Button = $Center/VBox/Quit
@onready var options_panel: Panel = $OptionsPanel
@onready var chk_fullscreen: CheckBox = $OptionsPanel/VBox/Fullscreen
@onready var sli_master: HSlider = $OptionsPanel/VBox/Master/H
@onready var sli_sfx: HSlider = $OptionsPanel/VBox/SFX/H
@onready var sli_music: HSlider = $OptionsPanel/VBox/Music/H
@onready var btn_apply: Button = $OptionsPanel/VBox/Buttons/Apply
@onready var btn_close: Button = $OptionsPanel/VBox/Buttons/Close

func _ready() -> void:
	var s: Dictionary = SaveSystem.get_settings()
	SaveSystem.apply_settings(s)
	_settings_to_ui(s)

	start_btn.pressed.connect(_on_start)
	cont_btn.pressed.connect(_on_continue)
	opt_btn.pressed.connect(_toggle_options)
	quit_btn.pressed.connect(_on_quit)
	btn_apply.pressed.connect(_on_apply_settings)
	btn_close.pressed.connect(_toggle_options)

	cont_btn.disabled = not SaveSystem.has_save()
	options_panel.visible = false

func _on_start() -> void:
	SaveSystem.pending_continue = false
	SaveSystem.delete_save()
	get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _on_continue() -> void:
	if SaveSystem.has_save():
		SaveSystem.request_continue()
		get_tree().change_scene_to_file("res://scenes/Game.tscn")

func _toggle_options() -> void:
	options_panel.visible = not options_panel.visible

func _on_apply_settings() -> void:
	var s := {
		"fullscreen": chk_fullscreen.button_pressed,
		"master": float(sli_master.value),
		"sfx": float(sli_sfx.value),
		"music": float(sli_music.value)
	}
	SaveSystem.save_settings(s)
	SaveSystem.apply_settings(s)

func _on_quit() -> void:
	get_tree().quit()

func _settings_to_ui(s: Dictionary) -> void:
	chk_fullscreen.button_pressed = bool(s.get("fullscreen", false))
	sli_master.min_value = 0.0; sli_master.max_value = 1.0; sli_master.step = 0.01
	sli_sfx.min_value = 0.0;    sli_sfx.max_value = 1.0;    sli_sfx.step = 0.01
	sli_music.min_value = 0.0;  sli_music.max_value = 1.0;  sli_music.step = 0.01
	sli_master.value = float(s.get("master", 0.8))
	sli_sfx.value = float(s.get("sfx", 0.8))
	sli_music.value = float(s.get("music", 0.6))
