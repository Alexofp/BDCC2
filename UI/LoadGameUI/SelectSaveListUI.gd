extends VBoxContainer

const SELECT_SAVE_ENTRY_UI = preload("res://UI/LoadGameUI/SelectSaveEntryUI.tscn")
var infos:Array[GameShortInfo]
var selected:GameShortInfo
var uiEntries:Array[Control]
#var infoToUIEntry:Dictionary[GameShortInfo, Control]

signal onEntrySelected(_game:GameShortInfo)

func _ready() -> void:
	populateList()
	pickFirst()

func populateList():
	Util.delete_children(self)
	selected = null
	#infos.clear()
	
	uiEntries.clear()
	infos = SAVE.getAllSaveInfos()
	for theInfo:GameShortInfo in infos:
		var newEntry:Control = SELECT_SAVE_ENTRY_UI.instantiate()
		add_child(newEntry)
		newEntry.setInfo(theInfo)
		newEntry.onPressed.connect(onSaveEntryUIPressed)
		uiEntries.append(newEntry)
	
	#if(!infos.is_empty()):
	#	selected = infos[0]
	
	updateList()
	#updateSelectedEntry()

func updateList():
	for theEntry:Control in uiEntries:
		theEntry.setVisiblySelected(theEntry.info == selected)

#func updateSelectedEntry():
#	pass

func pickFirst():
	if(infos.is_empty()):
		onSaveEntryUIPressed(null)
		return
	onSaveEntryUIPressed(infos[0])

func onSaveEntryUIPressed(_info:GameShortInfo):
	selected = _info
	updateList()
	#updateSelectedEntry()
	onEntrySelected.emit(_info)
