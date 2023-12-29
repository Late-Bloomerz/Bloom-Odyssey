extends Control

var is_casting: bool = false
var casted_seed: String
@onready var tilemap: TileMap = get_parent().get_parent().get_node("TileMap")
@onready var seed_cooldown: TextureProgressBar = %SeedCooldown
@onready var seed_texture: TextureRect = %SeedTexture
@onready var seed_cooldown_timer: Timer = $SeedCooldownTimer
@onready var money_label: Label = $MoneyLabel
@onready var seed_item = %Seed
@onready var attacker = %Attacker
@onready var chili = %Chili
@onready var pumpkin = %Pumpkin

@export var seed_scene: PackedScene
@export var seed_cooldown_duration: int


var indicator = preload("res://ui/indicator.tscn")
var indicator_ref


var placed_mushroom: Array[Vector2] = [Vector2(672, 384)]
var money: int = 100


func _ready():
  GameSignal.money_gained.connect(_on_money_gained)
  GameSignal.item_purchased.connect(_on_item_purchsed)
  GameSignal.seed_died.connect(_on_seed_died)


func _process(_delta):
  if is_casting && indicator_ref != null:
    var mouse_position = get_tree().current_scene.get_global_mouse_position()
    var mouse_position_to_tile_position = tilemap.local_to_map(mouse_position)
    var mouse_pos = get_tree().current_scene.get_global_mouse_position()
    var snapped_x = int(mouse_pos.x / 32) * 32
    var snapped_y = int(mouse_pos.y / 32) * 32
    indicator_ref.global_position = Vector2(snapped_x, snapped_y)
    if check_custom_data(mouse_position_to_tile_position, "is_dirt", 0):
      indicator_ref.modulate = Color.GREEN
    else:
      indicator_ref.modulate = Color.RED
    if placed_mushroom.has(Vector2(snapped_x, snapped_y)):
      indicator_ref.modulate = Color.RED


func _unhandled_input(event):
  # cancel_plant = esc, rmb
  if event.is_action_pressed("cancel_plant") && is_casting:
    is_casting = false
    indicator_ref.visible = false
    casted_seed = ""

  if event.is_action_pressed("left_click"):
      var mouse_position = get_tree().current_scene.get_global_mouse_position()
      var mouse_position_to_tile_position = tilemap.local_to_map(mouse_position)
      var mouse_pos = get_tree().current_scene.get_global_mouse_position()
      var snapped_x = int(mouse_pos.x / 32) * 32
      var snapped_y = int(mouse_pos.y / 32) * 32
      if check_custom_data(mouse_position_to_tile_position, "is_dirt", 0):
        if casted_seed == "seed" && !placed_mushroom.has(Vector2(snapped_x, snapped_y)):
          seed_item.place()
          is_casting = false
          indicator_ref.visible = false
          casted_seed = ""
          placed_mushroom.append(Vector2(snapped_x, snapped_y))
          $Plant.play()
        if casted_seed == "attacker" && !placed_mushroom.has(Vector2(snapped_x, snapped_y)):
          placed_mushroom.append(Vector2(snapped_x, snapped_y))
          attacker.place()
          is_casting = false
          indicator_ref.visible = false
          casted_seed = ""
          $Plant.play()
        if casted_seed == "chili" && !placed_mushroom.has(Vector2(snapped_x, snapped_y)):
          placed_mushroom.append(Vector2(snapped_x, snapped_y))
          chili.place()
          is_casting = false
          indicator_ref.visible = false
          casted_seed = ""
          $Plant.play()
        if casted_seed == "pumpkin" && !placed_mushroom.has(Vector2(snapped_x, snapped_y)):
          placed_mushroom.append(Vector2(snapped_x, snapped_y))
          pumpkin.place()
          is_casting = false
          indicator_ref.visible = false
          casted_seed = ""
          $Plant.play()
      if !check_custom_data(mouse_position_to_tile_position, "is_dirt", 0) && is_casting:
        UiUtils.show_info("Must plant inside dirt")
      if placed_mushroom.has(Vector2(snapped_x, snapped_y)) && is_casting:
        UiUtils.show_info("Dirt is full")


func check_custom_data(mouse_pos, custom_data_variable,layer):
  var tile_data: TileData = tilemap.get_cell_tile_data(layer,mouse_pos)
  if tile_data:
    return tile_data.get_custom_data(custom_data_variable)
  else:
    return false

func _on_seed_died(died_seed):
  placed_mushroom.erase(died_seed.global_position)

func _on_money_gained(value):
  money += value
  money_label.text = "Money: " + str(money)
  UiUtils.show_info("+"+str(value), false, Vector2(200, 200))
  $Money.play()

func _on_item_purchsed(value):
  money -= value
  money_label.text = "Money: " + str(money)


func _on_seed_cooldown_timer_timeout():
  pass 
  # seed_cooldown.value -= 1


func _on_seed_cooldown_timer_duration_timeout():
  pass
  # seed_cooldown.value = 0


func _on_container_gui_input(event):
  if event.is_action_pressed("left_click") && is_casting:
    is_casting = false
    indicator_ref.visible = false
    casted_seed = ""


func _on_seed_gui_input(event):
  if event.is_action_pressed("left_click") && indicator_ref == null:
    var indicator_instance = indicator.instantiate()
    get_tree().current_scene.add_child(indicator_instance)
    indicator_ref = indicator_instance

  if event.is_action_pressed("left_click") && seed_item.cooldown_timer.is_stopped() && money >= seed_item.price:
    await get_tree().create_timer(0.1).timeout
    is_casting = true
    indicator_ref.visible = true
    casted_seed = "seed"

  if event.is_action_pressed("left_click") && !seed_item.cooldown_timer.is_stopped():
    UiUtils.show_info("On Cooldown")
  elif event.is_action_pressed("left_click") && money < seed_item.price:
    UiUtils.show_info("Not Enough Money")


func _on_attacker_gui_input(event):
  if event.is_action_pressed("left_click") && indicator_ref == null:
    var indicator_instance = indicator.instantiate()
    get_tree().current_scene.add_child(indicator_instance)
    indicator_ref = indicator_instance

  if event.is_action_pressed("left_click") && attacker.cooldown_timer.is_stopped() && money >= attacker.price:
    await get_tree().create_timer(0.1).timeout
    is_casting = true
    indicator_ref.visible = true
    casted_seed = "attacker"

  if event.is_action_pressed("left_click") && !attacker.cooldown_timer.is_stopped():
    UiUtils.show_info("On Cooldown")
  elif event.is_action_pressed("left_click") && money < attacker.price:
    UiUtils.show_info("Not Enough Money")


func _on_shop_item_gui_input(event):
  if event.is_action_pressed("left_click") && indicator_ref == null:
    var indicator_instance = indicator.instantiate()
    get_tree().current_scene.add_child(indicator_instance)
    indicator_ref = indicator_instance

  if event.is_action_pressed("left_click") && chili.cooldown_timer.is_stopped() && money >= chili.price:
    await get_tree().create_timer(0.1).timeout
    is_casting = true
    indicator_ref.visible = true
    casted_seed = "chili"

  if event.is_action_pressed("left_click") && !chili.cooldown_timer.is_stopped():
    UiUtils.show_info("On Cooldown")
  elif event.is_action_pressed("left_click") && money < chili.price:
    UiUtils.show_info("Not Enough Money")

func _on_pumpkin_gui_input(event):
  if event.is_action_pressed("left_click") && indicator_ref == null:
    var indicator_instance = indicator.instantiate()
    get_tree().current_scene.add_child(indicator_instance)
    indicator_ref = indicator_instance

  if event.is_action_pressed("left_click") && pumpkin.cooldown_timer.is_stopped() && money >= pumpkin.price:
    await get_tree().create_timer(0.1).timeout
    is_casting = true
    indicator_ref.visible = true
    casted_seed = "pumpkin"

  if event.is_action_pressed("left_click") && !pumpkin.cooldown_timer.is_stopped():
    UiUtils.show_info("On Cooldown")
  elif event.is_action_pressed("left_click") && money < pumpkin.price:
    UiUtils.show_info("Not Enough Money")
