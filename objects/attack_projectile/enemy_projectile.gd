extends Projectile


func _ready():
  super()
  damage = damage * Stats.enemy_damage_mult

func is_enemy() -> bool:
  return true

func is_projectile() -> bool:
  return true
