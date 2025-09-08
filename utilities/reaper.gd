## For over-engineering signal connections to queue_free()
@tool
extends Node
class_name Reaper

## You generally NEVER want to set to `true` as that is a guaranteed way of
## accidentally deleting the scene you are working on. The only exception are
## e.g. "preview" nodes spawned via tool-scripts.
var allow_reaping_in_editor: bool = false

func reap() -> void:
	if Engine.is_editor_hint() and !allow_reaping_in_editor:
		return

	get_parent().queue_free()
