extends Seed

func bloom(pos):
  super(pos)
  $Explode.start()


func meledak():
  $AnimationPlayer2.play("explodo")



func _on_explode_timeout():
  GameSignal.emit_signal("seed_died", self)
  meledak()
