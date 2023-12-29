# Extend node type
# Must the same type with the node which the script attache into
extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var experience_bar: TextureProgressBar = %ExperienceBar
@onready var timer_label: Label = %TimerLabel
@onready var tilemap: TileMap = $TileMap
@onready var spawn_timer: Timer = $SpawnTimer

@export var easy_enemy: PackedScene
@export var init_seed: PackedScene

var scrolling_left: bool = false
var scrolling_right: bool = false
var scrolling_top: bool = false
var scrolling_bottom: bool = false

var level_second_elapsed: int = 1

var current_level: int = 1
var exp_to_level_up: int = 100
var current_exp: int = 0

var game_started: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
  $Shop.visible = false
  $CameraScroll.visible = false
  $Experience.visible = false
  $LevelTimerCanvas.visible = false
  GameSignal.experience_generated.connect(_on_experience_generated)
  GameSignal.game_started.connect(_on_game_started)

  print("==Level started==")

func _on_game_started() -> void:
  game_started = true
  $Shop.visible = true
  $CameraScroll.visible = true
  $Experience.visible = true
  $LevelTimerCanvas.visible = true
  camera.global_translate(Vector2(0,475))
  $Menu.visible = false
  $MenuBgm.playing = false
  $GameBgm.playing = true
  var inst = init_seed.instantiate()
  inst.global_position = Vector2(672, 384)
  add_child(inst)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
  pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
# For physic
func _physics_process(delta):
  if !game_started:
    return
  if scrolling_left:
    camera.global_position.x -= 4 * delta * 60
  if scrolling_right:
    camera.global_position.x += 4 * delta * 60
  if scrolling_top:
    camera.global_translate(Vector2(0,global_position.y - 4 * delta *60))
    #camera.global_position.y -= 4 * delta * 60
  if scrolling_bottom:
    camera.global_position.y += 4 * delta * 60
  

func _unhandled_input(event):
  if event.is_action_pressed("scroll_top"):
    scrolling_top = true
  if event.is_action_released("scroll_top"):
    scrolling_top = false

  if event.is_action_pressed("scroll_right"):
    scrolling_right = true
  if event.is_action_released("scroll_right"):
    scrolling_right = false

  if event.is_action_pressed("scroll_bot"):
    scrolling_bottom = true
  if event.is_action_released("scroll_bot"):
    scrolling_bottom = false

  if event.is_action_pressed("scroll_left"):
    scrolling_left = true
  if event.is_action_released("scroll_left"):
    scrolling_left = false

func _on_experience_generated(value: int):
  current_exp += value
  experience_bar.value = current_exp
  if current_exp >= exp_to_level_up:
    current_level += 1
    experience_bar.value = 0
    current_exp = 0
    exp_to_level_up = exp_to_level_up +  (100 + current_level / 5)
    experience_bar.max_value = exp_to_level_up 
    GameSignal.emit_signal("money_gained", 100)

  


func _on_left_mouse_entered():
  scrolling_left = true
func _on_left_mouse_exited():
  scrolling_left = false
func _on_top_mouse_entered():
  scrolling_top = true
func _on_top_mouse_exited():
  scrolling_top = false
func _on_right_mouse_entered():
  scrolling_right = true
func _on_right_mouse_exited():
  scrolling_right = false
func _on_bottom_mouse_entered():
  scrolling_bottom = true
func _on_bottom_mouse_exited():
  scrolling_bottom = false


func _on_level_timer_timeout():
  if !game_started:
    return
  level_second_elapsed += 1
  timer_label.text = secondsToTimeString(level_second_elapsed)
  
func secondsToTimeString(seconds: int) -> String:
  var minutes = seconds / 60
  var remainingSeconds = seconds % 60
  return String.num(minutes).pad_zeros(2) + ":" + String.num(remainingSeconds).pad_zeros(2)


func _on_spawn_timer_timeout():
  if get_tree().get_nodes_in_group("Seed").size() ==0:
    return

  randomize()
  if level_second_elapsed > 0 && level_second_elapsed < 30:
    for n in range(2):
      var enemy_instance = easy_enemy.instantiate()
      var seeds: Array = get_tree().get_nodes_in_group("Seed")
      var choosen_seed = seeds[randi() % seeds.size()];
      enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-50,100), randf_range(-50,100))
      add_child(enemy_instance)
  if level_second_elapsed >  30 && level_second_elapsed < 60:
    spawn_timer.wait_time = 8
    for n in range(3):
      var enemy_instance = easy_enemy.instantiate()
      var seeds: Array = get_tree().get_nodes_in_group("Seed")
      var choosen_seed = seeds[randi() % seeds.size()];
      enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-50,100), randf_range(-50,100))
      add_child(enemy_instance)
  if level_second_elapsed >  60 && level_second_elapsed < 90:
    spawn_timer.wait_time = 7
    for n in range(4):
      var enemy_instance = easy_enemy.instantiate()
      var seeds: Array = get_tree().get_nodes_in_group("Seed")
      var choosen_seed = seeds[randi() % seeds.size()];
      enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-50,100), randf_range(-50,100))
      add_child(enemy_instance)
    
  
