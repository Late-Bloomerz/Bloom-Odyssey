extends Sprite2D

@export var coin: PackedScene


func _on_timer_timeout():
  var instance = coin.instantiate()
  instance.global_position = global_position
  get_tree().current_scene.add_child(instance)

