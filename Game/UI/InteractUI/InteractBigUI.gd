extends Control

# [[name, indx, actionID, category], [..], ..]
var cachedActions:Array[Array]

var subCategory:Array[String]
var shouldBeVisible:bool = true

@onready var action_list: VBoxContainer = %ActionList

signal onAction(_indx:int, _actionID:String)

func _ready() -> void:
	shouldBeVisible = false
	visible = false
	modulate = Color.TRANSPARENT

func updateActionList():
	Util.delete_children(action_list)
	
	if(!subCategory.is_empty()):
		var backButton := Button.new()
		backButton.text = "[Back]"
		action_list.add_child(backButton)
		backButton.pressed.connect(onBackButtonPressed)

	# Adding category buttons
	var extraCategories:Array[String]
	var curCatAm:int = subCategory.size()
	for actionEntry in cachedActions:
		var theCat:Array = actionEntry[2]
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
		var theCatButton := Button.new()
		action_list.add_child(theCatButton)
		theCatButton.text = "["+theCatName+"]"
		#theCatButton.setCategoryName(theCatName)
		theCatButton.pressed.connect(onCategoryButtonPressed.bind(theCatName))

	var _i:int = 0
	for actionEntry in cachedActions:
		if(actionEntry[2] != subCategory):
			_i += 1
			continue
		
		if(true): # if button
			var newButton := Button.new()
			newButton.text = actionEntry[0]
			action_list.add_child(newButton)
			newButton.pressed.connect(onActionPressed.bind(actionEntry))
		
		_i += 1

func onActionPressed(_entry:Array):
	onAction.emit(_entry[1], _entry[3])
	
	#var theIndx:int = _entry[1]
	#var _theActionID:String = _entry[3]

	#updateActionsCache()
	#var theActions := getActions()
	var thePawn := GM.pcPawn
	if(!thePawn):
		return
	GI.askDoPawnInteractionAction(thePawn, _entry)
		
	#var theActions := thePawn.getPawnInteractor().actionsBigSync
	#if(theIndx >= 0 && theIndx < theActions.size()):
		#var anAction:Array = theActions[theIndx]
		#
		##print("DO QUICK ACTION!!!")
		#GI.askDoPawnInteractionAction(thePawn, anAction)
		#GI.askDoAction(getUser(), anAction)

func onBackButtonPressed():
	subCategory.pop_back()
	updateActionList()

func onCategoryButtonPressed(_catID:String):
	subCategory.append(_catID)
	updateActionList()

func setActions(_actions:Array[Array], _duplicate:bool = true):
	if(cachedActions == _actions):
		return
	cachedActions = _actions if !_duplicate else _actions.duplicate(true)
	updateActionList()
	if(cachedActions.is_empty()):
		fadeOut()
	else:
		fadeIn()

func _physics_process(_delta: float) -> void:
	var currentPawn := GM.pcPawn
	if(!currentPawn):
		setActions([])
		return
	var theInteractor := currentPawn.getPawnInteractor()
	setActions(theInteractor.actionsBigSync)
	
	if(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		action_list.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	else:
		action_list.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_INHERITED
	

var fadeTween:Tween
func fadeIn():
	if(shouldBeVisible):
		return
	shouldBeVisible = true
	visible = true

	if(fadeTween):
		fadeTween.kill()
	fadeTween = create_tween()
	fadeTween.tween_property(self, "modulate", Color.WHITE, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	
func fadeOut():
	if(!shouldBeVisible):
		return
	shouldBeVisible = false
	
	if(fadeTween):
		fadeTween.kill()
	fadeTween = create_tween()
	fadeTween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	fadeTween.tween_property(self, "visible", false, 0.0)
