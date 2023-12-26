# Extend node type
# Must the same type with the node which the script attache into
extends Node2D

@onready var camera: Camera2D = $Camera2D
@onready var experience_bar: TextureProgressBar = %ExperienceBar
@onready var timer_label: Label = %TimerLabel

var scrolling_left: bool = false
var scrolling_right: bool = false
var scrolling_top: bool = false
var scrolling_bottom: bool = false

var level_second_elapsed: int = 1

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
  print("Waiting for player to place their first seed")

func _on_game_started() -> void:
  game_started = true
  $Shop.visible = true
  $CameraScroll.visible = true
  $Experience.visible = true
  $LevelTimerCanvas.visible = true
  camera.move_local_y(475)
  $Menu.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
  pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
# For physic
func _physics_process(delta):
  if !game_started:
    return
  if scrolling_left:
    camera.position.x -= 4 * delta * 60
  if scrolling_right:
    camera.position.x += 4 * delta * 60
  if scrolling_top:
    camera.position.y -= 4 * delta * 60
  if scrolling_bottom:
    camera.position.y += 4 * delta * 60
  

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
  experience_bar.value += value
  


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
