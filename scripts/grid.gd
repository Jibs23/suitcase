extends Resource

class_name Grid

@export var width: int
@export var height: int
@export var cell_size: int
@export var offset: Vector2



var items: Dictionary = {} # Dictionary[Id, ItemResource]
var next_item_id: int = 1  # Counter for generating unique IDs
var all_cells_occupied: bool = false


func clear() -> void:
	items.clear()
	next_item_id = 1
	all_cells_occupied = false

func count_occupied_cells() -> int:
	var occupied_cells = {}
	var total_occupied = 0


	for key in items:
		var item = items[key]
		var item_pos = item.position
		var item_resource: ItemResource = item.item_resource
		var shape = item_resource.get_current_shape()

		for cell in shape:
			var occupied_pos = item_pos + Vector2(cell)
			# Only count cells that are within bounds
			if occupied_pos.x >= 0 and occupied_pos.x < width and occupied_pos.y >= 0 and occupied_pos.y < height:
				# Use a unique key for each position to avoid double counting
				var pos_key = str(occupied_pos.x) + "," + str(occupied_pos.y)
				if not occupied_cells.has(pos_key):
					occupied_cells[pos_key] = true
					total_occupied += 1

	return total_occupied

func add_item(id: String, pos: Vector2, item_resource: ItemResource) -> void:
	items[id] = {
		"item_resource": item_resource,
		"position": pos
	}
	var occupied_cells = count_occupied_cells()
	if occupied_cells == width * height:
		all_cells_occupied = true


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
	for cell in shape:
		var logical_cell_pos = grid_pos + Vector2(cell)
		if not is_position_in_bounds(logical_cell_pos):
			return false
		var existing_item = get_item_at_position(logical_cell_pos)
		if existing_item.has("id"):
			return false
	return true



func draw(drawer: CanvasItem, color: Color, type: String) -> void:
	# Draw grid background
	var background_color = Color(color.r, color.g, color.b, 0.05)

	var grid_rect = Rect2(offset, Vector2(width * cell_size, height * cell_size))
	drawer.draw_rect(grid_rect, background_color, true)

	var c = color
	c.a = 0.3
	# Draw grid lines
	for x in range(width + 1):
		var x_pos = offset.x + x * cell_size
		drawer.draw_line(Vector2(x_pos, offset.y), Vector2(x_pos, offset.y + height * cell_size), c)
	for y in range(height + 1):
		var y_pos = offset.y + y * cell_size
		drawer.draw_line(Vector2(offset.x, y_pos), Vector2(offset.x + width * cell_size, y_pos), c)

	# Draw items
	for id in items.keys():
		var pos = items[id].position
		var item_resource: ItemResource = items[id].item_resource
		var shape = item_resource.get_current_shape()

		# Draw lines around shape
		_draw_item_shape(drawer, pos, shape, type)

		# Draw sprite if available
		if item_resource.sprite_texture != null:
			_draw_item_sprite(drawer, pos, item_resource, shape)

func _draw_item_shape(drawer: CanvasItem, pos: Vector2, shape: PackedVector2Array, type: String) -> void:
	if (type != 'dropin'):
		return

	# Draw only the outline of the shape, not individual cell borders
	_draw_shape_outline(drawer, pos, shape)

func _draw_shape_outline(drawer: CanvasItem, pos: Vector2, shape: PackedVector2Array) -> void:
	# Convert shape cells to a set for quick lookup
	var occupied_cells = {}
	for cell in shape:
		var cell_key = str(cell.x) + "," + str(cell.y)
		occupied_cells[cell_key] = true

	# For each cell, check which edges should be drawn (edges that face empty space)
	for cell in shape:
		var cell_pos = offset + (pos + Vector2(cell)) * cell_size
		var cell_rect = Rect2(cell_pos, Vector2(cell_size, cell_size))

		# Check each edge of the cell
		var neighbors = [
			Vector2(cell.x - 1, cell.y),  # Left
			Vector2(cell.x + 1, cell.y),  # Right
			Vector2(cell.x, cell.y - 1),  # Top
			Vector2(cell.x, cell.y + 1)   # Bottom
		]

		# Draw edges that face empty space
		for i in range(4):
			var neighbor = neighbors[i]
			var neighbor_key = str(neighbor.x) + "," + str(neighbor.y)

			if not occupied_cells.has(neighbor_key):
				# This edge faces empty space, draw it
				match i:
					0: # Left edge
						drawer.draw_line(
							Vector2(cell_rect.position.x, cell_rect.position.y),
							Vector2(cell_rect.position.x, cell_rect.position.y + cell_rect.size.y),
							Color.WHITE, 2
						)
					1: # Right edge
						drawer.draw_line(
							Vector2(cell_rect.position.x + cell_rect.size.x, cell_rect.position.y),
							Vector2(cell_rect.position.x + cell_rect.size.x, cell_rect.position.y + cell_rect.size.y),
							Color.WHITE, 2
						)
					2: # Top edge
						drawer.draw_line(
							Vector2(cell_rect.position.x, cell_rect.position.y),
							Vector2(cell_rect.position.x + cell_rect.size.x, cell_rect.position.y),
							Color.WHITE, 2
						)
					3: # Bottom edge
						drawer.draw_line(
							Vector2(cell_rect.position.x, cell_rect.position.y + cell_rect.size.y),
							Vector2(cell_rect.position.x + cell_rect.size.x, cell_rect.position.y + cell_rect.size.y),
							Color.WHITE, 2
						)

func _draw_item_sprite(drawer: CanvasItem, pos: Vector2, item_resource: ItemResource, shape: PackedVector2Array) -> void:
	var texture = item_resource.sprite_texture

	# Get shape bounds
	var shape_bounds = _get_shape_bounds(item_resource.base_shape)
	var current_bounds = _get_shape_bounds(shape)

	# Calculate sprite size based on original shape
	var sprite_size = Vector2(shape_bounds.size * cell_size)
	var texture_size = texture.get_size()
	var scale = min(sprite_size.x / texture_size.x, sprite_size.y / texture_size.y)
	var final_size = texture_size * scale

	# Position sprite
	var world_pos = offset + pos * cell_size + Vector2(current_bounds.position * cell_size)
	var centered_pos = world_pos + (Vector2(current_bounds.size * cell_size) - final_size) * 0.5
	var sprite_center = centered_pos + final_size * 0.5

	# Draw with rotation
	drawer.draw_set_transform(sprite_center, deg_to_rad(item_resource.rotation_degrees), Vector2.ONE)
	drawer.draw_texture_rect(texture, Rect2(-final_size * 0.5, final_size), false, Color(1, 1, 1, 1))
	drawer.draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func _get_shape_bounds(shape: PackedVector2Array) -> Rect2:
	if shape.is_empty():
		return Rect2(0, 0, 1, 1)

	var min_pos = shape[0]
	var max_pos = shape[0]
	for point in shape:
		min_pos.x = min(min_pos.x, point.x)
		min_pos.y = min(min_pos.y, point.y)
		max_pos.x = max(max_pos.x, point.x)
		max_pos.y = max(max_pos.y, point.y)

	return Rect2(min_pos, max_pos - min_pos + Vector2.ONE)

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
