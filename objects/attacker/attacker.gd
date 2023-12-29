extends Seed

@onready var animation: AnimationPlayer = $AttackAnimation
@onready var attack_cooldown_timer: Timer = $AttackCooldown

@export var damage: int
@export var cooldown: float

@export var projectile_spped: int
@export var projectile_scene: PackedScene

var targets: Array
var closest_node
var target
var closest_distance = 999999
var current_velocity: Vector2 = Vector2.ZERO
var drag: float = 0.5

func _ready():
  attack_cooldown_timer.wait_time = cooldown
  GameSignal.enemy_died.connect(func(_enemy): closest_distance = 999999; search_target())
  super()


func _on_detection_range_area_entered(area):
  if area.has_method("is_enemy"):
    targets.append(area)
    if !animation.is_playing():
      animation.play("attack")
      attack_cooldown_timer.start()
      search_target()
    
func _on_detection_range_area_exited(area):
  targets.erase(area)
  closest_distance = 99999;
  search_target()
  if targets.size() <= 0:
    attack_cooldown_timer.stop()


func _on_attack_cooldown_timeout():
  attack()

func attack():
  randomize()
  if target:
    $Audio.play()
    $Particle.emitting = true
    var projectile_instance = projectile_scene.instantiate()
    projectile_instance.projectile_spped = projectile_spped
    projectile_instance.target = target
    projectile_instance.global_position = global_position + Vector2(8,8)
    var num = randi() % 4
    if num == 0:
      projectile_instance.initial_d = Vector2.UP.rotated(rotation)
    if num == 1:
      projectile_instance.initial_d = Vector2.DOWN.rotated(rotation)
    if num == 2:
      projectile_instance.initial_d = Vector2.RIGHT.rotated(rotation)
    if num == 3:
      projectile_instance.initial_d = Vector2.LEFT.rotated(rotation)
    get_tree().current_scene.add_child(projectile_instance)




func search_target():
  for node in targets:
    var distance = node.global_position.distance_to(global_position)
    if distance < closest_distance:
      closest_distance = distance
      closest_node = node
    if closest_node:
      target = closest_node
