extends VBoxContainer

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var seed_texture: TextureRect = %SeedTexture
@onready var seed_cooldown: TextureProgressBar = %SeedCooldown
@onready var seed_sprite: Sprite2D = $Sprite
@onready var label: Label = $Label

@export var seed_scene: PackedScene
@export var cooldown_duration: int
@export var price: int


func _ready():
  seed_cooldown.max_value = cooldown_duration * Stats.plant_cooldown_mult * 60
  seed_cooldown.value = 0
  cooldown_timer.wait_time = cooldown_duration * Stats.plant_cooldown_mult
  label.text = str(price)


func _process(delta):
  seed_sprite.global_position = get_global_mouse_position()

  if !cooldown_timer.is_stopped():
    seed_cooldown.value -= 60 * delta


func _on_cooldown_timer_timeout():
  seed_cooldown.value = 0


func _on_mouse_entered():
  if cooldown_timer.is_stopped():
    seed_texture.modulate = Color.LIGHT_BLUE


func _on_mouse_exited():
  seed_texture.modulate = Color.WHITE

func place():
  var mouse_pos = get_tree().current_scene.get_global_mouse_position()
  var snapped_x = int(mouse_pos.x / 32) * 32
  var snapped_y = int(mouse_pos.y / 32) * 32

  var instanced_seed = seed_scene.instantiate()
  instanced_seed.global_position.x = snapped_x
  instanced_seed.global_position.y = snapped_y
  var scene = get_tree().current_scene
  scene.add_child(instanced_seed)

  cooldown_timer.start()
  seed_cooldown.value = cooldown_duration * 60
  instanced_seed.add_to_group("Seed")
  GameSignal.emit_signal("item_purchased", price)
  instanced_seed.get_node("Particle").emitting = true
