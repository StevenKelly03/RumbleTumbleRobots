extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite

var is_punching := false

func _process(_delta):
	if Input.is_action_just_pressed("Blue_Punch") and not is_punching:
		punch()

func punch():
	is_punching = true
	sprite.play("punch")

func _on_sprite_animation_finished():
	if sprite.animation == "punch":
		is_punching = false
		sprite.play("idle")
