extends Control

var is_casting: bool = false
var casted_seed: String
@onready var seed_sprite: Sprite2D = $SeedSprite
@onready var tilemap: TileMap = get_parent().get_parent().get_node("TileMap")
@onready var seed_cooldown: TextureProgressBar = %SeedCooldown
@onready var seed_cooldown_timer: Timer = $SeedCooldownTimer

@export var seed_scene: PackedScene
@export var seed_cooldown_duration: int

var placed_mushroom: Array[Vector2] = [Vector2(688, 384)]

func _ready():
  seed_cooldown.max_value = seed_cooldown_duration * 60
  seed_cooldown.value = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  seed_sprite.global_position = get_global_mouse_position()
  if !seed_cooldown_timer.is_stopped():
    seed_cooldown.value -= 60 * delta


func _unhandled_input(event):
  if event.is_action_pressed("left_click"):
      var mouse_position = get_tree().current_scene.get_global_mouse_position()
      var mouse_position_to_tile_position = tilemap.local_to_map(mouse_position)
      if check_custom_data(mouse_position_to_tile_position, "is_dirt", 0):
        var mouse_pos = get_tree().current_scene.get_global_mouse_position()
        var snapped_x = int(mouse_pos.x / 16) * 16
        var snapped_y = int(mouse_pos.y / 16) * 16
        if casted_seed == "seed" && !placed_mushroom.has(Vector2(snapped_x, snapped_y)):
          var instanced_seed = seed_scene.instantiate()
          instanced_seed.global_position.x = snapped_x
          instanced_seed.global_position.y = snapped_y
          var scene = get_tree().current_scene
          scene.add_child(instanced_seed)
          is_casting = false
          casted_seed = ""
          seed_sprite.visible = false
          placed_mushroom.append(Vector2(snapped_x, snapped_y))
          $Plant.play()
          seed_cooldown_timer.start()
          seed_cooldown.value = seed_cooldown_duration * 60
          instanced_seed.add_to_group("Seed")


func _on_margin_container_gui_input(event: InputEvent):
  if event.is_action_pressed("left_click") && seed_cooldown_timer.is_stopped():
    seed_sprite.visible = true
    await get_tree().create_timer(0.1).timeout
    is_casting = true
    casted_seed = "seed"
  if event.is_action_pressed("left_click") && !seed_cooldown_timer.is_stopped():
    print("Sedang Cooldown")

func check_custom_data(mouse_pos, custom_data_variable,layer):
  var tile_data: TileData = tilemap.get_cell_tile_data(layer,mouse_pos)
  if tile_data:
    return tile_data.get_custom_data(custom_data_variable)
  else:
    return false

func _on_seed_cooldown_timer_timeout():
  seed_cooldown.value -= 1

func _on_seed_cooldown_timer_duration_timeout():
  seed_cooldown.value = 0
