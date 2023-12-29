extends CharacterBody2D

const SPEED = 10

@onready var particle: GPUParticles2D = $Particle
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var attack_cooldown_timer: Timer = $AttackCooldown
@onready var sprite: Sprite2D = $Sprite2D

@export var damage: int = 30
@export var hp: int = 100
@export var experience: int = 20
@export var money: int = 20

var closest_node
var closest_distance = 999999
var target
var targets: Array


func _ready():
  sprite.modulate = Color.TRANSPARENT
  search_target()
  GameSignal.seed_died.connect(_on_seed_died)
  var tween = get_tree().create_tween()
  await tween.tween_property(sprite, "modulate", Color.WHITE, 0.5).finished

func _physics_process(_delta):
  if target != null:
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
  if area.has_method("is_seed_projectile"):
    if !area.has_method("piercing"):
      area.queue_free()
    hp -= area.damage
    if hp <= 0:
      area.target = null
      queue_free()
      GameSignal.emit_signal("enemy_died", self)
      GameSignal.emit_signal("money_gained", money)
      GameSignal.emit_signal("experience_generated", experience)
    sprite.modulate = Color.RED
    await get_tree().create_timer(0.1).timeout
    sprite.modulate = Color.WHITE


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
