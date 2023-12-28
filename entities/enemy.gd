extends CharacterBody2D

const SPEED = 10

@onready var particle: GPUParticles2D = $Particle
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var attack_cooldown_timer: Timer = $AttackCooldown

var closest_node
var closest_distance = 999999
var target
var targets: Array

var game_started = false

func _ready():
  search_target()
  GameSignal.game_started.connect(func(): game_started = true)
  GameSignal.seed_died.connect(_on_seed_died)

func _physics_process(_delta):
  if target != null && game_started:
    velocity = global_position.direction_to(target.global_position) * SPEED
  move_and_slide()

func search_target():
  var nodes = get_tree().get_nodes_in_group("Seed")
  for node in nodes:
    var distance = node.global_position.distance_to(global_position)
    if distance < closest_distance:
      closest_distance = distance
      closest_node = node
    if closest_node:
      target = closest_node

func _on_change_target_timer_timeout():
  search_target()

func _on_seed_died(died_seed):
  targets.erase(died_seed)
  target = null
  closest_distance = 999999

func _on_hurtbox_area_entered(area):
  pass # Replace with function body.

func _on_attack_radius_area_entered(area):
  if area.has_method("is_seed"):
    targets.append(area)
    if !animation.is_playing():
      animation.play("attack")
      attack_cooldown_timer.start()
  
func _on_attack_radius_area_exited(area):
  targets.erase(area)
  if targets.size() <= 0:
    attack_cooldown_timer.stop()

func _on_attack_cooldown_timeout():
  if targets.size() > 0:
    animation.play("attack")
