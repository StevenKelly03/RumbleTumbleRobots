extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite

var DODGE_DIST := 50

var is_punching := false
var is_dodging := false

const PUNCH_COOLDOWN := 0.5
const DODGE_COOLDOWN := 0.4

var action_cd := 0.0 

func _process(delta):
	if action_cd > 0.0:
		action_cd -= delta
		return

	if is_punching or is_dodging:
		return

	if Input.is_action_just_pressed("Blue_Punch"):
		punch()
		action_cd = PUNCH_COOLDOWN

	elif Input.is_action_just_pressed("Blue_Dodge"):
		dodge()
		action_cd = DODGE_COOLDOWN

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
