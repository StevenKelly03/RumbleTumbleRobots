extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite

var npc_mode := false  # false = player, true = npc

var DODGE_DIST := 50

var is_punching := false
var is_dodging := false

func _ready():
	randomize()
	npc_loop()

func _process(_delta):
	if npc_mode:
		return

	if not is_punching and not is_dodging:
		if Input.is_action_just_pressed("Red_Punch"):
			punch()
		if Input.is_action_just_pressed("Red_Dodge"):
			dodge()

func punch():
	is_punching = true
	sprite.play("punch")

func dodge():
	is_dodging = true

	position.x += DODGE_DIST
	await get_tree().create_timer(0.5).timeout
	position.x -= DODGE_DIST

	is_dodging = false

func npc_loop():
	while true:
		await get_tree().create_timer(0.3).timeout  # npc think time
		if not npc_mode:
			continue
		if is_punching or is_dodging:
			continue

		# 50/50 random choice
		if randi() % 2 == 0:
			punch()
		else:
			dodge()

func _on_sprite_animation_finished():
	if sprite.animation == "punch":
		is_punching = false
		sprite.play("idle")


func _on_button_pressed() -> void:
	npc_mode = !npc_mode
