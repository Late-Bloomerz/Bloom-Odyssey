# Extend node type
# Must the same type with the node which the script attache into
extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var experience_bar: TextureProgressBar = %ExperienceBar
@onready var timer_label: Label = %TimerLabel
@onready var tilemap: TileMap = $TileMap
@onready var spawn_timer: Timer = $SpawnTimer
@onready var black: Sprite2D = %BlackS

@export var easy_enemy: PackedScene
@export var bee_enemy: PackedScene
@export var moth_enemy: PackedScene
@export var init_seed: PackedScene

var scrolling_left: bool = false
var scrolling_right: bool = false
var scrolling_top: bool = false
var scrolling_bottom: bool = false

var level_second_elapsed: int = 0


var current_level: int = 1
var exp_to_level_up: float = 100
var current_exp: int = 0
var enemies

var game_started: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
  $Shop.visible = false
  $CameraScroll.visible = false
  $Experience.visible = false
  $LevelTimerCanvas.visible = false
  $LevelCanvas.visible = false
  %MainMenu.visible = false
  %ProgressLevel.visible = false
  %MainMenu.modulate = Color.TRANSPARENT
  GameSignal.experience_generated.connect(_on_experience_generated)
  GameSignal.game_started.connect(_on_game_started)
  GameSignal.seed_died.connect(_on_seed_died)
  black.visible = true
  get_tree().create_tween().tween_property(black, "modulate", Color.TRANSPARENT, 1).set_ease(Tween.EASE_IN_OUT)
  await get_tree().create_tween().tween_property(camera, "global_position", Vector2(704,-65), 3).set_ease(Tween.EASE_IN_OUT).finished
  %MainMenu.visible = true
  get_tree().create_tween().tween_property(%MainMenu, "modulate", Color.WHITE, 1).set_ease(Tween.EASE_IN_OUT)


  print("==Level started==")

func _on_game_started() -> void:
  enemies = [easy_enemy, bee_enemy]
  game_started = true
  $Shop.visible = true
  $CameraScroll.visible = true
  $Experience.visible = true
  $LevelTimerCanvas.visible = true
  %ProgressLevel.visible = true
  $LevelCanvas.visible = true
  camera.global_translate(Vector2(0,475))
  $Menu.visible = false
  $MenuBgm.playing = false
  $GameBgm.playing = true
  var inst = init_seed.instantiate()
  inst.global_position = Vector2(672, 384)
  inst.add_to_group("Seed")
  add_child(inst)
  spawn_timer.start()

func _on_seed_died(_seed) -> void:
  var nodes = get_tree().get_nodes_in_group("Seed")
  if nodes.size() <= 0:
    $GameOver.visible = true
    $Shop.visible = false
    $CameraScroll.visible = false
    $Experience.visible = false
    $LevelTimerCanvas.visible = false
    $LevelCanvas.visible = false
    get_tree().create_tween().tween_property($GameBgm, "volume_db", -23, 2).set_ease(Tween.EASE_IN_OUT)
    $SoundOver.play()
    get_tree().create_tween().tween_property(%GameOverUi, "modulate", Color.WHITE, 0.2).set_ease(Tween.EASE_IN_OUT)


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
    %ExperienceL.text  = "Level: " + str(current_level)
    experience_bar.value = 0
    current_exp = 0
    exp_to_level_up += log(exp_to_level_up) * 100
    experience_bar.max_value = exp_to_level_up 
    GameSignal.emit_signal("money_gained", 100)
    level_up_sequence()

func level_up_sequence():
  get_tree().paused = true
  $Goddess.visible = true
  %Nuper.modulate = Color.TRANSPARENT
  %Bgd.modulate = Color.TRANSPARENT
  %NupLabel.modulate = Color.TRANSPARENT
  get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(%Nuper, "modulate", Color.WHITE, 0.5).set_ease(Tween.EASE_IN_OUT)
  get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(%NupLabel, "modulate", Color.WHITE, 0.5).set_ease(Tween.EASE_IN_OUT)
  get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(%Nuper, "global_position", Vector2(192, 475), 0.5).set_ease(Tween.EASE_IN_OUT)
  get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(%Bgd, "modulate", Color(255,255,255,0.5), 0.5).set_ease(Tween.EASE_IN_OUT)

  


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
  %ProgressLevel.value = level_second_elapsed
  timer_label.text = secondsToTimeString(level_second_elapsed)
  if level_second_elapsed == 60:
    Stats.enemy_damage_mult = 1.5
    Stats.enemy_health_mult = 1.5
  if level_second_elapsed == 120 * 2:
    Stats.enemy_damage_mult = 2
    Stats.enemy_health_mult = 2
  if level_second_elapsed == 180 * 2:
    Stats.enemy_damage_mult = 2.5
    Stats.enemy_health_mult = 2.5
  if level_second_elapsed == 240 * 2:
    Stats.enemy_damage_mult = 3
    Stats.enemy_health_mult = 3

  if level_second_elapsed > 600:
    %EndTitle.text = "You Win"
    $GameOver.visible = true
    $Shop.visible = false
    $CameraScroll.visible = false
    $Experience.visible = false
    $LevelTimerCanvas.visible = false
    $LevelCanvas.visible = false
    get_tree().create_tween().tween_property($GameBgm, "volume_db", -23, 2).set_ease(Tween.EASE_IN_OUT)
    get_tree().create_tween().tween_property(%GameOverUi, "modulate", Color.WHITE, 0.2).set_ease(Tween.EASE_IN_OUT)
  
func secondsToTimeString(seconds: int) -> String:
  var minutes = seconds / 60
  var remainingSeconds = seconds % 60
  return String.num(minutes).pad_zeros(2) + ":" + String.num(remainingSeconds).pad_zeros(2)


func _on_spawn_timer_timeout():
  if get_tree().get_nodes_in_group("Seed").size() ==0:
    return

  randomize()
  if level_second_elapsed > 0 && level_second_elapsed < 30:
    if level_second_elapsed % 5 == 0:
      for n in range(1):
        var enemy_instance = easy_enemy.instantiate()
        var seeds: Array = get_tree().get_nodes_in_group("Seed")
        var choosen_seed = seeds[randi() % seeds.size()];
        enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-150,150), randf_range(-150,150))
        add_child(enemy_instance)

  if level_second_elapsed > 30 && level_second_elapsed < 60:
    if level_second_elapsed % 4 == 0:
      for n in range(2):
        var enemy_instance = easy_enemy.instantiate()
        var seeds: Array = get_tree().get_nodes_in_group("Seed")
        var choosen_seed = seeds[randi() % seeds.size()];
        enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-150,150), randf_range(-150,150))
        add_child(enemy_instance)

  if level_second_elapsed > 60 && level_second_elapsed < 90:
    if level_second_elapsed % 3 == 0:
      for n in range(2):
        var enemy_instance = easy_enemy.instantiate()
        var seeds: Array = get_tree().get_nodes_in_group("Seed")
        var choosen_seed = seeds[randi() % seeds.size()];
        enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-150,150), randf_range(-150,150))
        add_child(enemy_instance)


  if level_second_elapsed > 90 && level_second_elapsed < 120:
    if level_second_elapsed % 3 == 0:
      for n in range(2):
        var enemy_instance = easy_enemy.instantiate()
        var seeds: Array = get_tree().get_nodes_in_group("Seed")
        var choosen_seed = seeds[randi() % seeds.size()];
        enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-150,150), randf_range(-150,150))
        add_child(enemy_instance)

  if level_second_elapsed > 120 && level_second_elapsed < 180:
    if level_second_elapsed % 3 == 0:
      for n in range(3):
        var enemy_instance = enemies[randi() % enemies.size()].instantiate()
        var seeds: Array = get_tree().get_nodes_in_group("Seed")
        var choosen_seed = seeds[randi() % seeds.size()];
        enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-150,150), randf_range(-150,150))
        add_child(enemy_instance)

  if level_second_elapsed > 120 && level_second_elapsed < 240:
    if level_second_elapsed % 2 == 0:
      for n in range(4):
        var enemy_instance = enemies[randi() % enemies.size()].instantiate()
        var seeds: Array = get_tree().get_nodes_in_group("Seed")
        var choosen_seed = seeds[randi() % seeds.size()];
        enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-150,150), randf_range(-150,150))
        add_child(enemy_instance)

  if level_second_elapsed > 240 && level_second_elapsed < 300:
    if level_second_elapsed % 2 == 0:
      for n in range(4):
        var enemy_instance = enemies[randi() % enemies.size()].instantiate()
        var seeds: Array = get_tree().get_nodes_in_group("Seed")
        var choosen_seed = seeds[randi() % seeds.size()];
        enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-150,150), randf_range(-150,150))
        add_child(enemy_instance)

  if level_second_elapsed > 360 && level_second_elapsed < 360:
    if level_second_elapsed % 2 == 0:
      for n in range(5):
        var enemy_instance = enemies[randi() % enemies.size()].instantiate()
        var seeds: Array = get_tree().get_nodes_in_group("Seed")
        var choosen_seed = seeds[randi() % seeds.size()];
        enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-150,150), randf_range(-150,150))
        add_child(enemy_instance)

      if level_second_elapsed == 300:
        var moth = moth_enemy.instantiate()
        var seeds: Array = get_tree().get_nodes_in_group("Seed")
        var choosen_seed = seeds[randi() % seeds.size()];
        moth.global_position = choosen_seed.global_position + Vector2(randf_range(-150,150), randf_range(-150,150))
        add_child(moth)

  if level_second_elapsed > 360 && level_second_elapsed < 480:
    for n in range(5):
      var enemy_instance = enemies[randi() % enemies.size()].instantiate()
      var seeds: Array = get_tree().get_nodes_in_group("Seed")
      var choosen_seed = seeds[randi() % seeds.size()];
      enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-150,150), randf_range(-150,150))
      add_child(enemy_instance)

  if level_second_elapsed > 480 && level_second_elapsed < 540:
    for n in range(5):
      var enemy_instance = enemies[randi() % enemies.size()].instantiate()
      var seeds: Array = get_tree().get_nodes_in_group("Seed")
      var choosen_seed = seeds[randi() % seeds.size()];
      enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-150,150), randf_range(-150,150))
      add_child(enemy_instance)

  if level_second_elapsed > 540 && level_second_elapsed < 600:
    for n in range(10):
      var enemy_instance = enemies[randi() % enemies.size()].instantiate()
      var seeds: Array = get_tree().get_nodes_in_group("Seed")
      var choosen_seed = seeds[randi() % seeds.size()];
      enemy_instance.global_position = choosen_seed.global_position + Vector2(randf_range(-150,150), randf_range(-150,150))
      add_child(enemy_instance)
    if level_second_elapsed == 598:
      for m in range(2):
        var moth = moth_enemy.instantiate()
        var seeds: Array = get_tree().get_nodes_in_group("Seed")
        var choosen_seed = seeds[randi() % seeds.size()];
        moth.global_position = choosen_seed.global_position + Vector2(randf_range(-150,150), randf_range(-150,150))
        add_child(moth)

    
  
func _on_restart_pressed():
  await get_tree().create_tween().tween_property(black, "modulate", Color.WHITE, 1).set_ease(Tween.EASE_IN_OUT).finished
  get_tree().reload_current_scene()


func _on_area_2d_input_event(_viewport, event, _shape_idx):
  if event.is_action_pressed("left_click") && $Goddess.visible == true:
    get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(%Nuper, "modulate", Color.TRANSPARENT, 0.5).set_ease(Tween.EASE_IN_OUT)
    get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(%Nuper, "global_position", Vector2(352, 475), 0.5).set_ease(Tween.EASE_IN_OUT)
    get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(%Bgd, "modulate", Color.TRANSPARENT, 0.5).set_ease(Tween.EASE_IN_OUT)
    await get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(%NupLabel, "modulate", Color.TRANSPARENT, 0.5).set_ease(Tween.EASE_IN_OUT).finished
    $Goddess.visible = false
    %Apgred.modulate = Color.TRANSPARENT
    $Upgrades.visible = true
    get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(%Apgred, "modulate", Color.WHITE, 0.5).set_ease(Tween.EASE_IN_OUT)


func _on_health_u_mouse_entered():
  %HealthU.modulate = Color.LIGHT_BLUE


func _on_health_u_mouse_exited():
  %HealthU.modulate = Color.WHITE


func _on_damage_u_mouse_entered():
  %DamageU.modulate = Color.LIGHT_BLUE


func _on_damage_u_mouse_exited():
  %DamageU.modulate = Color.WHITE


func _on_cooldown_u_mouse_entered():
  %CooldownU.modulate = Color.LIGHT_BLUE


func _on_cooldown_u_mouse_exited():
  %CooldownU.modulate = Color.WHITE



func _on_health_u_gui_input(event):
  if event.is_action_pressed("left_click") && $Upgrades.visible && %Apgred.modulate == Color.WHITE:
    Stats.plant_health_mult += 0.5
    await get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(%Apgred, "modulate", Color.TRANSPARENT, 0.5).set_ease(Tween.EASE_IN_OUT).finished
    $Upgrades.visible = false
    get_tree().paused = false



func _on_damage_u_gui_input(event):
  if event.is_action_pressed("left_click") && $Upgrades.visible && %Apgred.modulate == Color.WHITE:
    Stats.plant_damage_mult += 0.2
    await get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(%Apgred, "modulate", Color.TRANSPARENT, 0.5).set_ease(Tween.EASE_IN_OUT).finished
    $Upgrades.visible = false
    get_tree().paused = false


func _on_cooldown_u_gui_input(event):
  if event.is_action_pressed("left_click") && $Upgrades.visible && %Apgred.modulate == Color.WHITE:
    if Stats.plant_cooldown_mult != 0:
      Stats.plant_cooldown_mult -= 0.1
    await get_tree().create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).tween_property(%Apgred, "modulate", Color.TRANSPARENT, 0.5).set_ease(Tween.EASE_IN_OUT).finished
    $Upgrades.visible = false
    get_tree().paused = false


func _on_area_2d_mouse_entered():
  Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_area_2d_mouse_exited():
  Input.set_default_cursor_shape(Input.CURSOR_ARROW)
