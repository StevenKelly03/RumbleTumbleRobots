extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var health_bar: ProgressBar = $HealthBar
@onready var enemy: CharacterBody2D = get_parent().get_node("Red")
@onready var match_manager: Node = get_parent().get_node("MatchManager")

@export var csv_filename := "MatchLog.csv"

var dodge_dist := 50
var health := 100

var is_punching := false
var is_dodging := false
var dead := false

var punch_cooldown := 0.5
var dodge_cooldown := 0.4

var action_cd := 0.0

var _csv_rows: Array[String] = []
var _start_time_ms: int = 0

func _ready():
	randomize()
	_start_time_ms = Time.get_ticks_msec()
	_csv_rows.append("time_ms,event,self_health,enemy_health,amount,dodge_cooldown")
	health_bar.value = health
	if randi() % 2 == 0:
		dodge_cooldown = 0.4
	else:
		dodge_cooldown = 0.3
	log_event("start")

func _process(delta):
	if action_cd > 0.0:
		action_cd -= delta
	if action_cd > 0.0:
		return
	if is_punching or is_dodging or dead:
		return
	if Input.is_action_just_pressed("Blue_Punch"):
		punch()
		action_cd = punch_cooldown
	elif Input.is_action_just_pressed("Blue_Dodge"):
		dodge()
		action_cd = dodge_cooldown

func _now_ms() -> int:
	return Time.get_ticks_msec() - _start_time_ms

func _csv_escape(s: String) -> String:
	var t := s.replace('"', '""')
	return '"' + t + '"'

func log_event(event_name: String, amount: int = 0) -> void:
	var enemy_health := -1
	if enemy != null and "health" in enemy:
		enemy_health = enemy.health
	var line := "%d,%s,%d,%d,%d,%.3f" % [
		_now_ms(),
		_csv_escape(event_name),
		health,
		enemy_health,
		amount,
		dodge_cooldown
	]
	_csv_rows.append(line)

func export_csv() -> void:
	var path := "user://%s" % csv_filename
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Could not write CSV: " + path)
		return
	file.store_string("\n".join(_csv_rows) + "\n")
	file.close()

func punch():
	is_punching = true
	sprite.play("punch")
	log_event("punch")
	if enemy.has_method("take_damage"):
		enemy.take_damage(20)
		log_event("damage_sent", 20)

func dodge():
	is_dodging = true
	log_event("dodge")
	position.x -= dodge_dist
	await get_tree().create_timer(0.2).timeout
	position.x += dodge_dist
	is_dodging = false

func take_damage(amount: int):
	if is_dodging:
		log_event("damage_avoided", amount)
		return
	health -= amount
	health_bar.value = health
	log_event("damage_taken", amount)
	if health <= 0:
		die()

func die():
	dead = true
	sprite.play("defeat")
	log_event("death")
	match_manager.end_match("Red", dodge_cooldown)
	export_csv()

func _on_sprite_animation_finished():
	if sprite.animation == "punch":
		is_punching = false
		sprite.play("idle")
