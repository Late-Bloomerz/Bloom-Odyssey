extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
  if OS.has_feature("HTML5"):
    %Exit.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
  pass


func _on_button_3_pressed():
  $AcceptDialog.visible = true


func _on_accept_dialog_confirmed():
  get_tree().quit() 


func _on_button_pressed():
  GameSignal.emit_signal("game_started")

