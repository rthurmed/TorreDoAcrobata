extends Node2D

const IDLE_DURATION = 1.0

export var move_to = Vector2.UP * 32
export var speed = 3.0

onready var platform = $Platform
onready var tween = $Tween

var follow = Vector2()

func _ready():
	# Tween config
	# Based on: https://youtu.be/mBNa8LcAsns
	var duration = move_to.length() / float(speed * 16)
	tween.interpolate_property(self, "follow", Vector2.ZERO, move_to, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, IDLE_DURATION)
	tween.interpolate_property(self, "follow", move_to, Vector2.ZERO, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, duration + IDLE_DURATION * 2)
	tween.start()

func _physics_process(_delta):
	platform.position = platform.position.linear_interpolate(follow, 0.075)
