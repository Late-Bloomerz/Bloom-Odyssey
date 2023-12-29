extends CanvasLayer


@onready var label: Label = $HBoxContainer/Label
@onready var icon: TextureRect = $HBoxContainer/TextureRect
@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var container: HBoxContainer = $HBoxContainer

func pop_info(info: String, location: Vector2, with_icon: bool = true):
  if !with_icon:
    icon.visible = false
  container.set_position(location)
  label.set_text(info)
  get_tree().create_tween().tween_property(container, "global_position", Vector2(container.global_position.x, container.global_position.y - 20), 0.2).set_trans(Tween.TRANS_BACK)
