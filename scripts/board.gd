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
	inventory_grid = _create_grid(8, 12, Vector2(100, 150))
	dropin_grid = _create_grid(10, 10, Vector2(700, 120))
	z_index = 10

	# inventory_grid.add_item(Vector2(2, 2), _create_item("Coins", [Vector2(0,0)], "res://assets/1x1_coins.png"))
	inventory_grid.add_item(Vector2(3, 2), _create_item("FireJar", [Vector2(0,0)], "res://assets/1x1_fireJar.png"))
	inventory_grid.add_item(Vector2(3, 1), _create_item("Dagger", [Vector2(0,-1), Vector2(1,-1),Vector2(2,-1), Vector2(2,0)], "res://assets/3x2_dagger.png"))
	# inventory_grid.add_item(Vector2(1, 3), _create_item("Pouches", [Vector2(0,1), Vector2(1,1),Vector2(1,0), Vector2(2,1)], "res://assets/3x2_pouches.png"))
	# inventory_grid.add_item(Vector2(2, 3), _create_item("Mushrooms", [Vector2(0,0), Vector2(1,0), Vector2(0,-1)], "res://assets/2x2_L_mushrooms.png"))

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

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drag(event.position)
		else:
			_end_drag(event.position)
	elif event is InputEventKey and event.keycode == KEY_U and event.pressed:
		_rotate_item_at_position(mouse_pos)

	elif event is InputEventMouseMotion:
		mouse_pos = event.position
		if is_dragging:
			queue_redraw()

func _rotate_item_at_position(pos: Vector2) -> void:
	var grids = [inventory_grid, dropin_grid]
	for grid in grids:
		if grid.try_rotate_item_at_position(pos):
			queue_redraw()
			Logic.audio_manager.play_sound("rotate_cw")
			return

func _process(_delta: float) -> void:
	print("Update called", inventory_grid.items)

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
			grid.remove_item(drag_data.position)
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
		if grid.try_place_item(target_pos, dragging_item.item_resource):
			_reset_drag()
			return

	# If couldn't place anywhere, return to original position
	dragging_item.grid.add_item(dragging_item.position, dragging_item.item_resource)
	_reset_drag()

func _reset_drag() -> void:
	is_dragging = false
	dragging_item.clear()
	queue_redraw()

func _draw() -> void:
	inventory_grid.draw(self, Color.BLACK)
	dropin_grid.draw(self, Color.ORANGE)

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
	var item_scale_factor = 2  # Match the grid's scaling
	for cell in shape:
		var cell_pos = pos + Vector2(cell * GRID_CELL_SIZE * item_scale_factor)
		var scaled_size = GRID_CELL_SIZE * item_scale_factor
		draw_rect(Rect2(cell_pos, Vector2(scaled_size, scaled_size)), color, true)
		draw_rect(Rect2(cell_pos, Vector2(scaled_size, scaled_size)), Color.WHITE, false, 2)

func _draw_item_sprite(pos: Vector2, can_place: bool) -> void:
	var texture = drag_preview_item.sprite_texture
	var shape = drag_preview_item.get_current_shape()

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

	# Calculate sprite area covering the entire shape (accounting for scaling)
	var item_scale_factor = 2  # Match the grid's scaling
	var shape_width = (max_x - min_x + 1) * GRID_CELL_SIZE * item_scale_factor
	var shape_height = (max_y - min_y + 1) * GRID_CELL_SIZE * item_scale_factor
	var sprite_area_size = Vector2(shape_width, shape_height)

	# Position sprite at the top-left of the bounding box (accounting for scaling)
	var sprite_pos = pos + Vector2(min_x, min_y) * GRID_CELL_SIZE * item_scale_factor

	# Scale sprite to fit the entire shape area
	var texture_size = texture.get_size()
	var scale_factor = min(sprite_area_size.x / texture_size.x, sprite_area_size.y / texture_size.y)
	var scaled_size = texture_size * scale_factor

	# Center the sprite within the shape area
	var centered_pos = sprite_pos + (sprite_area_size - scaled_size) * 0.5

	var sprite_transform = Transform2D()
	sprite_transform = sprite_transform.rotated(deg_to_rad(drag_preview_item.rotation_degrees))
	sprite_transform.origin = centered_pos + scaled_size * 0.5

	var color = Color.RED if not can_place else Color(1, 1, 1, 0.8)

	draw_set_transform(sprite_transform.origin, sprite_transform.get_rotation(), Vector2.ONE)
	draw_texture_rect(texture, Rect2(-scaled_size * 0.5, scaled_size), false, color)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)
