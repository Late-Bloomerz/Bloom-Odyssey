extends Sprite2D

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var labu: Sprite2D = $Labu
@onready var progress: TextureProgressBar = $Progress

@export var cooldown_duration: int
@export var gulundung: PackedScene

var is_casting: bool = false

func _process(delta):
  if is_casting:
    labu.global_position = get_tree().current_scene.get_global_mouse_position()
  if !cooldown_timer.is_stopped():
    progress.value += 60 * delta

  

func _ready():
  cooldown_timer.wait_time = cooldown_duration
  $Bloom.play()
  progress.max_value = cooldown_duration * 60


func _on_bowl_area_mouse_entered():
  Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)


func _on_bowl_area_mouse_exited():
  Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _unhandled_input(event):
  if event.is_action_pressed("left_click") && is_casting:
    is_casting = false
    labu.visible = false
    var inst = gulundung.instantiate()
    inst.global_position = global_position
    inst.target = get_tree().current_scene.get_global_mouse_position()
    get_tree().current_scene.add_child(inst)
    $Bowl.play()
    cooldown_timer.start()
    frame = 1
    progress.visible=true
    


func _on_bowl_area_input_event(_viewport, event, _shape_idx):
  if event.is_action_pressed("left_click"):
    if cooldown_timer.is_stopped():
      await get_tree().create_timer(0.1).timeout
      is_casting = true
      labu.visible = true
    else:
      UiUtils.show_info("On Cooldown")


func _on_cooldown_timer_timeout():
  frame = 0
  $Bloom.play()
  progress.visible=false
  progress.value=0
