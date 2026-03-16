extends Control

@onready var category_list: ItemList = %CategoryList
@onready var action_list: VBoxContainer = %ActionList
const INTERACT_MENU_CATEGORY_BUTTON = preload("res://Game/Interactable/UI/InteractMenuCategoryButton.tscn")

signal onClose

var pawn:CharacterPawn
var target:Node

var subCategory:Array[String]

func clearMenu():
	category_list.clear()
	Util.delete_children(action_list)

func updateMenu():
	if(!pawn):
		clearMenu()
		return
	var _pawnInteractor:PawnInteractor = pawn.getPawnInteractor()
	
	category_list.clear()
	for cachedCategory in _pawnInteractor.cachedCategories:
		category_list.add_item(cachedCategory.categoryName)
	updateListSelectedTargetEntry()

func onBackButtonPressed():
	if(!subCategory.is_empty()):
		subCategory.pop_back()
	updateInteractEntriesList()

func onCategoryButtonPressed(_catID:String):
	subCategory.append(_catID)
	updateInteractEntriesList()

func updateInteractEntriesList():
	Util.delete_children(action_list)
	if(!pawn):
		return
	if(category_list.get_selected_items().is_empty()):
		return
	var _pawnInteractor:PawnInteractor = pawn.getPawnInteractor()
	var cachedCategories := _pawnInteractor.cachedCategories
		
	var selectedCategoryIndx:int = category_list.get_selected_items()[0]
	if(selectedCategoryIndx < 0 || selectedCategoryIndx >= cachedCategories.size()):
		return
	
	var selectedCategory := cachedCategories[selectedCategoryIndx]
	
	if(!subCategory.is_empty()):
		var theBackButton := INTERACT_MENU_CATEGORY_BUTTON.instantiate()
		action_list.add_child(theBackButton)
		theBackButton.setCategoryName("Back")
		theBackButton.onPressed.connect(onBackButtonPressed)
		
	var extraCategories:Array[String]
	var curCatAm:int = subCategory.size()
	for interactEntry in selectedCategory.interactEntries:
		var theCat := interactEntry.subCategory
		var theCatAm:int = theCat.size()
		
		if(curCatAm >= theCatAm):
			continue
		var beginsSame:bool = true
		for _i in curCatAm:
			if(subCategory[_i] != theCat[_i]):
				beginsSame = false
				break
		if(beginsSame):
			var newCatName:String = theCat[curCatAm]
			if(!extraCategories.has(newCatName)):
				extraCategories.append(newCatName)
	
	for theCatName in extraCategories:
		var theCatButton := INTERACT_MENU_CATEGORY_BUTTON.instantiate()
		action_list.add_child(theCatButton)
		theCatButton.setCategoryName(theCatName)
		theCatButton.onPressed.connect(onCategoryButtonPressed.bind(theCatName))
	
	var theContext := pawn.pawnActionContext
	
	var _i:int = 0
	for interactEntry in selectedCategory.interactEntries:
		if(interactEntry.subCategory != subCategory):
			_i += 1
			continue
		
		if(interactEntry is InteractEntryText):
			var newLabel := Label.new()
			newLabel.text = interactEntry.text
			action_list.add_child(newLabel)
		elif(interactEntry is InteractEntryDo):
			theContext.loadFromInteractEntryDo(interactEntry, selectedCategory.target)
			
			#var theAction:PawnActionBase = interactEntry.action
			
			var newButton := Button.new()
			newButton.text = interactEntry.cachedName#theAction.getVisibleName(theContext) if theAction else "MISSING:"+str(interactEntry.action)# interactEntry.actionName
			action_list.add_child(newButton)
			newButton.pressed.connect(onInteractEntryDoPressed.bind(interactEntry, selectedCategory, _i))
		else:
			Log.error("Unknown interact entry: "+str(interactEntry))
		_i += 1
		
	theContext.clearContext()
	
func onInteractEntryDoPressed(_entry:InteractEntryDo, _category:InteractCategory, _indx:int):
	if(!pawn):
		return
	#pawn.askDoInteractEntryDo(_entry, _category.target)
	GI.askDoInteractEntryDo(pawn, _entry, _category, _indx)
	tryCloseMenu()

func setPawn(_p:CharacterPawn):
	if(pawn):
		var oldInteractor:PawnInteractor = pawn.getPawnInteractor()
		oldInteractor.onCachedCategoriesUpdate.disconnect(onInteractorUpdate)
	pawn = _p
	if(pawn):
		var newInteractor:PawnInteractor = pawn.getPawnInteractor()
		newInteractor.askUpdateInteractor()
		newInteractor.onCachedCategoriesUpdate.connect(onInteractorUpdate)
	updateMenu()
	
func onInteractorUpdate():
	if(gonnaSelectBestTarget):
		selectBestTarget()
		gonnaSelectBestTarget = false
	
	updateMenu()
	pass

var gonnaSelectBestTarget:bool = false
func showBestTarget():
	if(Network.isClient()): # Probably gonna be very buggy
		gonnaSelectBestTarget = true
	else:
		selectBestTarget()
		updateMenu()

func selectBestTarget():
	if(!pawn):
		return
	var _pawnInteractor := pawn.getPawnInteractor()
	if(_pawnInteractor.cachedCategories.size() > 1):
		target = _pawnInteractor.cachedCategories[1].target
	elif(_pawnInteractor.cachedCategories.size() > 0):
		target = _pawnInteractor.cachedCategories[0].target
	else:
		target = null
	subCategory.clear()

func setTarget(_node:Node3D) -> bool:
	target = _node
	subCategory.clear()
	updateMenu()
	return true

func updateListSelectedTargetEntry():
	if(!pawn):
		return false
	var _pawnInteractor := pawn.getPawnInteractor()
	var cachedCategories := _pawnInteractor.cachedCategories
	
	var _catAm:int = cachedCategories.size()
	for _i in _catAm:
		var theCategory := cachedCategories[_i]
		
		if(theCategory.target == target):
			category_list.select(_i)
			updateInteractEntriesList()
			return true
	return false
	
func _on_close_button_pressed() -> void:
	onClose.emit()

func _enter_tree() -> void:
	UIHandler.addUI(self, UIHandler.CLOSE_TRYCLOSEMENU_FUNC)

func _exit_tree() -> void:
	UIHandler.removeUI(self)

func tryCloseMenu() -> bool:
	onClose.emit()
	return true

func _on_category_list_item_selected(_index: int) -> void:
	if(pawn):
		subCategory.clear()
		var _pawnInteractor:PawnInteractor = pawn.getPawnInteractor()
		var cachedCategories := _pawnInteractor.cachedCategories
			
		var selectedCategoryIndx:int = category_list.get_selected_items()[0]
		if(selectedCategoryIndx < 0 || selectedCategoryIndx >= cachedCategories.size()):
			return
		
		var selectedCategory := cachedCategories[selectedCategoryIndx]
		if(!selectedCategory.target || !is_instance_valid(selectedCategory.target)):
			target = null
			return
		target = selectedCategory.target
	
	updateInteractEntriesList()
