extends Sprite2D

@export var cloud: PackedScene


func _on_fart_timer_timeout():
  var instance = cloud.instantiate()
  instance.global_position = global_position
  get_tree().current_scene.add_child(instance)
