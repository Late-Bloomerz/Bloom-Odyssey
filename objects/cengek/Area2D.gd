extends Area2D

var target
@export var damage: int = 100

func is_seed_projectile() -> bool:
  return true

func piercing() -> bool:
  return true
