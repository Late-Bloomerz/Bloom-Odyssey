extends Node2D
class_name Seed

@export var hp: int = 100
@export var max_hp: int = 100
@export var experience_gain: int = 10
@export var root: PackedScene
@export var bloom_form: PackedScene

@onready var sprite: Sprite2D = $Sprite
var bloom_pos: Vector2

func bloom(pos):
  var instanced_root = root.instantiate()
  add_child(instanced_root)
  instanced_root.global_position = pos
  bloom_pos = pos
  var animation: AnimationPlayer = instanced_root.get_node("Animation")
  animation.animation_finished.connect(_on_bloom)

func _on_bloom(_pogg):
  if bloom_pos.y > 16:
    bloom(bloom_pos - Vector2(0, 16))
  else:
    final_bloom(bloom_pos - Vector2(0, 32))


func final_bloom(pos):
  var instanced_root = bloom_form.instantiate()
  add_child(instanced_root)
  instanced_root.global_position = pos

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
