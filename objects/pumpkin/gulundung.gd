extends Area2D

var target
var current_velocity: Vector2 = Vector2.ZERO
var drag: float = 2
var projectile_spped = 200
var damage = 50

func _ready():
  damage = damage * Stats.plant_damage_mult


func _process(delta):
  rotation += 15 * delta
  var direction: Vector2 = Vector2.ZERO
  if target != null:
    direction = global_position.direction_to(target).normalized()
  var desired_velocity = direction * projectile_spped
  var change = (desired_velocity - current_velocity) * drag
  current_velocity += change * delta
  global_position += current_velocity * delta

func fade():
  var tween = get_tree().create_tween()
  await tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5).finished
  queue_free()


func is_seed_projectile() -> bool:
  return true

func piercing() -> bool:
  return true

func pumpkin() -> bool:
  return true


func _on_duration_timeout():
  await get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.2).set_ease(Tween.EASE_IN_OUT).finished
  queue_free()
