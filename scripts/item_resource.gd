extends Resource
class_name ItemResource

@export var item_name: String = ""
@export var sprite_texture: Texture2D
@export var base_shape: PackedVector2Array = PackedVector2Array()
@export var rotation_degrees: float = 0.0

# Cached rotated shape to avoid recalculating every time
var _cached_shape: PackedVector2Array
var _cached_rotation: float = -999.0

func get_current_shape() -> PackedVector2Array:
	# Return cached shape if rotation hasn't changed
	if _cached_rotation == rotation_degrees and not _cached_shape.is_empty():
		return _cached_shape

	# Calculate rotated shape
	_cached_shape = _rotate_shape(base_shape, rotation_degrees)
	_cached_rotation = rotation_degrees
	return _cached_shape

func rotate_clockwise() -> void:
	rotation_degrees += 90.0
	if rotation_degrees >= 360.0:
		rotation_degrees -= 360.0

func rotate_counter_clockwise() -> void:
	rotation_degrees -= 90.0
	if rotation_degrees < 0.0:
		rotation_degrees += 360.0

func _rotate_shape(shape: PackedVector2Array, degrees: float) -> PackedVector2Array:
	if degrees == 0.0:
		return shape

	# Debug: print("Rotating shape ", shape, " by ", degrees, " degrees")

	var rotated_shape = PackedVector2Array()

	# For 90-degree increments, use simple transformation rules
	var steps = int(degrees / 90.0) % 4
	if steps < 0:
		steps += 4

	for point in shape:
		var new_point = point

		# Apply 90-degree rotations
		for i in range(steps):
			# 90-degree clockwise rotation: (x, y) -> (-y, x)
			var temp_x = new_point.x
			new_point.x = -new_point.y
			new_point.y = temp_x

		rotated_shape.append(new_point)

	# Normalize shape to ensure all coordinates are non-negative
	var result = _normalize_shape(rotated_shape)

	return result

func _normalize_shape(shape: PackedVector2Array) -> PackedVector2Array:
	if shape.is_empty():
		return shape

	# Find minimum x and y values
	var min_x = shape[0].x
	var min_y = shape[0].y

	for point in shape:
		min_x = min(min_x, point.x)
		min_y = min(min_y, point.y)

	# Offset all points to make minimum values 0
	var normalized_shape = PackedVector2Array()
	for point in shape:
		normalized_shape.append(Vector2(point.x - min_x, point.y - min_y))

	return normalized_shape
