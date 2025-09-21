extends Area2D
signal door_opened

@export var locked := true
@export var target_room_path: NodePath

func _ready():
    _update_visuals()

func lock():
    locked = true
    _update_visuals()

func unlock():
    if locked:
        locked = false
        _update_visuals()
        _reveal_target_room()
        door_opened.emit()

func _update_visuals():
    if has_node("OpenSprite"):
        $OpenSprite.visible = not locked
    if has_node("LockedSprite"):
        $LockedSprite.visible = locked
    if has_node("Blocker"):
        $Blocker/CollisionShape2D.disabled = not locked

func _reveal_target_room():
    if target_room_path != NodePath():
        var room = get_node_or_null(target_room_path)
        if room:
            room.visible = true
            room.set_process(true)
            room.set_physics_process(true)