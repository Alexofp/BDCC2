extends PanelContainer

@onready var text_label: Label = %TextLabel
const SAVE_SELECTED = preload("res://UI/LoadGameUI/SaveSelected.tres")
const SAVE_UNSELECTED = preload("res://UI/LoadGameUI/SaveUnselected.tres")

var info:GameShortInfo
var selected:bool = false

signal onPressed(_info:GameShortInfo)

func _ready() -> void:
	setVisiblySelected(false)

func setVisiblySelected(_sel:bool):
	add_theme_stylebox_override("panel", SAVE_SELECTED if _sel else SAVE_UNSELECTED)
	selected = _sel

func setInfo(_game:GameShortInfo):
	info = _game
	updateInfo()

func updateInfo():
	var theLines:Array[String]
	if(info.corrupted):
		theLines.append(info.prisonName+" (!CORRUPTED!)")
		theLines.append(info.savePath.get_file())
		text_label.text = Util.join(theLines, "\n")
		return
	theLines.append(info.prisonName+" ("+info.getGameModeName()+")")
	theLines.append(info.playerName+" (Time played: "+str(Util.getTimeStringShort(info.timePlayed))+")")
	
	text_label.text = Util.join(theLines, "\n")

func _on_presser_pressed() -> void:
	onPressed.emit(info)
