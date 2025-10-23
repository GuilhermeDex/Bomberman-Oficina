extends Area2D
class_name CentralExplosion

@export var lifetime := 0.35
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@onready var raycasts: Array[RayCast2D] = [
	$RayCasts/RayCastUp,
	$RayCasts/RayCastRight,
	$RayCasts/RayCastDown,
	$RayCasts/RayCastLeft
]

var animation_names := ["up", "right", "down", "left"]
const TILE_SIZE := 16
var size := 1

# direções já no tamanho de 1 tile
var animation_directions: Array[Vector2] = [
	Vector2(0, -TILE_SIZE),
	Vector2(TILE_SIZE, 0),
	Vector2(0, TILE_SIZE),
	Vector2(-TILE_SIZE, 0)
]

const DIRECTIONAL_EXPLOSION := preload("res://Scenes/directional_explosion.tscn")

func _ready() -> void:
	for i in raycasts.size():
		_check_dir(animation_names[i], raycasts[i], animation_directions[i])
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _check_dir(anim_name: String, rc: RayCast2D, dir_step: Vector2) -> void:
	rc.target_position = dir_step * size
	rc.force_raycast_update()

	if not rc.is_colliding():
		_create_for_size(size, anim_name, dir_step)
		return

	var result := _reach_and_hit(rc)
	var tiles_to_spawn: int = result["tiles"]
	var hit_destructible: bool = result["hit_destructible"]

	if tiles_to_spawn > 0:
		_create_for_size(tiles_to_spawn, anim_name, dir_step)

	if hit_destructible:
		_execute_collision(rc.get_collider())


func _create_for_size(n: int, anim_name: String, dir_step: Vector2) -> void:
	for i in n:
		var pos := dir_step * (i + 1)
		var fx := DIRECTIONAL_EXPLOSION.instantiate()
		fx.position = pos
		add_child(fx)
		var anim_to_play := ("%s_middle" % anim_name) if i < n - 1 else ("%s_end" % anim_name)
		fx.play_animation(anim_to_play)


func _reach_and_hit(rc: RayCast2D) -> Dictionary:
	var cp := rc.get_collision_point()
	var tiles_before := int(floor(rc.global_position.distance_to(cp) / TILE_SIZE))

	var include_hit := false
	var c := rc.get_collider()

	if c is BrickWall:
		include_hit = true
	elif c is TileMapLayer:
		var tl := c as TileMapLayer
		var map_pos: Vector2i = tl.local_to_map(tl.to_local(cp))
		var td := tl.get_cell_tile_data(map_pos)
		include_hit = td and td.has_custom_data("destructible") and bool(td.get_custom_data("destructible"))
	var extra: int = 0
	if include_hit:
		extra = 1
	var tiles_to_spawn: int = min(size, tiles_before + extra)
	return {"tiles": tiles_to_spawn, "hit_destructible": include_hit}



func _execute_collision(collider: Object) -> void:
	if collider is BrickWall:
		(collider as BrickWall).destroy()
