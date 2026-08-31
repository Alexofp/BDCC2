@tool
extends EditorPlugin

const ImportWindow = preload("res://addons/streamed_texture_reimport_tool/streaming_texture_import.tscn")

var window : Window

func _enter_tree():
    add_tool_menu_item("StreamedTexture2D Re-import Tool", _stream_texture_import_tool)


func _exit_tree():
    remove_tool_menu_item("StreamedTexture2D Re-import Tool")
    if window:
        window.queue_free()


func _stream_texture_import_tool():
    if not window:
        window = ImportWindow.instantiate()
        get_editor_interface().get_base_control().add_child(window)
    
    window.popup_centered()
