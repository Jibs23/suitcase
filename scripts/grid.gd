extends Resource

class_name Grid

@export var width: int
@export var height: int
@export var cell_size: int
@export var offset: Vector2

var items: Dictionary = {} # Dictionary[Id, ItemResource]
var next_item_id: int = 1  # Counter for generating unique IDs

func add_item(id: String, pos: Vector2, item_resource: ItemResource) -> void:
	items[id] = {
		"item_resource": item_resource,
		"position": pos
	}

# Debug function - can be removed in production
func debug_print_items():
	print("Grid items: ", items.keys())
	for id in items.keys():
		print("  ", id, " at ", items[id].position)

func remove_item(id: String) -> void:
	items.erase(id)

func get_item_by_id(id: String) -> Dictionary:
	if items.has(id):
		return {
			"id": id,
			"position": items[id].position,
			"item_resource": items[id].item_resource
		}
	return {}

func update_item_position(id: String, new_pos: Vector2) -> bool:
	if items.has(id):
		items[id].position = new_pos
		return true
	return false

func generate_unique_id() -> String:
	var id = "item_" + str(next_item_id)
	next_item_id += 1
	# Ensure uniqueness (in case items were added with manual IDs)
	while items.has(id):
		id = "item_" + str(next_item_id)
		next_item_id += 1
	return id

func is_position_in_bounds(grid_pos: Vector2) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < width and grid_pos.y >= 0 and grid_pos.y < height

func world_to_grid(world_pos: Vector2) -> Vector2:
	var local_pos = world_pos - offset
	# Grid positions are 1:1 with cells, no scaling for logical grid
	return Vector2(local_pos / cell_size).floor()

func grid_to_world(grid_pos: Vector2) -> Vector2:
	# Convert logical grid position directly to world position (no scaling for grid bounds)
	return offset + Vector2(grid_pos * cell_size)

func get_item_at_position(grid_pos: Vector2) -> Dictionary:
	for id in items.keys():
		var item_pos = items[id].position
		var item_resource: ItemResource = items[id].item_resource
		var shape = item_resource.get_current_shape()
		for cell in shape:
			var occupied_pos = item_pos + Vector2(cell)
			if occupied_pos == grid_pos:
				return {"id": id, "position": item_pos, "item_resource": item_resource}
	return {}

func can_place_item(grid_pos: Vector2, item_resource: ItemResource) -> bool:
	var shape = item_resource.get_current_shape()
	# Debug: print("Checking placement at grid_pos: ", grid_pos, " for item with shape: ", shape)
	for cell in shape:
		var logical_cell_pos = grid_pos + Vector2(cell)
		# Check if the logical position is within bounds
		if not is_position_in_bounds(logical_cell_pos):
			# Debug: print("Position out of bounds: ", logical_cell_pos)
			return false
		# Check if position is occupied by another item (check at logical level)
		var existing_item = get_item_at_position(logical_cell_pos)
		if existing_item.has("id"):
			# Debug: Uncomment to see collision detection
			# print("Cannot place item - position ", logical_cell_pos, " occupied by item with ID: ", existing_item.id)
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


	for id in items.keys():
		var pos = items[id].position
		var item_resource: ItemResource = items[id].item_resource
		var shape = item_resource.get_current_shape()

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

			# Calculate sprite area covering the entire shape (no scaling needed)
			var shape_width = (max_x - min_x + 1) * cell_size
			var shape_height = (max_y - min_y + 1) * cell_size
			var sprite_area_size = Vector2(shape_width, shape_height)

			# Position sprite at the grid position
			var base_pos = offset + pos * cell_size  # Base grid position
			var sprite_pos = base_pos + Vector2(min_x, min_y) * cell_size

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
	if item_data.has("id"):
		return {
			"grid": self,
			"id": item_data.id,
			"position": item_data.position,
			"item_resource": item_data.item_resource,
			"drag_offset": world_pos - grid_to_world(item_data.position)
		}
	return {}

# Try to place an item at the given world position
# Returns the ID of the placed item if successful, empty string otherwise
func try_place_item(world_pos: Vector2, item_resource: ItemResource, custom_id: String = "") -> String:
	var grid_pos = world_to_grid(world_pos)

	if can_place_item(grid_pos, item_resource):
		var id = custom_id if custom_id != "" else generate_unique_id()
		add_item(id, grid_pos, item_resource)
		return id
	return ""

# Try to rotate an item at the given world position
# Returns true if an item was rotated, false if no item found
func try_rotate_item_at_position(world_pos: Vector2) -> bool:
	var grid_pos = world_to_grid(world_pos)
	var item_data = get_item_at_position(grid_pos)
	if item_data.has("id"):
		item_data.item_resource.rotate_clockwise()
		return true
	return false

# Check if an item can be placed at the given world position
func can_place_item_at_world_pos(world_pos: Vector2, item_resource: ItemResource) -> bool:
	var grid_pos = world_to_grid(world_pos)
	return can_place_item(grid_pos, item_resource)
