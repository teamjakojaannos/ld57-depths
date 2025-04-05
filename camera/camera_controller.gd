@tool
extends Camera2D

@export var tile_size_in_px: int = 16
@export var level_height_in_tiles: int = 20

var level_height_in_px: float:
	get:
		return level_height_in_tiles * tile_size_in_px

@export_category("Debug")
@export_tool_button("Refresh preview")
var _refresh_preview_button: Callable = _on_resized

func _ready() -> void:
	_on_resized()
	if not Engine.is_editor_hint():
		get_window().size_changed.connect(_on_resized)

func _on_resized() -> void:
	var new_height: float = get_viewport_rect().size.y * 1.0
	if Engine.is_editor_hint():
		new_height = ProjectSettings.get_setting("display/window/size/viewport_height")

	var zoom_amount = new_height / level_height_in_px
	zoom = Vector2(zoom_amount, zoom_amount)
	position.x = 0
	position.y = level_height_in_px * -0.5

	print("Repositioned camera at %s x%s" % [position, zoom_amount])
