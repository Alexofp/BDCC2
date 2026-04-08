@tool
class_name VersionBumperPlugin
extends EditorPlugin

enum DisplayMode {EMBED_TOP, DOCK}

var current_mode: int = DisplayMode.DOCK
var dock_instance: Control
var top_bar_instance: Control
var menu: PopupMenu

func _enter_tree() -> void:
	if not ProjectSettings.has_setting("application/config/version"):
		ProjectSettings.set_setting("application/config/version", "0.0.0")

	if ProjectSettings.has_setting("version_bumper/display_mode"):
		current_mode = ProjectSettings.get_setting("version_bumper/display_mode")
	else:
		ProjectSettings.set_setting("version_bumper/display_mode", DisplayMode.EMBED_TOP)

	menu = PopupMenu.new()
	menu.add_radio_check_item("Embed Top", DisplayMode.EMBED_TOP)
	menu.add_radio_check_item("Dock", DisplayMode.DOCK)
	menu.set_item_checked(current_mode, true)
	menu.id_pressed.connect(_on_menu_id_pressed)

	add_tool_submenu_item("VersionBumper", menu)

	_apply_mode(current_mode)

func _exit_tree() -> void:
	remove_tool_menu_item("VersionBumper")
	if menu:
		menu.free()
	_remove_all_uis()

func increment(change_type: int) -> void:
	var current_version: String = "0.0.0"
	if ProjectSettings.has_setting("application/config/version"):
		current_version = str(ProjectSettings.get_setting("application/config/version")).strip_edges()

	if current_version.is_empty():
		current_version = "0.0.0"

	var parts: PackedStringArray = current_version.split(".")
	var major: int = parts[0].to_int() if parts.size() >= 1 and not parts[0].is_empty() else 0
	var minor: int = parts[1].to_int() if parts.size() >= 2 and not parts[1].is_empty() else 0
	var patch: int = parts[2].to_int() if parts.size() >= 3 and not parts[2].is_empty() else 0

	match change_type:
		0:
			major += 1
			minor = 0
			patch = 0
		1:
			minor += 1
			patch = 0
		2:
			patch += 1

	var ver_str: String = "%d.%d.%d" % [major, minor, patch]
	ProjectSettings.set_setting("application/config/version", ver_str)
	ProjectSettings.save()

	_update_ui()

func _on_menu_id_pressed(id: int) -> void:
	for i in range(menu.get_item_count()):
		menu.set_item_checked(i, false)
	menu.set_item_checked(id, true)

	ProjectSettings.set_setting("version_bumper/display_mode", id)
	ProjectSettings.save()

	_apply_mode(id)

func _remove_all_uis() -> void:
	if dock_instance:
		remove_control_from_docks(dock_instance)
		dock_instance.free()
		dock_instance = null
	if top_bar_instance:
		remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, top_bar_instance)
		top_bar_instance.free()
		top_bar_instance = null

func _apply_mode(mode: int) -> void:
	current_mode = mode
	_remove_all_uis()

	match mode:
		DisplayMode.DOCK:
			dock_instance = preload("res://addons/version_bumper/version_bumper_dock.tscn").instantiate()
			dock_instance.plugin = self
			add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, dock_instance)
			_update_ui()
		DisplayMode.EMBED_TOP:
			top_bar_instance = _create_minimal_ui()
			add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, top_bar_instance)
			_update_ui()

func _create_minimal_ui() -> HBoxContainer:
	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	# 1 pixel separation so the backgrounds don't bleed into one solid block
	hbox.add_theme_constant_override("separation", 1)

	var btn_major: Button = Button.new()
	var btn_minor: Button = Button.new()
	var btn_patch: Button = Button.new()

	# Create a custom stylebox to force minimal padding and add a background color
	var style_normal: StyleBoxFlat = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.3, 0.3, 0.3, 0.5) # Subtle transparent gray
	style_normal.content_margin_left = 4
	style_normal.content_margin_right = 4
	style_normal.content_margin_top = 2
	style_normal.content_margin_bottom = 2
	style_normal.corner_radius_top_left = 2
	style_normal.corner_radius_top_right = 2
	style_normal.corner_radius_bottom_left = 2
	style_normal.corner_radius_bottom_right = 2

	# Slightly brighter color for hovering/clicking
	var style_hover: StyleBoxFlat = style_normal.duplicate()
	style_hover.bg_color = Color(0.4, 0.4, 0.4, 0.8)

	for btn in [btn_major, btn_minor, btn_patch]:
		# Apply our strict styleboxes to all states to prevent default editor padding
		btn.add_theme_stylebox_override("normal", style_normal)
		btn.add_theme_stylebox_override("hover", style_hover)
		btn.add_theme_stylebox_override("pressed", style_hover)
		btn.add_theme_stylebox_override("focus", style_normal)

	btn_major.tooltip_text = "Major"
	btn_minor.tooltip_text = "Minor"
	btn_patch.tooltip_text = "Patch"

	btn_major.pressed.connect(increment.bind(0))
	btn_minor.pressed.connect(increment.bind(1))
	btn_patch.pressed.connect(increment.bind(2))

	hbox.add_child(btn_major)
	hbox.add_child(btn_minor)
	hbox.add_child(btn_patch)

	return hbox

func _update_ui() -> void:
	var current_version: String = "0.0.0"
	if ProjectSettings.has_setting("application/config/version"):
		current_version = str(ProjectSettings.get_setting("application/config/version")).strip_edges()

	if current_version.is_empty():
		current_version = "0.0.0"

	var parts: PackedStringArray = current_version.split(".")
	var major: String = parts[0] if parts.size() >= 1 and not parts[0].is_empty() else "0"
	var minor: String = parts[1] if parts.size() >= 2 and not parts[1].is_empty() else "0"
	var patch: String = parts[2] if parts.size() >= 3 and not parts[2].is_empty() else "0"

	if dock_instance:
		dock_instance.update_version(major, minor, patch)
	if top_bar_instance:
		# Indices are back to 0, 1, and 2 since we removed the dots
		top_bar_instance.get_child(0).text = major
		top_bar_instance.get_child(1).text = minor
		top_bar_instance.get_child(2).text = patch
