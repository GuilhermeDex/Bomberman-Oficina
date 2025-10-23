extends Node

class_name PowerUpSystem

var player: Player

@onready var animated_sprite_2d: AnimatedSprite2D = $"../Player/AnimatedSprite2D"
@onready var bomb_placement_system: BombPlacementSystem = $"../Player/BombPlacementSystem"

const SPEED_MULTIPLIER = 3

func _ready() -> void:
	add_to_group("PowerUpSystem")
	player = $"../Player" as Player  
	assert(player != null)
	assert(animated_sprite_2d != null)
	assert(bomb_placement_system != null)

func enable_power_up(power_up_type: Utils.PowerUpType):
	match power_up_type:
		Utils.PowerUpType.BOMB_UP:
			player.max_bombs_at_once += 1
		Utils.PowerUpType.FIRE_UP:
			bomb_placement_system.explosion_size += 1
		Utils.PowerUpType.SPEED_UP:
			player.movement_speed += 5
			animated_sprite_2d.speed_scale += 0.25 
