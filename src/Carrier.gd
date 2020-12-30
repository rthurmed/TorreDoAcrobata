extends Node2D

export (float) var SPEED = 120

var follow
var running = true

func _ready():
	if get_parent() is PathFollow2D:
		follow = get_parent()

func _physics_process(delta):
	# Do path
	if follow and running:
		follow.set_offset(follow.get_offset() + SPEED * delta)

