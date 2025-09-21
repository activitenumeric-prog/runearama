extends Node

@onready var room1: Node = $"../Room1"
@onready var room2: Node = $"../Room2"
@onready var door_to_room2: Node = $"../Room1/DoorToRoom2"
@onready var final_door: Node = $"../Room2/FinalDoor"

var enemies_alive_room1 := 0
var enemies_alive_room2 := 0
var elite_killed := false

func _ready():
    add_to_group("managers")
    room2.visible = false
    room2.set_process(false)
    room2.set_physics_process(false)
    enemies_alive_room1 = _count_enemies_in(room1)
    enemies_alive_room2 = _count_enemies_in(room2)
    if enemies_alive_room1 == 0 and door_to_room2.has_method("unlock"):
        door_to_room2.unlock()

func _count_enemies_in(room: Node) -> int:
    var count := 0
    for e in get_tree().get_nodes_in_group("enemies"):
        if room.is_ancestor_of(e):
            count += 1
    return count

func on_enemy_killed():
    var player = get_tree().get_first_node_in_group("player")
    if player and room1.is_ancestor_of(player):
        enemies_alive_room1 -= 1
        if enemies_alive_room1 <= 0 and door_to_room2.has_method("unlock"):
            door_to_room2.unlock()
    else:
        enemies_alive_room2 -= 1
        if elite_killed and final_door.has_method("unlock"):
            final_door.unlock()

func on_elite_killed():
    elite_killed = true
    if final_door.has_method("unlock"):
        final_door.unlock()