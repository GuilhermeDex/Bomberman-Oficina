extends CharacterBody2D
class_name Enemy

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox

@export var tile_size: int = 16
@export var tiles_per_second: float = 2.0           # velocidade (tiles/segundo)
@export var change_dir_chance: float = 0.5          # chance de trocar direção em interseções
@export var prevent_backtracking: bool = true       # evita voltar imediatamente
@export var tilemap: TileMapLayer                   

var dir := Vector2.LEFT                             
var moving := false
var current_cell: Vector2i
var next_cell: Vector2i
var target_world: Vector2
var last_dir := Vector2.ZERO

func _ready() -> void:
	_snap_to_grid()
	current_cell = _world_to_cell(global_position)
	if dir == Vector2.ZERO:
		dir = Vector2.LEFT
	if hurtbox and not hurtbox.body_entered.is_connected(_on_hurtbox_body_entered):
		hurtbox.body_entered.connect(_on_hurtbox_body_entered)
	_maybe_start_step() 

func _physics_process(delta: float) -> void:
	if moving:
		var pixels_per_sec := tiles_per_second * tile_size
		var to_target := target_world - global_position
		var step := to_target.normalized() * pixels_per_sec * delta
		if step.length() >= to_target.length():
			global_position = target_world
			moving = false
			current_cell = next_cell
			_maybe_change_dir()  
			_maybe_start_step()
		else:
			global_position += step
	else:
		
		_maybe_start_step()

func _maybe_change_dir() -> void:
	if randf() <= change_dir_chance:
		dir = _pick_new_dir(dir)

func _maybe_start_step() -> void:
	if _is_blocked(dir):
		dir = _pick_new_dir(dir)
		if dir == Vector2.ZERO:
			return  

	next_cell = current_cell + _vec_to_cell(dir)
	target_world = _cell_to_world(next_cell)
	moving = true
	_update_sprite(dir)

func _pick_new_dir(current: Vector2) -> Vector2:
	var dirs := [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]

	if prevent_backtracking:
		dirs.erase(-current)

	var candidates: Array[Vector2] = []
	for d in dirs:
		if not _is_blocked(d):
			candidates.append(d)

	if candidates.size() > 0:
		last_dir = current
		return candidates[randi_range(0, candidates.size()-1)]

	if prevent_backtracking and not _is_blocked(-current):
		return -current

	for d in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		if not _is_blocked(d):
			return d

	return Vector2.ZERO  

func _is_blocked(d: Vector2) -> bool:
	var cell := current_cell + _vec_to_cell(d)

	var td := tilemap.get_cell_tile_data(cell)
	if td != null:
		var solid := td.has_custom_data("solid") and bool(td.get_custom_data("solid"))
		var destructible := td.has_custom_data("destructible") and bool(td.get_custom_data("destructible"))
		if solid or destructible:
			return true

	var world := _cell_to_world(cell)
	var space := get_world_2d().direct_space_state
	var qp := PhysicsPointQueryParameters2D.new()
	qp.position = world
	qp.collide_with_bodies = true
	qp.collide_with_areas = true

	var hits: Array[Dictionary] = space.intersect_point(qp, 8)
	for hit: Dictionary in hits:
		var obj: Object = hit.get("collider")
		if obj is BrickWall:
			return true
		if obj is Bomb:
			return true
	return false

func _update_sprite(new_dir: Vector2) -> void:
	if new_dir.x != 0:
		animated_sprite_2d.scale.x = sign(new_dir.x)


func _world_to_cell(p: Vector2) -> Vector2i:
	return tilemap.local_to_map(tilemap.to_local(p))

func _cell_to_world(cell: Vector2i) -> Vector2:
	var local := tilemap.map_to_local(cell)
	return tilemap.to_global(local)

func _vec_to_cell(v: Vector2) -> Vector2i:
	if v.x > 0: return Vector2i(1, 0)
	if v.x < 0: return Vector2i(-1, 0)
	if v.y > 0: return Vector2i(0, 1)
	if v.y < 0: return Vector2i(0, -1)
	return Vector2i.ZERO

func _snap_to_grid() -> void:
	global_position.x = roundf(global_position.x / tile_size) * tile_size
	global_position.y = roundf(global_position.y / tile_size) * tile_size

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body is Player:
		(body as Player).die()

func die():
	animated_sprite_2d.play("die")
	set_physics_process(false)
	set_collision_layer(0)
	set_collision_mask(0)
	await animated_sprite_2d.animation_finished
	queue_free()
