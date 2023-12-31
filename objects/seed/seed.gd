extends Node2D
class_name Seed

@export var hp: int = 100
@export var max_hp: int = 100
@export var experience_gain: int = 10
@export var root: PackedScene
@export var bloom_form: PackedScene
@export var bloom_duration: int
@export var with_alt: bool = false
@export var bloom_above: bool = true

@onready var sprite: Sprite2D = $Sprite
@onready var sprite_alt: Sprite2D = $SpriteAlt
@onready var bloom_timer: Timer = $BloomTimer

var bloom_pos: Vector2
var bloomed: bool = false

func _ready():
  hp = hp * Stats.plant_health_mult
  max_hp = hp * Stats.plant_health_mult



  bloom_timer.wait_time = bloom_duration
  bloom_timer.start()


func bloom(pos):
  bloomed = true
  if with_alt:
    sprite_alt.visible = true
    await get_tree().create_tween().tween_property(sprite, "modulate", Color.TRANSPARENT, 0.2).set_ease(Tween.EASE_IN_OUT).finished
    await get_tree().create_tween().tween_property(sprite_alt, "scale", Vector2(1,1), 0.2).set_ease(Tween.EASE_IN_OUT).finished
    $AnimationPlayer2.play("mengeliat")
    with_alt = false
  if bloom_above:
    var instanced_root = root.instantiate()
    add_child(instanced_root)
    instanced_root.global_position = pos
    bloom_pos = pos
    var animation: AnimationPlayer = instanced_root.get_node("Animation")
    animation.animation_finished.connect(_on_bloom)
  

func _on_bloom(_pogg):
  if bloom_above:
    if bloom_pos.y > 32:
      bloom(bloom_pos - Vector2(0, 32))
    else:
      randomize()
      final_bloom(bloom_pos - Vector2(0-16+randf_range(-10, 10), 64-32-5))


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
    hp -= area.damage
    if area.has_method("is_projectile"):
      area.queue_free()
    if sprite_alt.visible:
      sprite_alt.modulate = Color.RED
      await get_tree().create_timer(0.1).timeout
      sprite_alt.modulate = Color.WHITE
    else:
      sprite.modulate = Color.RED
      await get_tree().create_timer(0.1).timeout
      sprite.modulate = Color.WHITE
    if hp <=0:
      remove_from_group("Seed")
      queue_free()
      GameSignal.emit_signal("seed_died", self)



func _on_bloom_timer_timeout():
  bloom(global_position + Vector2(0, -32))
