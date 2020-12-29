extends Area2D

signal cause_damage(pos)

func _on_Spinblade_body_entered(body):
	if body.name == "Player":
		emit_signal("cause_damage", global_position)
