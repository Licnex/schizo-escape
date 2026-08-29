extends Node

@onready var invis_tiles: TileMapLayer = $"Invis Tiles"

func _ready() -> void:
	invis_tiles.modulate.a = 0.0
