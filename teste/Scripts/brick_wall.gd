# brick_wall.gd
extends StaticBody2D
class_name BrickWall

@onready var col: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

const POWER_UP_SCENE = preload("res://Scenes/power_up.tscn")

@export var bomb_up_res: PowerUpRes
@export var fire_up_res: PowerUpRes
@export var speed_up_res: PowerUpRes

func destroy() -> void:
	if col:
		col.disabled = true
	set_collision_layer(0)
	set_collision_mask(0)
	if anim and anim.sprite_frames and anim.sprite_frames.has_animation("destro"):
		anim.play("destro")
		await anim.animation_finished
	var chosen := _pick_random_powerup()
	if chosen != null:
		_spawn_power_up(chosen)
	queue_free() 

func _pick_random_powerup() -> PowerUpRes:
	# 5 resultados equiprováveis: 4 power-ups + "nada" (null)
	var options: Array = [bomb_up_res, fire_up_res, speed_up_res, null]
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var idx := rng.randi_range(0, options.size() - 1)
	return options[idx]



func _spawn_power_up(res: PowerUpRes) -> void:
	var power_up = POWER_UP_SCENE.instantiate()
	power_up.global_position = global_position
	get_tree().root.add_child(power_up)
	power_up.init(res)
