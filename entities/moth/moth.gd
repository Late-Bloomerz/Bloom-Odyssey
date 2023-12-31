extends Enemy

@export var projectile: PackedScene
@export var projectile_speed: int = 100

func _physics_process(_delta):
  if target != null:
    if global_position.distance_to(target.global_position) > 200:
      velocity = global_position.direction_to(target.global_position) * SPEED
    else:
      velocity = Vector2.ZERO

    if flip:
      var mouse_direction = (global_position- target.global_position ).normalized()
      if mouse_direction.x < 0 and sign(sprite.scale.x) != sign(mouse_direction.x):
        sprite.scale.x *= -1
      elif mouse_direction.x > 0 and sign(sprite.scale.x) != sign(mouse_direction.x):
        sprite.scale.x *= -1
  move_and_slide()
  if target !=null:
    look_at(target.global_position)

func attack_func():
  if target != null :

    var nodes = get_tree().get_nodes_in_group("Seed")
    for node in nodes:
      var projectile_instance = projectile.instantiate()
      projectile_instance.projectile_spped = projectile_speed
      projectile_instance.target = node
      projectile_instance.global_position = global_position + Vector2(-8,0)
      projectile_instance.initial_d = Vector2.LEFT.rotated(rotation)
      get_tree().current_scene.add_child(projectile_instance)



