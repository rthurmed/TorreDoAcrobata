extends Area2D

signal collected

var to_be_collected = true

func collect(status = false, keep_visible = false):
	to_be_collected = status
	visible = status or keep_visible
	$CollisionShape2D.disabled = not status

func _on_Fly_body_entered(body):
	if to_be_collected and body.name == "Player":
		collect(false, true)
		emit_signal("collected")
		$AnimationPlayer.play("collect")
		$CollectedTimer.start()

func _on_CollectedTimer_timeout():
	visible = false
