extends Sprite2D

func _ready() -> void:
    var viewport_size = get_viewport_rect().size
    var tex_size = texture.get_size()
    # scale = viewport_size / tex_size