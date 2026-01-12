extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var health_bar: ProgressBar = $HealthBar 
@onready var enemy: CharacterBody2D	= get_parent().get_node("Blue")

var DODGE_DIST := 50
var health := 100

var is_punching := false
var is_dodging := false

func _ready():
	health_bar.value = health

func _process(_delta):
	if not is_punching and not is_dodging:
		if Input.is_action_just_pressed("Red_Punch"):
			punch()
		if Input.is_action_just_pressed("Red_Dodge"):
			dodge()

func punch():
	is_punching = true
	sprite.play("punch")
	if enemy.has_method("take_damage"):
		enemy.take_damage(20)

func dodge():
	is_dodging = true
	position.x += DODGE_DIST
	await get_tree().create_timer(0.2).timeout
	position.x -= DODGE_DIST
	is_dodging = false

func take_damage(amount: int):
	if is_dodging:
		return
	
	health -= amount
	health_bar.value = health
	
	if health <= 0:
		die()

func die():
	sprite.play("defeat")
	
func _on_sprite_animation_finished():
	if sprite.animation == "punch":
		is_punching = false
		sprite.play("idle")
