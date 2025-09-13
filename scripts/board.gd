extends Node2D

var inventory_grid: Grid
var dropin_grid: Grid

var GRID_CELL_SIZE := 32

# Drag and drop variables
var dragging_item: Dictionary = {}

var drag_offset: Vector2 = Vector2.ZERO
var is_dragging: bool = false
var drag_preview_shape: PackedVector2Array
var mouse_pos: Vector2

func _init() -> void:
	Logic.board = self

func _ready() -> void:
	# Setup grids
	inventory_grid = Grid.new()
	inventory_grid.width = 8
	inventory_grid.height = 12
	inventory_grid.cell_size = GRID_CELL_SIZE
	inventory_grid.offset = Vector2(0, 0)

	dropin_grid = Grid.new()
	dropin_grid.width = 10
	dropin_grid.height = 10
	dropin_grid.cell_size = GRID_CELL_SIZE
	dropin_grid.offset = Vector2(1500, 0)

	# Set this node's z-index to be above sprites
	z_index = 1

	# Example items"
	var shape = PackedVector2Array([Vector2(0,0), Vector2(1,0), Vector2(0,1)])
	dropin_grid.add_item(Vector2(1, 1), shape)
	inventory_grid.add_item(Vector2(2, 2), shape)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.position)
			else:
				_end_drag(event.position)
	elif event is InputEventMouseMotion:
		mouse_pos = event.position
		if is_dragging:
			queue_redraw()



func _resize_grids() -> void:
	var screen_size = get_viewport_rect().size

	# Example: inventory on left, dropin on right
	# Both should fit vertically, so base cell size on height
	var max_rows = max(inventory_grid.height, dropin_grid.height)
	var cell_size = floor(screen_size.y / max_rows)

	inventory_grid.cell_size = cell_size
	dropin_grid.cell_size = cell_size

	# Inventory flush left
	inventory_grid.offset = Vector2(0, 0)

	# Dropin placed to the right, with margin
	var inv_width_px = inventory_grid.width * cell_size
	var drop_width_px = dropin_grid.width * cell_size
	var total_width = inv_width_px + drop_width_px

	# Center them horizontally
	var start_x = (screen_size.x - total_width) / 2.0
	inventory_grid.offset.x = start_x
	dropin_grid.offset.x = start_x + inv_width_px


func _start_drag(click_pos: Vector2) -> void:
	# Check inventory grid first
	var inv_grid_pos = inventory_grid.world_to_grid(click_pos)
	var item_data = inventory_grid.get_item_at_position(inv_grid_pos)

	if item_data.has("position"):
		dragging_item = {"grid": inventory_grid, "position": item_data.position, "shape": item_data.shape}
		drag_preview_shape = item_data.shape
		drag_offset = click_pos - inventory_grid.grid_to_world(item_data.position)
		inventory_grid.remove_item(item_data.position)
		is_dragging = true
		queue_redraw()
		return

	# Check dropin grid
	var drop_grid_pos = dropin_grid.world_to_grid(click_pos)
	item_data = dropin_grid.get_item_at_position(drop_grid_pos)

	if item_data.has("position"):
		dragging_item = {"grid": dropin_grid, "position": item_data.position, "shape": item_data.shape}
		drag_preview_shape = item_data.shape
		drag_offset = click_pos - dropin_grid.grid_to_world(item_data.position)
		dropin_grid.remove_item(item_data.position)
		is_dragging = true
		queue_redraw()

func _end_drag(release_pos: Vector2) -> void:
	if not is_dragging:
		return

	var placed = false

	# Try to place in dropin grid first
	var target_pos = dropin_grid.world_to_grid(release_pos - drag_offset)
	if dropin_grid.can_place_item(target_pos, dragging_item.shape):
		dropin_grid.add_item(target_pos, dragging_item.shape)
		placed = true

	# If that fails, try inventory grid
	if not placed:
		target_pos = inventory_grid.world_to_grid(release_pos - drag_offset)
		if inventory_grid.can_place_item(target_pos, dragging_item.shape):
			inventory_grid.add_item(target_pos, dragging_item.shape)
			placed = true

	# If still not placed, return to original position
	if not placed:
		dragging_item.grid.add_item(dragging_item.position, dragging_item.shape)

	# Reset drag state
	is_dragging = false
	dragging_item.clear()
	queue_redraw()

func _draw() -> void:
	inventory_grid.draw(self, Color.GREEN)
	dropin_grid.draw(self, Color.ORANGE)

	# Draw dragging item and drop preview
	if is_dragging:
		var drag_pos = mouse_pos - drag_offset

		# Check if we can place at current position
		var can_place_in_dropin = false
		var can_place_in_inventory = false
		var target_pos_dropin = dropin_grid.world_to_grid(mouse_pos - drag_offset)
		var target_pos_inventory = inventory_grid.world_to_grid(mouse_pos - drag_offset)

		if dropin_grid.can_place_item(target_pos_dropin, drag_preview_shape):
			can_place_in_dropin = true
			# Draw valid placement preview in dropin grid
			for cell in drag_preview_shape:
				var grid_pos = target_pos_dropin + Vector2(cell)
				var world_pos = dropin_grid.grid_to_world(grid_pos)
				draw_rect(Rect2(world_pos, Vector2(GRID_CELL_SIZE, GRID_CELL_SIZE)), Color(0, 1, 0, 0.5), true)
				draw_rect(Rect2(world_pos, Vector2(GRID_CELL_SIZE, GRID_CELL_SIZE)), Color.WHITE, false, 2)


		if inventory_grid.can_place_item(target_pos_inventory, drag_preview_shape):
			can_place_in_inventory = true
			# Draw valid placement preview in inventory grid (only if not placing in dropin)
			if not can_place_in_dropin:
				for cell in drag_preview_shape:
					var grid_pos = target_pos_inventory + Vector2(cell)
					var world_pos = inventory_grid.grid_to_world(grid_pos)
					draw_rect(Rect2(world_pos, Vector2(GRID_CELL_SIZE, GRID_CELL_SIZE)), Color(0, 1, 0, 0.5), true)
					draw_rect(Rect2(world_pos, Vector2(GRID_CELL_SIZE, GRID_CELL_SIZE)), Color.WHITE, false, 2)

		# Draw the item being dragged
		var item_color = Color.BLUE
		if not can_place_in_dropin and not can_place_in_inventory:
			item_color = Color.RED  # Show red if can't place anywhere

		for cell in drag_preview_shape:
			var cell_world_pos = drag_pos + Vector2(cell * GRID_CELL_SIZE)
			draw_rect(Rect2(cell_world_pos, Vector2(GRID_CELL_SIZE, GRID_CELL_SIZE)), Color(item_color.r, item_color.g, item_color.b, 0.8), true)
			draw_rect(Rect2(cell_world_pos, Vector2(GRID_CELL_SIZE, GRID_CELL_SIZE)), Color.WHITE, false, 2)
