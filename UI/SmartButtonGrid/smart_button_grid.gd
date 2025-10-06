extends VBoxContainer
class_name SmartButtonGrid

@export var buttonAmountInitial:int = 15
@export var gridColumnsInitial:int = 5

@onready var page_prev_button: Button = %PagePrevButton
@onready var button_grid_container: GridContainer = %ButtonGridContainer
@onready var page_next_button: Button = %PageNextButton

signal onButtonPressed(buttonEntry:SmartGridButtonEntry)

var page:int = 0
var currentCategory:Array[String] = []

var needsUpdate:bool = false

var buttons:Array[SmartGridButton] = []
var buttonEntries:Array[SmartGridButtonEntry] = []

var buttonScene := preload("res://UI/SmartButtonGrid/smart_grid_button.tscn")

@export var addTestButtons:bool = false

func _ready() -> void:
	button_grid_container.columns = gridColumnsInitial
	
	for buttonIndx in range(buttonAmountInitial):
		var theButton:SmartGridButton= buttonScene.instantiate()
		theButton.buttonIndex = buttonIndx
		button_grid_container.add_child(theButton)
		theButton.onPressedActually.connect(onGridButtonPressed.bind(theButton))
		buttons.append(theButton)
	
	if(addTestButtons):
		for _i in range(17):
			addButton(SmartGridButtonEntry.make("Button"+str(_i), "asd"))
		for _i in range(17):
			addButton(SmartGridButtonEntry.make("Button"+str(_i), "asd", [], ["asd", "meow"]))
	
	markDirty()

func onGridButtonPressed(_entry:SmartGridButtonEntry, _button:SmartGridButton):
	if(_entry.buttonType == SmartGridButtonEntry.BUTTON_ACTION):
		if(!buttonEntries.has(_entry)):
			assert(false, "Invalid button entry, something went very wrong")
			return
		onButtonPressed.emit(_entry)
	elif(_entry.buttonType == SmartGridButtonEntry.BUTTON_BACK):
		currentCategory.pop_back()
		markDirty()
	elif(_entry.buttonType == SmartGridButtonEntry.BUTTON_CATEGORY):
		currentCategory.append(_entry.actionID)
		markDirty()
	else:
		assert(false, "Unknown button type: "+str(_entry.buttonType))

func markDirty():
	if(needsUpdate):
		return
	needsUpdate = true
	updateButtons.call_deferred()

func updateButtons():
	var gridHigh:Array = []
	var theGrid := calcGridDictionary(gridHigh)
	while(!currentCategory.is_empty() && !gridHigh[1]): # Category trim
		gridHigh.clear()
		currentCategory.pop_back()
		theGrid = calcGridDictionary(gridHigh)
	var highestGridIndx:int = gridHigh[0] if gridHigh.size() > 0 else 0
	var buttonsAmount:int = buttons.size()
	
	#Page trim
	var theMaxPage:int = ceili(float(highestGridIndx+1)/float(buttonsAmount))-1
	if(page > theMaxPage):
		page = theMaxPage
	
	for button in buttons:
		var buttonIndxRaw := button.buttonIndex
		var buttonIndx:int = page*buttonsAmount + buttonIndxRaw
		
		if(!theGrid.has(buttonIndx)):
			button.setEmptyEntry()
			continue
		button.setEntry(theGrid[buttonIndx])
	
	page_prev_button.visible = (page > 0)
	page_next_button.visible = (highestGridIndx > (page+1)*buttonsAmount)
	
	needsUpdate = false

func calcMaxPage() -> int:
	var gridHigh:Array = []
	var _theGrid := calcGridDictionary(gridHigh)
	var highestGridIndx:int = gridHigh[0] if gridHigh.size() > 0 else 0
	var buttonsAmount:int = buttons.size()
	
	if(highestGridIndx < 0):
		return 0
	
	var pages:int = ceili(float(highestGridIndx+1)/float(buttonsAmount))-1
	return pages

func addButton(_entry:SmartGridButtonEntry):
	buttonEntries.append(_entry)
	markDirty()

func clearButtons(resetTheState:bool=true):
	buttonEntries.clear()
	if(resetTheState):
		page = 0
		currentCategory.clear()
	markDirty()

func resetState():
	page = 0
	currentCategory.clear()
	markDirty()

func _on_page_prev_button_pressed() -> void:
	page -= 1
	markDirty()

func _on_page_next_button_pressed() -> void:
	page += 1
	markDirty()

func getPage() -> int:
	return page

func trimPage():
	if(page < 0):
		page = 0
		markDirty()
		return
	var theMaxPage := calcMaxPage()
	if(page > theMaxPage):
		page = theMaxPage
		markDirty()

func setPage(_page:int, trimToMax:bool = false):
	if(trimToMax):
		var theMaxPage := calcMaxPage()
		if(_page > theMaxPage):
			_page = theMaxPage
	
	if(page == _page):
		return
	page = _page
	markDirty()

func calcGridDictionary(_out:Array=[]) -> Dictionary[int, SmartGridButtonEntry]:
	var result: Dictionary[int, SmartGridButtonEntry] = {}
	var highestIndx:int = -1
	var hasAnyActions:bool = false
	
	# Add all the buttons that have a fixed index first
	for entry in buttonEntries:
		if(entry.buttonIndx >= 0):
			if(entry.buttonCategory != currentCategory):
				continue
			
			result[entry.buttonIndx] = entry
			if(entry.buttonIndx > highestIndx):
				highestIndx = entry.buttonIndx
			hasAnyActions = true
	
	# Then fill the empty spots with the rest
	var checkSpot:int = 0
	while(result.has(checkSpot)):
		checkSpot += 1
	
	if(!currentCategory.is_empty()):
		var backButton := SmartGridButtonEntry.make("[Back]", "")
		backButton.buttonType = SmartGridButtonEntry.BUTTON_BACK
		result[checkSpot] = backButton
		checkSpot += 1
		hasAnyActions = true
		
	var theCats := getPossibleCategories()
	for categoryName in theCats:
		while(result.has(checkSpot)):
			checkSpot += 1
		var catButton := SmartGridButtonEntry.make("["+categoryName+"]", categoryName)
		catButton.buttonType = SmartGridButtonEntry.BUTTON_CATEGORY
		result[checkSpot] = catButton
		checkSpot += 1
		hasAnyActions = true
	
	for entry in buttonEntries:
		if(entry.buttonIndx >= 0):
			continue
		if(entry.buttonCategory != currentCategory):
			continue
		while(result.has(checkSpot)):
			checkSpot += 1
		result[checkSpot] = entry
		checkSpot += 1
		hasAnyActions = true
	
	if(checkSpot > highestIndx):
		highestIndx = checkSpot
	
	_out.append(highestIndx) #Scuffed way to get an extra return value
	_out.append(hasAnyActions)
	return result

func getPossibleCategoriesAt(_cat:Array[String]) -> Array[String]:
	var result:Array[String] = []
	
	var curCatSize:int = _cat.size()
	
	for entry in buttonEntries:
		if(curCatSize >= entry.buttonCategory.size()):
			continue
		var sameCat:bool = true
		for _i in range(curCatSize):
			if(_cat[_i] != entry.buttonCategory[_i]):
				sameCat = false
				break
		if(!sameCat):
			continue
		if(!result.has(entry.buttonCategory[curCatSize])):
			result.append(entry.buttonCategory[curCatSize])
	
	return result
	
func getPossibleCategories() -> Array[String]:
	return getPossibleCategoriesAt(currentCategory)
