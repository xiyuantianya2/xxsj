extends TileMap

# 简单的像素风格地图
class_name TileMap

func _ready():
	# 初始化地图
	pass

func get_tile_at(position: Vector2) -> int:
	return get_cell_source_id(0, position)

func set_tile_at(position: Vector2, tile_id: int):
	set_cell(0, position, tile_id, Vector2i(0, 0))
