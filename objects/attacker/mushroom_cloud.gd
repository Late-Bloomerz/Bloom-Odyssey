extends Area2D

var speed = 0.5

@export var damage: int = 20
var target

func _process(delta):
  global_position.y += speed * delta * 60

func is_seed_projectile() -> bool:
  return true

func piercing() -> bool:
  return true
