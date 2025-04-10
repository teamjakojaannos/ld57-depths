@tool
extends TileMapLayer

@export_tool_button("Generate paths")
var _generate_paths: Callable = _do_generate_paths

@export_tool_button("Clear paths")
var _clear_paths: Callable = _do_clear_paths

@onready var enemy_paths: Node2D = $"../EnemyPaths"

func _ready() -> void:
	_generate_paths.call_deferred()

func _do_clear_paths() -> void:
	for path in enemy_paths.get_children():
		if path is not Path2D:
			continue
		if not path.is_in_group("path_enemy_spawn"):
			continue
		path.queue_free()

func _do_generate_paths() -> void:
	_do_clear_paths()
	
	var tile_size = tile_set.tile_size
	
	var cells = get_used_cells()
	var used = []
	for start_coords in cells:
		if used.has(start_coords):
			continue

		var start_tile_type = _get_tile_type(start_coords)
		if start_tile_type == TileType.EMPTY || start_tile_type == TileType.FILLED:
			continue

		var path_curve = Curve2D.new()
		var coords = start_coords
		while not used.has(coords):
			used.push_back(coords)

			var tile_type = _get_tile_type(coords)
			if tile_type == TileType.EMPTY || tile_type == TileType.FILLED:
				break
			
			if is_corner(tile_type):
				var offset = offset_of(tile_type)
				path_curve.add_point((coords + offset) * tile_size)

			var direction = _type_to_direction(tile_type)
			coords = coords + direction

		var is_complete_path = path_curve.point_count >= 4 && coords == start_coords

		# Make the path cyclic
		var offset = offset_of(start_tile_type)
		path_curve.add_point((start_coords + offset) * tile_size)

		if is_complete_path:
			print("Found a complete path starting at %s" % start_coords)
			var path = Path2D.new()
			path.curve = path_curve
			enemy_paths.add_child(path, true)
			path.owner = enemy_paths.get_parent()
			path.add_to_group("path_enemy_spawn")
		else:
			print("Could not complete path starting at %s" % start_coords)

enum TileType {
	EMPTY,
	FILLED,

	CORNER_TOP_LEFT,
	SIDE_TOP,
	CORNER_TOP_RIGHT,
	SIDE_RIGHT,
	CORNER_BOTTOM_RIGHT,
	SIDE_BOTTOM,
	CORNER_BOTTOM_LEFT,
	SIDE_LEFT,

	INNER_CORNER_TOP_TO_LEFT,
	INNER_CORNER_TOP_TO_RIGHT,
	INNER_CORNER_BOTTOM_TO_LEFT,
	INNER_CORNER_BOTTOM_TO_RIGHT,
}

const STONE_TERRAIN_BIT = 1
func _get_tile_type(coords: Vector2i) -> TileType:
	var data = get_cell_tile_data(coords)
	assert(data != null, "No tile at coordinates %s" % coords)

	# Check tile's own terrain
	if data.terrain != STONE_TERRAIN_BIT:
		return TileType.EMPTY

	# Determine which sides/corners are marked as empty
	var left_top = data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER) == -1
	var right_top = data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER) == -1
	var left_side = data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_LEFT_SIDE) == -1
	var right_side = data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_RIGHT_SIDE) == -1
	var left_bottom = data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER) == -1
	var right_bottom = data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER) == -1
	var side_top = data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_TOP_SIDE) == -1
	var side_bottom = data.get_terrain_peering_bit(TileSet.CELL_NEIGHBOR_BOTTOM_SIDE) == -1

	# Check full sides for emptiness
	var is_left_side = left_top && left_side && left_bottom
	var is_right_side = right_top && right_side && right_bottom
	var is_top_side = left_top && side_top && right_top
	var is_bottom_side = left_bottom && side_bottom && right_bottom
	
	# Use elimination method to narrow down the tile type
	# NOTE: Does not support double-sided tiles
	if is_left_side:
		if is_top_side:
			return TileType.CORNER_TOP_LEFT
		elif is_bottom_side:
			return TileType.CORNER_BOTTOM_LEFT
		else:
			return TileType.SIDE_LEFT
	elif is_right_side:
		if is_top_side:
			return TileType.CORNER_TOP_RIGHT
		elif is_bottom_side:
			return TileType.CORNER_BOTTOM_RIGHT
		else:
			return TileType.SIDE_RIGHT
	elif is_top_side:
		return TileType.SIDE_TOP
	elif is_bottom_side:
		return TileType.SIDE_BOTTOM
	# None of the sides are empty, must be an inner corner or filled tile
	elif left_top:
		return TileType.INNER_CORNER_TOP_TO_LEFT
	elif right_top:
		return TileType.INNER_CORNER_TOP_TO_RIGHT
	elif left_bottom:
		return TileType.INNER_CORNER_BOTTOM_TO_LEFT
	elif right_bottom:
		return TileType.INNER_CORNER_BOTTOM_TO_RIGHT
	# No empty corners, the tile is filled
	else:
		return TileType.FILLED

func _type_to_direction(tile_type: TileType) -> Vector2i:
	assert(tile_type != TileType.FILLED, "Filled tiles have no definite clockwise next tile!")
	assert(tile_type != TileType.EMPTY, "Empty tiles have no definite clockwise next tile!")
	
	match tile_type:
		TileType.CORNER_TOP_LEFT:
			return Vector2i.RIGHT
		TileType.SIDE_TOP:
			return Vector2i.RIGHT
		TileType.CORNER_TOP_RIGHT:
			return Vector2i.DOWN
		TileType.SIDE_RIGHT:
			return Vector2i.DOWN
		TileType.CORNER_BOTTOM_RIGHT:
			return Vector2i.LEFT
		TileType.SIDE_BOTTOM:
			return Vector2i.LEFT
		TileType.CORNER_BOTTOM_LEFT:
			return Vector2i.UP
		TileType.SIDE_LEFT:
			return Vector2i.UP
		TileType.INNER_CORNER_TOP_TO_LEFT:
			return Vector2i.UP
		TileType.INNER_CORNER_TOP_TO_RIGHT:
			return Vector2i.RIGHT
		TileType.INNER_CORNER_BOTTOM_TO_LEFT:
			return Vector2i.LEFT
		TileType.INNER_CORNER_BOTTOM_TO_RIGHT:
			return Vector2i.DOWN
		# TileType.NONE:
		# TileType.FILLED:
		_:
			assert(false, "Unhandled tile type: %s" % tile_type)
			return Vector2i.ZERO

func offset_of(tile_type: TileType) -> Vector2i:
	match tile_type:
		TileType.CORNER_TOP_RIGHT:
			return Vector2i.RIGHT
		TileType.SIDE_RIGHT:
			return Vector2i.RIGHT
		TileType.CORNER_BOTTOM_RIGHT:
			return Vector2i.ONE
		TileType.SIDE_BOTTOM:
			return Vector2i.DOWN
		TileType.CORNER_BOTTOM_LEFT:
			return Vector2i.DOWN
		_:
			return Vector2i.ZERO

const CORNER_TILE_TYPES: Array[TileType] = [
	TileType.CORNER_TOP_LEFT,
	TileType.CORNER_TOP_RIGHT,
	TileType.CORNER_BOTTOM_LEFT,
	TileType.CORNER_BOTTOM_RIGHT,
	TileType.INNER_CORNER_TOP_TO_LEFT,
	TileType.INNER_CORNER_TOP_TO_RIGHT,
	TileType.INNER_CORNER_BOTTOM_TO_LEFT,
	TileType.INNER_CORNER_BOTTOM_TO_RIGHT
]

func is_corner(tile_type: TileType) -> bool:
	return CORNER_TILE_TYPES.has(tile_type)
