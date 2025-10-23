extends Area2D
class_name PowerUp

@onready var shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

var type: Utils.PowerUpType

func _ready() -> void:
	body_entered.connect(_on_body_entered)  # Player é corpo, não área

# chamado pelo BrickWall após instanciar
func init(res: PowerUpRes) -> void:
	type = res.type
	if sprite and res.texture:
		sprite.texture = res.texture


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var sys := get_tree().get_first_node_in_group("PowerUpSystem") as PowerUpSystem
		if sys:
			sys.enable_power_up(type)
		queue_free()
