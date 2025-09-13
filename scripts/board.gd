extends Node2D

# Inventory grid
@export var inv_cell_size: int = 32
@export var inv_width: int = 5
@export var inv_height: int = 5
@export var inv_offset: Vector2 = Vector2(0, 0)

# Drop-in grid
@export var drop_cell_size: int = 32
@export var drop_width: int = 8
@export var drop_height: int = 8
@export var drop_offset: Vector2 = Vector2(200, 0)

func _draw() -> void:
    _draw_grid(inv_offset, inv_width, inv_height, inv_cell_size, Color.WHITE)
    _draw_grid(drop_offset, drop_width, drop_height, drop_cell_size, Color.GRAY)

func _draw_grid(offset: Vector2, width: int, height: int, cell_size: int, color: Color) -> void:
    # Vertical lines
    for x in range(width + 1):
        var x_pos = offset.x + x * cell_size
        draw_line(Vector2(x_pos, offset.y), Vector2(x_pos, offset.y + height * cell_size), color)

    # Horizontal lines
    for y in range(height + 1):
        var y_pos = offset.y + y * cell_size
        draw_line(Vector2(offset.x, y_pos), Vector2(offset.x + width * cell_size, y_pos), color)
