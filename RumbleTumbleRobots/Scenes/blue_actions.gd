extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite

var DODGE_DIST := 50

var is_punching := false
var is_dodging := false

func _process(_delta):
	if not is_punching and not is_dodging:
		if Input.is_action_just_pressed("Blue_Punch"):
			punch()
		if Input.is_action_just_pressed("Blue_Dodge"):
			dodge()

func punch():
	is_punching = true
	sprite.play("punch")

func dodge():
	is_dodging = true

	position.x -= DODGE_DIST
	await get_tree().create_timer(0.2).timeout
	position.x += DODGE_DIST

	is_dodging = false

func _on_sprite_animation_finished():
	if sprite.animation == "punch":
		is_punching = false
		sprite.play("idle")
