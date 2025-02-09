extends Node

const fireball = preload("res://scenes/fireball/fireball.tscn")

var game_active = false
var game_over = false
var game_started = null
var level = 0
var fireball_instance


func _process(_delta: float):
  if is_instance_valid(fireball_instance):
    var speed: float = 1 + ((Time.get_unix_time_from_system() - game_started) / 40)
    $Map/ColorRect.color = Color(255, 0, 0, clamp((speed - 1) / 15, 0, 0.3))
    $Map/Score.text = "SCORE: " + str(round(Time.get_unix_time_from_system() - game_started))
    fireball_instance.speed = speed

  if Input.is_action_just_pressed("start_game"):
    if game_over:
      reset_game()
    elif not game_active:
      start_game()


func start_game():
  game_active = true
  game_over = false
  game_started = Time.get_unix_time_from_system()
  level = 0

  $TitleScreen.hide()
  $GameOverScreen.hide()
  $Map/Score.show()

  new_level()


func end_game():
  game_active = false
  game_over = true

  fireball_instance.queue_free()

  $GameOverScreen/VBoxContainer/Score.text = "SCORE: " + str(round(Time.get_unix_time_from_system() - game_started))
  $GameOverScreen.show()
  $Map/Score.hide()


func reset_game():
  game_over = false
  game_active = false

  $Map.despawn_trees()

  $TitleScreen.show()
  $GameOverScreen.hide()


func new_level():
  level += 1

  $Map.despawn_trees()
  $Map.spawn_trees()

  if is_instance_valid(fireball_instance):
    fireball_instance.queue_free()

  fireball_instance = fireball.instantiate()

  add_child(fireball_instance)

  fireball_instance.hit_tree.connect(func(tree):
    if !is_instance_valid(tree):
      tree = null
    
    tree.burning = true
  )

  fireball_instance.hit_target.connect(func(target):
    if !is_instance_valid(target):
      target = null

    var pure_trees = $Map.get_trees(func(child):
      return not child.burning and (child != target)  
    )
    
    if pure_trees.size() >= 1:
      var new_target = pure_trees.pick_random()
      fireball_instance.target = new_target
    elif pure_trees.size() == 0:
      end_game()
  )

  fireball_instance.target = $Map.get_trees().pick_random()
