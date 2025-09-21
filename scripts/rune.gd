extends Area2D

@onready var timer: Timer = $Timer

func _ready():
    body_entered.connect(_on_body_entered)
    timer.wait_time = 5.0
    timer.one_shot = true
    timer.timeout.connect(_on_Timer_timeout)
    timer.start()

func _on_body_entered(body):
    if body.is_in_group("player"):
        if body.has_method("collect_rune"):
            body.collect_rune()
        _play_sfx("res://ressources/sounds/rune.wav")
        queue_free()

func _on_Timer_timeout():
    queue_free()

func _play_sfx(path: String):
    if not ResourceLoader.exists(path):
        return
    var s = AudioStreamPlayer.new()
    add_child(s)
    s.stream = load(path)
    s.play()
