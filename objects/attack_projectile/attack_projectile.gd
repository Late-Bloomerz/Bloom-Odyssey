extends Area2D

var target
var current_velocity: Vector2 = Vector2.ZERO
var drag: float = 2
var projectile_spped
var damage = 50
var initial_d = Vector2.UP.rotated(rotation)

func _ready():
  current_velocity = projectile_spped * initial_d * 0.5

func _process(delta):
  if target == null:
    fade()
  var direction: Vector2 = Vector2.UP.rotated(rotation).normalized()
  if target != null:
    direction = global_position.direction_to(target.global_position)
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
