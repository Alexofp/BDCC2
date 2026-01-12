extends Control

@onready var category_list: ItemList = %CategoryList
@onready var action_list: VBoxContainer = %ActionList

signal onClose

var pawn:CharacterPawn

func clearMenu():
	pass

func updateMenu():
	if(!pawn):
		clearMenu()
		return
	var _pawnInteractor:PawnInteractor = pawn.getPawnInteractor()
	
	category_list.clear()
	for cachedCategory in _pawnInteractor.cachedCategories:
		category_list.add_item(cachedCategory.categoryName)
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
	
	var theContext := pawn.pawnActionContext
	
	var _i:int = 0
	for interactEntry in selectedCategory.interactEntries:
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
	updateMenu()
	pass

#TODO: MAKE THIS WORK IN MULTIPLAYER
func setTarget(_node:Node3D) -> bool:
	if(!pawn):
		return false
	var _pawnInteractor := pawn.getPawnInteractor()
	var cachedCategories := _pawnInteractor.cachedCategories
	
	var _catAm:int = cachedCategories.size()
	for _i in _catAm:
		var theCategory := cachedCategories[_i]
		
		if(theCategory.target == _node):
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
	updateInteractEntriesList()
