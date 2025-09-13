extends Node2D

var inventory_grid: Grid
var dropin_grid: Grid

var GRID_CELL_SIZE := 32

func _ready() -> void:
	# Setup grids
	inventory_grid = Grid.new()
	inventory_grid.width = 3
	inventory_grid.height = 10
	inventory_grid.cell_size = GRID_CELL_SIZE
	inventory_grid.offset = Vector2(0, 0)

	dropin_grid = Grid.new()
	dropin_grid.width = 10
	dropin_grid.height = 10
	dropin_grid.cell_size = GRID_CELL_SIZE
	dropin_grid.offset = Vector2(200, 0)

	# Example items
	var shape = PackedVector2Array([Vector2(0,0), Vector2(1,0), Vector2(0,1)]) # L-shape
	dropin_grid.add_item(Vector2(1, 1), shape)
	inventory_grid.add_item(Vector2(2, 2), shape)

func _draw() -> void:
	inventory_grid.draw(self, Color.GREEN)
	dropin_grid.draw(self, Color.ORANGE)
