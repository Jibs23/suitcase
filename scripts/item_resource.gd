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
	
	var rotated_shape = PackedVector2Array()
	var rad = deg_to_rad(degrees)
	var cos_angle = cos(rad)
	var sin_angle = sin(rad)
	
	for point in shape:
		# Rotate around origin
		var rotated_x = point.x * cos_angle - point.y * sin_angle
		var rotated_y = point.x * sin_angle + point.y * cos_angle
		rotated_shape.append(Vector2(round(rotated_x), round(rotated_y)))
	
	# Normalize shape to ensure all coordinates are non-negative
	return _normalize_shape(rotated_shape)

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
