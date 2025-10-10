@tool
extends EditorPlugin

var inspector_plugin: EditorInspectorPlugin

func _enter_tree() -> void:
    inspector_plugin = AnimatedSpriteImporterInspectorPlugin.new()
    add_inspector_plugin(inspector_plugin)

func _exit_tree() -> void:
    if inspector_plugin != null:
        remove_inspector_plugin(inspector_plugin)
        inspector_plugin.free()
        inspector_plugin = null
