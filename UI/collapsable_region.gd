extends PanelContainer

@onready var collapse_label: Label = %CollapseLabel
@onready var name_label: Label = %NameLabel
@onready var inside_container: VBoxContainer = %InsideContainer

@export var startsOpened:bool = false
@export var startName:String = "Collapsable region"

signal onOpenToggle(newOpen)

func _ready() -> void:
	setOpened(startsOpened)
	setName(startName)

func setName(newName:String):
	name_label.text = newName

func setOpened(newOpen:bool):
	inside_container.visible = newOpen
	collapse_label.text = "v " if newOpen else "> "
	onOpenToggle.emit(newOpen)

func toggleOpen():
	setOpened(!inside_container.visible)

func _on_toggle_button_pressed() -> void:
	toggleOpen()

func addNodeInside(node:Node):
	inside_container.add_child(node)

func clearInside():
	Util.delete_children(inside_container)
