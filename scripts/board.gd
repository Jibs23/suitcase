extends Node2D

var inventory_grid: Grid
var dropin_grid: Grid
var GRID_CELL_SIZE := 32

# Drag variables
var dragging_item: Dictionary = {}
var is_dragging: bool = false
var drag_preview_item: ItemResource
var drag_offset: Vector2
var mouse_pos: Vector2

func _init() -> void:
	Logic.board = self

func _ready() -> void:
	inventory_grid = _create_grid(8, 12, Vector2(100, 150))  # Double the grid size for 2x effect
	dropin_grid = _create_grid(10, 10, Vector2(700, 120))      # Double the grid size for 2x effect
	z_index = 10

	# Create items with 2x2 scaling for each logical cell (simpler shape definitions)
	inventory_grid.add_item("Coins", Vector2(4, 4), _create_item("Coins", _make_2x2_square(), "res://assets/1x1_coins.png"))
	inventory_grid.add_item("FireJar", Vector2(6, 4), _create_item("FireJar", _make_2x2_square(), "res://assets/1x1_fireJar.png"))
	inventory_grid.add_item("Dagger", Vector2(6, 2), _create_item("Dagger", _make_3x2_rect_top(), "res://assets/3x2_dagger.png"))
	inventory_grid.add_item("Pouches", Vector2(2, 6), _create_item("Pouches", _make_3x2_rect_bottom(), "res://assets/3x2_pouches.png"))
	inventory_grid.add_item("Mushrooms", Vector2(4, 6), _create_item("Mushrooms", _make_2x2_L(), "res://assets/2x2_L_mushrooms.png"))

func _create_grid(width: int, height: int, offset: Vector2) -> Grid:
	var grid = Grid.new()
	grid.width = width
	grid.height = height
	grid.cell_size = GRID_CELL_SIZE
	grid.offset = offset
	return grid

func _create_item(item_name: String, shape_array: Array, texture_path: String = "") -> ItemResource:
	var item = ItemResource.new()
	item.item_name = item_name
	item.base_shape = PackedVector2Array(shape_array)
	if texture_path != "" and ResourceLoader.exists(texture_path):
		item.sprite_texture = load(texture_path)
	return item

# Helper functions for common shapes (2x2 scaling)
func _make_2x2_square() -> Array:
	return [Vector2(0,0), Vector2(1,0), Vector2(0,1), Vector2(1,1)]

func _make_3x2_rect_top() -> Array:
	# 3x2 rectangle with handle at bottom (dagger shape)
	return [
		Vector2(0,-2), Vector2(1,-2), Vector2(2,-2), Vector2(3,-2), Vector2(4,-2), Vector2(5,-2),
		Vector2(0,-1), Vector2(1,-1), Vector2(2,-1), Vector2(3,-1), Vector2(4,-1), Vector2(5,-1),
		Vector2(4,0), Vector2(5,0), Vector2(4,1), Vector2(5,1)
	]

func _make_3x2_rect_bottom() -> Array:
	# 3x2 rectangle with handle at top (pouches shape)
	return [
		Vector2(0,2), Vector2(1,2), Vector2(2,2), Vector2(3,2), Vector2(4,2), Vector2(5,2),
		Vector2(0,3), Vector2(1,3), Vector2(2,3), Vector2(3,3), Vector2(4,3), Vector2(5,3),
		Vector2(2,0), Vector2(3,0), Vector2(2,1), Vector2(3,1)
	]

func _make_2x2_L() -> Array:
	# L-shaped 2x2 with extension (mushrooms shape)
	return [
		Vector2(0,0), Vector2(1,0), Vector2(2,0), Vector2(3,0),
		Vector2(0,1), Vector2(1,1), Vector2(2,1), Vector2(3,1),
		Vector2(0,-2), Vector2(1,-2), Vector2(0,-1), Vector2(1,-1)
	]

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag(event.position)
		else:
			_end_drag(event.position)
	elif event is InputEventKey and event.keycode == KEY_U and event.pressed:
		_rotate_dragging_item()
	elif event is InputEventMouseMotion:
		mouse_pos = event.position
		if is_dragging:
			queue_redraw()

func _rotate_dragging_item() -> void:
	if not is_dragging:
		return
	dragging_item.item_resource.rotate_clockwise()
	Logic.audio_manager.play_sound("rotate_cw", true)
	queue_redraw()



func _start_drag(pos: Vector2) -> void:
	var grids = [inventory_grid, dropin_grid]
	#TODO: fix so sound only plays when you actually pick up an item.
	#TODO: Make speedrun timer start and stop when picking up item.
	Logic.audio_manager.play_sound("item_pickup", true)
	for grid in grids:
		var drag_data = grid.try_start_drag(pos)
		if not drag_data.is_empty():
			dragging_item = drag_data
			drag_preview_item = drag_data.item_resource
			drag_offset = drag_data.drag_offset
			grid.remove_item(drag_data.id)
			is_dragging = true
			queue_redraw()
			return

func _end_drag(pos: Vector2) -> void:
	if not is_dragging:
		return

	var target_pos = pos - drag_offset
	var grids = [dropin_grid, inventory_grid]  # Try dropin first

	Logic.audio_manager.play_sound("item_drop", true)
	for grid in grids:
		var placed_id = grid.try_place_item(target_pos, dragging_item.item_resource, dragging_item.id)
		if placed_id != "":
			_reset_drag()
			return

	# If couldn't place anywhere, return to original position
	dragging_item.grid.add_item(dragging_item.id, dragging_item.position, dragging_item.item_resource)
	_reset_drag()

func _reset_drag() -> void:
	is_dragging = false
	dragging_item.clear()
	queue_redraw()

func _draw() -> void:
	inventory_grid.draw(self, Color.BLACK, 'inventory')
	dropin_grid.draw(self, Color.BROWN, 'dropin')

	if is_dragging:
		_draw_drag_preview()

func _draw_drag_preview() -> void:
	var drag_pos = mouse_pos - drag_offset
	var can_place = _can_place_anywhere(drag_pos)

	# Draw placement preview
	_draw_placement_preview(drag_pos, can_place)

	# Draw dragged item
	var color = Color.RED if !can_place else Color.GREEN
	color.a = 0.1

	# Draw sprite if available
	if drag_preview_item.sprite_texture:
		_draw_item_sprite(drag_pos, can_place)

func _can_place_anywhere(drag_pos: Vector2) -> bool:
	var grids = [dropin_grid, inventory_grid]
	for grid in grids:
		if grid.can_place_item_at_world_pos(drag_pos, drag_preview_item):
			return true
	return false

func _draw_placement_preview(drag_pos: Vector2, can_place: bool) -> void:
	if not can_place:
		return

	var grids = [dropin_grid, inventory_grid]
	for grid in grids:
		if grid.can_place_item_at_world_pos(drag_pos, drag_preview_item):
			var grid_pos = grid.world_to_grid(drag_pos)
			_draw_item_shape(grid.grid_to_world(grid_pos), drag_preview_item.get_current_shape(), Color(0, 1, 0, 0.5))
			return

func _draw_item_shape(pos: Vector2, shape: PackedVector2Array, color: Color) -> void:
	for cell in shape:
		var cell_pos = pos + Vector2(cell * GRID_CELL_SIZE)
		draw_rect(Rect2(cell_pos, Vector2(GRID_CELL_SIZE, GRID_CELL_SIZE)), color, true)
		draw_rect(Rect2(cell_pos, Vector2(GRID_CELL_SIZE, GRID_CELL_SIZE)), Color.WHITE, false, 2)

func _draw_item_sprite(pos: Vector2, can_place: bool) -> void:
	var texture = drag_preview_item.sprite_texture
	var shape = drag_preview_item.get_current_shape()

	# Get shape bounds for positioning and sizing
	var original_bounds = _get_shape_bounds(drag_preview_item.base_shape)
	var current_bounds = _get_shape_bounds(shape)

	# Calculate sprite size based on original shape (consistent scaling)
	var sprite_area = Vector2(original_bounds.size * GRID_CELL_SIZE)
	var texture_size = texture.get_size()
	var scale_factor = min(sprite_area.x / texture_size.x, sprite_area.y / texture_size.y)
	var final_size = texture_size * scale_factor

	# Position sprite at current shape bounds
	var sprite_pos = pos + Vector2(current_bounds.position * GRID_CELL_SIZE)
	var current_area = Vector2(current_bounds.size * GRID_CELL_SIZE)
	var centered_pos = sprite_pos + (current_area - final_size) * 0.5
	var sprite_center = centered_pos + final_size * 0.5

	var color = Color.RED if not can_place else Color(1, 1, 1, 0.8)

	draw_set_transform(sprite_center, deg_to_rad(drag_preview_item.rotation_degrees), Vector2.ONE)
	draw_texture_rect(texture, Rect2(-final_size * 0.5, final_size), false, color)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

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
