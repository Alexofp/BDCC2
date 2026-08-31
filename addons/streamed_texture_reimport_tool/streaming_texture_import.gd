@tool
extends Window

# Stores the filtered file paths for display
var file_paths: Array = []
# Stores all file paths for filtering
var all_file_paths: Array = []
var filter_line_edit: LineEdit = null
var tree: Tree = null
var all_button: Button = null
var none_button: Button = null
var error_dialog: AcceptDialog = null
var error_label: RichTextLabel = null
var failed_files_for_dialog: PackedStringArray = PackedStringArray()

func _ready():
	_initialize();

func _initialize():
	
	# Get references to UI elements
	filter_line_edit = %Filter
	all_button = %All
	none_button = %None
	tree = %Tree

	error_dialog = AcceptDialog.new()
	error_dialog.title = "Streamed Texture Import"
	error_dialog.add_button("Copy", true, "copy_failed")
	error_dialog.custom_action.connect(_on_error_dialog_action)
	error_label = RichTextLabel.new()
	error_label.bbcode_enabled = true
	error_label.selection_enabled = true
	error_label.scroll_active = true
	error_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	error_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	error_label.meta_clicked.connect(_on_error_label_meta_clicked)
	error_dialog.add_child(error_label)
	add_child(error_dialog)
	
	# Configure the tree
	tree.column_titles_visible = true
	tree.hide_root = true
	tree.columns = 4
	tree.set_column_title(0, "Select")
	tree.set_column_title(1, "Format")
	tree.set_column_title(2, "W x H")
	tree.set_column_title(3, "Path")
	tree.set_column_expand(0, false)
	tree.set_column_expand(1, false)
	tree.set_column_expand(2, false)
	tree.set_column_expand(3, true)
	tree.set_column_custom_minimum_width(0, 70)
	tree.set_column_custom_minimum_width(1, 140)
	tree.set_column_custom_minimum_width(2, 90)
	
	visibility_changed.connect(_on_visibility_changed)
	
	var efs = EditorInterface.get_resource_filesystem()
	efs.scan_sources()
	
	# Load the texture imports
	update_grid_from_imports()


func _on_visibility_changed() -> void:
	if visible:
		update_grid_from_imports()


func _on_cancel_pressed():
	hide()


func _on_close_requested():
	hide()


func _on_all_pressed():
	var root = tree.get_root()
	if root:
		var item = root.get_first_child()
		while item:
			item.set_checked(0, true)
			item = item.get_next()


func _on_none_pressed():
	var root = tree.get_root()
	if root:
		var item = root.get_first_child()
		while item:
			item.set_checked(0, false)
			item = item.get_next()


func _on_filter_text_changed(new_text: String):
	_apply_filter()


func update_grid_from_imports():
	clear_grid()
	all_file_paths.clear()
	var matches = find_texture_imports("res://")
	for entry in matches:
		if entry.has("source_file") and entry["source_file"] != "":
			all_file_paths.append(entry["source_file"])
	all_file_paths.sort()
	_apply_filter()


func populate_grid():
	var root = tree.get_root()
	if not root:
		root = tree.create_item()
	
	# Clear existing items
	var child = root.get_first_child()
	while child:
		var next = child.get_next()
		child.free()
		child = next
	
	# Add filtered paths
	for path in file_paths:
		var texture: Texture2D = ResourceLoader.load(path, "", 1)
		if texture == null:
			continue
		var image := texture.get_image()
		if image == null:
			continue
		var format_text = _get_format_name(image.get_format())
		var width := image.get_width()
		var height := image.get_height()
		
		var item = tree.create_item(root)
		item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		item.set_checked(0, false)
		item.set_editable(0, true)
		item.set_text(1, format_text)
		item.set_text(2, "{0} x {1}".format([str(width), str(height)]))
		item.set_text(3, path)


func _apply_filter():
	var filter_text = ""
	if filter_line_edit:
		filter_text = filter_line_edit.text.strip_edges().to_lower()
	file_paths.clear()
	for path in all_file_paths:
		if filter_text == "" or filter_text in path.to_lower():
			file_paths.append(path)
	populate_grid()


func find_texture_imports(root_path: String) -> Array:
	var results: Array = []
	var stack: Array = [root_path]

	while stack.size() > 0:
		var path: String = stack.pop_back()
		var dir := DirAccess.open(path)
		if dir == null:
			continue

		dir.list_dir_begin()
		var name = dir.get_next()
		while name != "":
			var full := path.path_join(name)
			if dir.current_is_dir():
				stack.append(full)
			else:
				if full.ends_with(".import"):
					var cfg := ConfigFile.new()
					var err := cfg.load(full)
					if err == OK:
						var importer := str(cfg.get_value("remap", "importer", ""))
						var type := str(cfg.get_value("remap", "type", ""))
						var mode := int(cfg.get_value("params", "compress/mode", ""))
						if importer == "texture" and type == "CompressedTexture2D" and mode == 2:
							var source_file : String = cfg.get_value("deps", "source_file", "")
							results.append({
								"import_file": full,
								"source_file": source_file
							})
			name = dir.get_next()

		dir.list_dir_end()

	return results


func clear_grid() -> void:
	var root = tree.get_root()
	if root:
		var child = root.get_first_child()
		while child:
			var next = child.get_next()
			child.free()
			child = next
	else:
		tree.create_item()


func _on_reimport_pressed():
	# Collect checked items from the tree and reimport their source files
	var root = tree.get_root()
	if not root:
		print("No items in tree to reimport")
		return

	var files: PackedStringArray = PackedStringArray()
	var item = root.get_first_child()
	while item:
		if item.is_checked(0):
			var path = item.get_text(3)
			# Only add non-empty paths
			if path != "":
				files.append(path)
		item = item.get_next()

	if files.size() == 0:
		print("No checked items to reimport")
		return
		
	var efs = EditorInterface.get_resource_filesystem()
	var failed_files: PackedStringArray = PackedStringArray()
	
	for file in files:
		var path = file + ".import"
		var cfg := ConfigFile.new()
		var err := cfg.load(path)
		if err == OK:
			cfg.set_value("remap", "importer", "streamed_texture_2d")
			cfg.set_value("remap", "type", "StreamedTexture2D")
			if cfg.save(path) == OK:
				efs.update_file(file)
			else:
				failed_files.append(file)
		else:
			failed_files.append(file)

	var baseControl = EditorInterface.get_base_control()
	baseControl.get_tree().process_frame.connect(func():
		var file_system = EditorInterface.get_resource_filesystem()
		file_system.reimport_files(files)
		for file in files:
			file_system.update_file(file)
		if failed_files.size() > 0:
			if error_dialog:
				failed_files_for_dialog = failed_files.duplicate()
				var message := "Failed to update .import for %d files:\n\n" % failed_files.size()
				for failed_file in failed_files:
					message += "[url=%s]%s[/url]\n" % [failed_file, failed_file]
				if error_label:
					error_label.text = message
				error_dialog.popup_centered()
	, CONNECT_ONE_SHOT)
	hide()

func _on_refresh_pressed():
	populate_grid()
	pass # Replace with function body.


func _on_error_dialog_action(action: StringName) -> void:
	if action != "copy_failed":
		return
	if failed_files_for_dialog.is_empty():
		return
	var text := ""
	for i in range(failed_files_for_dialog.size()):
		if i > 0:
			text += "\n"
		text += failed_files_for_dialog[i]
	DisplayServer.clipboard_set(text)


func _on_error_label_meta_clicked(meta: Variant) -> void:
	var path := String(meta)
	var resource := ResourceLoader.load(path)
	if resource != null:
		EditorInterface.edit_resource(resource)


func _get_format_name(format: int) -> String:
	match format:
		Image.FORMAT_L8:
			return "L8"
		Image.FORMAT_LA8:
			return "LA8"
		Image.FORMAT_R8:
			return "R8"
		Image.FORMAT_RG8:
			return "RG8"
		Image.FORMAT_RGB8:
			return "RGB8"
		Image.FORMAT_RGBA8:
			return "RGBA8"
		Image.FORMAT_RGBA4444:
			return "RGBA4444"
		Image.FORMAT_RGB565:
			return "RGB565"
		Image.FORMAT_RF:
			return "RF"
		Image.FORMAT_RGF:
			return "RGF"
		Image.FORMAT_RGBF:
			return "RGBF"
		Image.FORMAT_RGBAF:
			return "RGBAF"
		Image.FORMAT_RH:
			return "RH"
		Image.FORMAT_RGH:
			return "RGH"
		Image.FORMAT_RGBH:
			return "RGBH"
		Image.FORMAT_RGBAH:
			return "RGBAH"
		Image.FORMAT_RGBE9995:
			return "RGBE9995"
		Image.FORMAT_DXT1:
			return "DXT1"
		Image.FORMAT_DXT3:
			return "DXT3"
		Image.FORMAT_DXT5:
			return "DXT5"
		Image.FORMAT_RGTC_R:
			return "RGTC_R"
		Image.FORMAT_RGTC_RG:
			return "RGTC_RG"
		Image.FORMAT_BPTC_RGBA:
			return "BPTC_RGBA"
		Image.FORMAT_BPTC_RGBF:
			return "BPTC_RGBF"
		Image.FORMAT_BPTC_RGBFU:
			return "BPTC_RGBFU"
		Image.FORMAT_ETC:
			return "ETC"
		Image.FORMAT_ETC2_R11:
			return "ETC2_R11"
		Image.FORMAT_ETC2_R11S:
			return "ETC2_R11S"
		Image.FORMAT_ETC2_RG11:
			return "ETC2_RG11"
		Image.FORMAT_ETC2_RG11S:
			return "ETC2_RG11S"
		Image.FORMAT_ETC2_RGB8:
			return "ETC2_RGB8"
		Image.FORMAT_ETC2_RGBA8:
			return "ETC2_RGBA8"
		Image.FORMAT_ETC2_RGB8A1:
			return "ETC2_RGB8A1"
		Image.FORMAT_ETC2_RA_AS_RG:
			return "ETC2_RA_AS_RG"
		Image.FORMAT_DXT5_RA_AS_RG:
			return "DXT5_RA_AS_RG"
		Image.FORMAT_ASTC_4x4:
			return "ASTC_4x4"
		Image.FORMAT_ASTC_8x8:
			return "ASTC_8x8"
		Image.FORMAT_ASTC_4x4_HDR:
			return "ASTC_4x4_HDR"
		Image.FORMAT_ASTC_8x8_HDR:
			return "ASTC_8x8_HDR"
		_:
			return str(format)
