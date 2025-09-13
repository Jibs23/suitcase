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
