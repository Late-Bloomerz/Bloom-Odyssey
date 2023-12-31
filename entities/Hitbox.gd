extends Area2D

var damage = 20

func _ready():
  damage = damage * Stats.enemy_damage_mult

func is_enemy() -> bool:
  return true
