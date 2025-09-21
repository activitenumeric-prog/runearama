extends Camera2D
var _origin := Vector2.ZERO

func _ready():
    add_to_group("camera")
    _origin = offset

func shake(intensity := 8.0, duration := 0.15):
    var tween = create_tween()
    var steps := 6
    for i in range(steps):
        var dir = Vector2(randf()*2-1, randf()*2-1).normalized()
        tween.tween_property(self, "offset", _origin + dir*intensity, duration/steps)
    tween.tween_property(self, "offset", _origin, duration/steps)
