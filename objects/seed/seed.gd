extends Node2D
class_name Seed

@export var hp: int = 100
@export var max_hp: int = 100
@export var experience_gain: int = 10

@onready var sprite: Sprite2D = $Sprite


func is_seed() -> bool:
  return true

func _on_experience_timer_timeout():
  GameSignal.emit_signal("experience_generated", experience_gain)

func _on_hurtbox_area_entered(area):
  if area.has_method("is_enemy"):
    hp -= 10
    sprite.modulate = Color.RED
    await get_tree().create_timer(0.1).timeout
    sprite.modulate = Color.WHITE
    if hp <=0:
      remove_from_group("Seed")
      queue_free()
      GameSignal.emit_signal("seed_died", self)
