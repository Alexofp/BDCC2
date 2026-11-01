extends OptionButton
class_name CharacterTypeComboBox

@export var playerChoice:bool = false

var choiceIDs:Array[int]
var selectedType:int = -1

signal onCharTypeSelected(_type:int)

func _ready() -> void:
	updateList()
	setSelectedType(CharacterType.InmateGeneral, true)
	item_selected.connect(internal_onItemSelected)

func setPlayerChoice(_c:bool):
	playerChoice = _c
	updateList()

func updateList():
	choiceIDs.clear()
	clear()
	var _i:int = 0
	for theID:int in GlobalRegistry.characterTypes:
		var theType:CharacterTypeBase = GlobalRegistry.characterTypes[theID]
		
		if(!theType.canBePicked()):
			continue
		if(playerChoice && !theType.canBePickedAsPlayer()):
			continue
		add_item(theType.getName())
		choiceIDs.append(theID)
		if(theID == selectedType):
			select(_i)
		_i += 1

func setSelectedType(_type:int, _callSignal:bool = true):
	selectedType = _type
	var _i:int = 0
	for theID:int in choiceIDs:
		if(theID == _type):
			select(_i)
			break
		_i += 1
	
	if(_callSignal):
		onCharTypeSelected.emit(_type)

func internal_onItemSelected(_index:int):
	if(_index < 0 || _index >= choiceIDs.size()):
		return
	selectedType = choiceIDs[_index]
	onCharTypeSelected.emit(selectedType)
