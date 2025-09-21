extends Node

func _ready():
    # Set player's projectile scene
    var player = $"../Player"
    if player:
        player.projectile_scene = preload("res://scenes/Projectile.tscn")
    # Wire Door target room and connect exit
    var door1 = $"../Room1/DoorToRoom2"
    if door1:
        door1.target_room_path = NodePath("../Room2")
    var exit_area = $"../Room2/ExitArea"
    if exit_area:
        exit_area.body_entered.connect(_on_exit_body_entered)

func _on_exit_body_entered(body):
    if body.is_in_group("player"):
        get_tree().change_scene_to_file("res://scenes/Victory.tscn")