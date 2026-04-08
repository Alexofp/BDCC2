@tool
class_name VersionBumperDock
extends VBoxContainer

var plugin: EditorPlugin

@onready var version_label: Label = $VersionLabel
@onready var major_button: Button = $Buttons/MajorButton
@onready var minor_button: Button = $Buttons/MinorButton
@onready var patch_button: Button = $Buttons/PatchButton

func _ready() -> void:
	major_button.pressed.connect(_on_major_pressed)
	minor_button.pressed.connect(_on_minor_pressed)
	patch_button.pressed.connect(_on_patch_pressed)

func update_version(major: String, minor: String, patch: String) -> void:
	version_label.text = "Current Version: " + major + "." + minor + "." + patch

func _on_major_pressed() -> void:
	if plugin:
		plugin.increment(0)

func _on_minor_pressed() -> void:
	if plugin:
		plugin.increment(1)

func _on_patch_pressed() -> void:
	if plugin:
		plugin.increment(2)
