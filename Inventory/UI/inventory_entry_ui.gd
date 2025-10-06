extends PanelContainer

var itemUID:int = -1

@onready var name_label: Label = %NameLabel
@onready var post_fix_label: Label = %PostFixLabel

const PANEL_SELECTED = preload("res://Inventory/UI/PanelSelected.tres")
const PANEL_NOT_SELECTED = preload("res://Inventory/UI/PanelNotSelected.tres")

signal onSelected(itemUID:int)

func setItem(_item:ItemBase):
	name_label.text = _item.getName()
	itemUID = _item.uniqueID

func getItemUID() -> int:
	return itemUID

func setSelected(_sel:bool):
	if(_sel):
		add_theme_stylebox_override("panel", PANEL_SELECTED)
	else:
		add_theme_stylebox_override("panel", PANEL_NOT_SELECTED)

func setPostFix(_text:String):
	post_fix_label.text = _text

func _on_presser_pressed() -> void:
	onSelected.emit(itemUID)
