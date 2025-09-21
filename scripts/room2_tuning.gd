extends Node2D
## Petit ajustement de difficulté pour Room2 : accélère un peu les ennemis.
func _ready():
    for e in get_tree().get_nodes_in_group("enemies"):
        if is_ancestor_of(e):
            e.speed = 100.0  # Room2 un peu plus rapide
