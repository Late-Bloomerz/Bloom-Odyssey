extends Area2D

var target
@export var damage: int = 100

func _ready():
  damage = damage * Stats.plant_damage_mult

func is_seed_projectile() -> bool:
  return true

func piercing() -> bool:
  return true
