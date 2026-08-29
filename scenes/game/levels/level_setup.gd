extends Node2D

@onready var background_layer: TileMapLayer = $Background
@onready var normal_tiles: TileMapLayer = $"Normal Tiles"
@onready var fake_tiles: TileMapLayer = $"Visibility/Fake Tiles"
@onready var invis_tiles: TileMapLayer = $"Visibility/Invis Tiles"

func _ready() -> void:
	fill_background()
	ensure_spawn_lights()

func fill_background() -> void:
	if not background_layer.get_used_cells().is_empty():
		return
	if not normal_tiles.tile_set:
		return
	var bg_source := _background_source_id(normal_tiles.tile_set)
	if bg_source == -1:
		return
	var min_cell := Vector2i(1 << 30, 1 << 30)
	var max_cell := Vector2i(-(1 << 30), -(1 << 30))
	for layer in [normal_tiles, fake_tiles, invis_tiles]:
		for cell in layer.get_used_cells():
			min_cell = min_cell.min(cell)
			max_cell = max_cell.max(cell)
	if max_cell.x < min_cell.x or max_cell.y < min_cell.y:
		return
	for x in range(min_cell.x, max_cell.x + 1):
		for y in range(min_cell.y, max_cell.y + 1):
			background_layer.set_cell(Vector2i(x, y), bg_source, Vector2i(0, 0))

func _background_source_id(tile_set: TileSet) -> int:
	for index in range(tile_set.get_source_count()):
		var source_id := tile_set.get_source_id(index)
		var source := tile_set.get_source(source_id)
		if source is TileSetAtlasSource and source.resource_name == "background":
			return source_id
	return -1

func ensure_spawn_lights() -> void:
	if has_node("Spawn Lights"):
		return
	var source_light := get_node_or_null("lighting/PointLight2D3") as PointLight2D
	if source_light == null or source_light.texture == null:
		return
	var origin := _spawn_position()
	var lights_node := Node.new()
	lights_node.name = "Spawn Lights"
	for light in _light_pair(source_light.texture):
		light.position = origin
		lights_node.add_child(light)
	add_child(lights_node)

func _spawn_position() -> Vector2:
	var player := get_node_or_null("Player")
	return player.global_position if player else Vector2.ZERO

func _light_pair(texture: Texture2D) -> Array[PointLight2D]:
	var light := PointLight2D.new()
	light.texture = texture
	light.scale = Vector2(8, 6)
	light.energy = 1.2
	light.shadow_enabled = true
	light.shadow_filter = 2
	return [light]
