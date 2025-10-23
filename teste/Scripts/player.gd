extends CharacterBody2D
class_name Player

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var bomb_placement_system:  = $BombPlacementSystem

@export var movement_speed: float = 75.0
var max_bombs_at_once := 1

func _physics_process(delta: float) -> void:
	var dir := Input.get_vector("left", "right", "up", "down")
	
	if abs(dir.x) > abs(dir.y):
		dir = Vector2(sign(dir.x), 0)
	else:
		dir = Vector2(0, sign(dir.y))
	
	velocity = dir * movement_speed
	move_and_slide() 

	# Animações simples
	if velocity == Vector2.ZERO:
		animated_sprite_2d.stop()
	else:
		if velocity.x > 0: animated_sprite_2d.play("walk_right")
		elif velocity.x < 0: animated_sprite_2d.play("walk_left")
		elif velocity.y < 0: animated_sprite_2d.play("walk_up")
		elif velocity.y > 0: animated_sprite_2d.play("walk_down")

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("place_bomb"):
		bomb_placement_system.place_bomb()

func die():
	animated_sprite_2d.play("die")
	velocity = Vector2.ZERO
	set_process_input(false)
	set_physics_process(false)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "die":
		queue_free()
		print("game over")
