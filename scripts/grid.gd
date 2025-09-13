extends Resource

class_name Grid

@export var width: int
@export var height: int
@export var cell_size: int
@export var offset: Vector2

var items: Dictionary = {} # Dictionary[Vector2, ItemResource]

func add_item(pos: Vector2, item_resource: ItemResource) -> void:
	items[pos] = item_resource

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
		var item_resource: ItemResource = items[item_pos]
		var shape = item_resource.get_current_shape()
		for cell in shape:
			if item_pos + Vector2(cell) == grid_pos:
				return {"position": item_pos, "item_resource": item_resource}
	return {}

func can_place_item(grid_pos: Vector2, item_resource: ItemResource) -> bool:
	var shape = item_resource.get_current_shape()
	for cell in shape:
		var check_pos = grid_pos + Vector2(cell)
		if not is_position_in_bounds(check_pos):
			return false
		# Check if position is occupied by another item
		if get_item_at_position(check_pos).has("position"):
			return false
	return true

func draw(drawer: CanvasItem, color: Color) -> void:

	# Draw grid background
	var background_color = Color(color.r, color.g, color.b, 0.1)
	var grid_rect = Rect2(offset, Vector2(width * cell_size, height * cell_size))
	drawer.draw_rect(grid_rect, background_color, true)

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


	for pos in items.keys():
		var item_resource: ItemResource = items[pos]
		var shape = item_resource.get_current_shape()

		# Draw shape background
		for cell in shape:
			var cell_pos = pos + cell
			var top_left = offset + cell_pos * cell_size
			drawer.draw_rect(Rect2(top_left, Vector2(cell_size, cell_size)), color, true)

		# Draw sprite if available
		if item_resource.sprite_texture != null:
			# Calculate the bounding box of the shape
			var min_x = 0
			var min_y = 0
			var max_x = 0
			var max_y = 0
			
			for cell in shape:
				min_x = min(min_x, cell.x)
				min_y = min(min_y, cell.y)
				max_x = max(max_x, cell.x)
				max_y = max(max_y, cell.y)
			
			# Calculate sprite area covering the entire shape
			var shape_width = (max_x - min_x + 1) * cell_size
			var shape_height = (max_y - min_y + 1) * cell_size
			var sprite_area_size = Vector2(shape_width, shape_height)
			
			# Position sprite at the top-left of the bounding box
			var sprite_pos = offset + (pos + Vector2(min_x, min_y)) * cell_size
			
			# Scale sprite to fit the entire shape area
			var texture_size = item_resource.sprite_texture.get_size()
			var scale_factor = min(sprite_area_size.x / texture_size.x, sprite_area_size.y / texture_size.y)
			var scaled_size = texture_size * scale_factor
			
			# Center the sprite within the shape area
			var centered_pos = sprite_pos + (sprite_area_size - scaled_size) * 0.5
			
			# Create a transform for rotation
			var transform = Transform2D()
			transform = transform.rotated(deg_to_rad(item_resource.rotation_degrees))
			transform.origin = centered_pos + scaled_size * 0.5
			
			drawer.draw_set_transform(transform.origin, transform.get_rotation(), Vector2.ONE)
			drawer.draw_texture_rect(item_resource.sprite_texture,
									Rect2(-scaled_size * 0.5, scaled_size),
									false, Color(1, 1, 1, 0.65))
			drawer.draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

# Try to start dragging an item at the given world position
# Returns a dictionary with drag info if successful, empty dict if no item found
func try_start_drag(world_pos: Vector2) -> Dictionary:
	var grid_pos = world_to_grid(world_pos)
	var item_data = get_item_at_position(grid_pos)
	if item_data.has("position"):
		return {
			"grid": self,
			"position": item_data.position,
			"item_resource": item_data.item_resource,
			"drag_offset": world_pos - grid_to_world(item_data.position)
		}
	return {}

# Try to place an item at the given world position
# Returns true if successfully placed, false otherwise
func try_place_item(world_pos: Vector2, item_resource: ItemResource) -> bool:
	var grid_pos = world_to_grid(world_pos)
	if can_place_item(grid_pos, item_resource):
		add_item(grid_pos, item_resource)
		return true
	return false

# Try to rotate an item at the given world position
# Returns true if an item was rotated, false if no item found
func try_rotate_item_at_position(world_pos: Vector2) -> bool:
	var grid_pos = world_to_grid(world_pos)
	var item_data = get_item_at_position(grid_pos)
	if item_data.has("position"):
		item_data.item_resource.rotate_clockwise()
		return true
	return false

# Check if an item can be placed at the given world position
func can_place_item_at_world_pos(world_pos: Vector2, item_resource: ItemResource) -> bool:
	var grid_pos = world_to_grid(world_pos)
	return can_place_item(grid_pos, item_resource)
