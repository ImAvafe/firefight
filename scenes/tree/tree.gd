extends Node2D

@export var burning: bool:
	set(value):
		burning = value
		update_burning()


func _ready() -> void:
	burning = randi() % 3 == 2

	$BurnTimer.timeout.connect(func():
		perish()
	)


func _process(_delta: float) -> void:
	pass


func update_burning():
	$Sprite2D/Fire.visible = burning
	
	if burning:
		$BurnTimer.start()
		$Sprite2D/Fire.play()
	else:
		$BurnTimer.stop()
		$Sprite2D/Fire.stop()


func smoke():
	$Sprite2D/Smoke.visible = true
	$Sprite2D/Smoke.play()


func perish():
	burning = false
	smoke()

	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2.ZERO, 0.2)
	tween.tween_callback(func():
		queue_free()
	)
	tween.play()


func extinguish():
	burning = false
	smoke()