extends Seed

func bloom(pos):
  super(pos)
  $Explode.start()


func meledak():
  $AnimationPlayer2.play("explodo")



func _on_explode_timeout():
  meledak()
