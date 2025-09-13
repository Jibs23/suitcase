extends Resource

class_name Grid

@export var width: int
@export var height: int
@export var cell_size: int
@export var offset: Vector2

var items: Dictionary = {}

func add_item(pos: Vector2, shape: PackedVector2Array) -> void:
	items[pos] = shape

func remove_item(pos: Vector2) -> void:
	items.erase(pos)

func get_grid_position(world_pos: Vector2) -> Vector2:
	var local_pos = world_pos - offset
	return Vector2(local_pos / cell_size).floor()

func is_position_in_bounds(grid_pos: Vector2) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < width and grid_pos.y >= 0 and grid_pos.y < height

func world_to_grid(world_pos: Vector2) -> Vector2:
	return get_grid_position(world_pos)

func grid_to_world(grid_pos: Vector2) -> Vector2:
	return offset + Vector2(grid_pos * cell_size)

func get_item_at_position(grid_pos: Vector2) -> Dictionary:
	for item_pos in items.keys():
		var shape: PackedVector2Array = items[item_pos]
		for cell in shape:
			if item_pos + Vector2(cell) == grid_pos:
				return {"position": item_pos, "shape": items[item_pos]}
	return {}

func can_place_item(grid_pos: Vector2, shape: PackedVector2Array) -> bool:
	for cell in shape:
		var check_pos = grid_pos + Vector2(cell)
		if not is_position_in_bounds(check_pos):
			return false
		# Check if position is occupied by another item
		if get_item_at_position(check_pos).has("position"):
			return false
	return true

func draw(drawer: CanvasItem, color: Color) -> void:
	# Draw grid lines
	for x in range(width + 1):
		var x_pos = offset.x + x * cell_size
		drawer.draw_line(Vector2(x_pos, offset.y),
						 Vector2(x_pos, offset.y + height * cell_size),
						 color)
	for y in range(height + 1):
		var y_pos = offset.y + y * cell_size
		drawer.draw_line(Vector2(offset.x, y_pos),
						 Vector2(offset.x + width * cell_size, y_pos),
						 color)

	# Draw items
	for pos in items.keys():
		var shape: PackedVector2Array = items[pos]
		for cell in shape:
			var cell_pos = pos + cell
			var top_left = offset + cell_pos * cell_size
			drawer.draw_rect(Rect2(top_left, Vector2(cell_size, cell_size)), color, true)
