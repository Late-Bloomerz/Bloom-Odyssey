extends Area2D

var speed = 0.5
var picked = false


func _process(delta):
  global_position.y += speed * delta * 60


func _on_mouse_entered():
  Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
  pass # Replace with function body.


func _on_mouse_exited():
  Input.set_default_cursor_shape(Input.CURSOR_ARROW)


func _on_input_event(viewport, event, shape_idx):
  if !picked:
    picked = true
    speed = 0
    GameSignal.emit_signal("money_gained", 25)
    get_tree().create_tween().tween_property(self, "global_position", global_position+Vector2(0, -10), 0.2).set_ease(Tween.EASE_IN_OUT)
    await get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.2).set_ease(Tween.EASE_IN_OUT).finished
    queue_free()
     
