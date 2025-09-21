extends Resource
class_name Spell

@export var name: String
@export var mana_cost: int = 5
@export var cooldown: float = 0.5
@export var projectile_scene: PackedScene
@export var speed: float = 400.0
@export var damage: int = 1