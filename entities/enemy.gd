extends CharacterBody2D

const SPEED = 5
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var closest_node = null
var closest_distance = 999999
var target

var game_started = false

func _ready():
  search_target()

  GameSignal.game_started.connect(func(): game_started = true)

func _physics_process(_delta):
  if target != null && game_started:
    velocity = global_position.direction_to(target.global_position) * SPEED
  move_and_slide()

func search_target():
  var nodes = get_tree().get_nodes_in_group("Seed")
  for node in nodes:
    var distance = node.global_position.distance_to(global_position)
    if distance < closest_distance:
      closest_distance = distance
      closest_node = node
    if closest_node:
      print("Closest node:", closest_node.name)
      target = closest_node

func _on_change_target_timer_timeout():
  search_target()
