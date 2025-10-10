extends Node

const CLOSE_QUEUE_FREE = 0
const CLOSE_HIDE = 1
const CLOSE_TRYCLOSEMENU_FUNC = 2
const CLOSE_BLOCK = 3

const META_CLOSE_NAME = "UIHandelrClose"

var UIs:Array[Control] = []
var mouseCaptures:Array[Node] = []
var windows:Array[Window] = []

var uiVisible:bool = false
var gameplayInputBlocked:bool = false
var menuInputBlocked:bool = false

#func _ready() -> void:
#	get_viewport().gui_focus_changed.connect(onGuiFocusChanged)

func addUI(theUI:Control, tryCloseLogic:int = CLOSE_QUEUE_FREE):
	if(theUI == null || !is_instance_valid(theUI)):
		return
	if(UIs.has(theUI)):
		return
	UIs.append(theUI)
	theUI.set_meta(META_CLOSE_NAME, tryCloseLogic)
	theUI.tree_exiting.connect(removeUI.bind(theUI))

func removeUI(theUI:Control):
	if(UIs.has(theUI)):
		UIs.erase(theUI)

func hasAnyUIVisible() -> bool:
	if(Console.is_visible()):
		return true
	return uiVisible

func addMouseCapturer(theNode:Node):
	if(theNode == null || !is_instance_valid(theNode)):
		return
	if(mouseCaptures.has(theNode)):
		return
	if(!theNode.has_method("shouldCaptureMouse")):
		assert(false, "No shouldCaptureMouse method found")
		return
	mouseCaptures.append(theNode)
	theNode.tree_exiting.connect(removeMouseCapturer.bind(theNode))

func removeMouseCapturer(theNode:Node):
	if(mouseCaptures.has(theNode)):
		mouseCaptures.erase(theNode)

func shouldMouseBeCaptured() -> bool:
	if(Console.is_visible()):
		return false
	
	for node in mouseCaptures:
		if(node.shouldCaptureMouse()):
			return true
	return false

func isGameplayInputBlocked() -> bool:
	if(Console.is_visible()):
		return true
	return gameplayInputBlocked

func isMenuInputBlocked() -> bool:
	var theViewport := get_viewport()
	if(theViewport):
		var theControl := theViewport.gui_get_focus_owner()
		if(theControl):
			if((theControl is LineEdit) && theControl.is_editing()):
				return true
	
	for window in windows:
		if(is_instance_valid(window) && window.is_inside_tree()):
			var windowViewport := window.get_viewport()
			if(windowViewport):
				var theControl := windowViewport.gui_get_focus_owner()
				if(theControl):
					if((theControl is LineEdit) && theControl.is_editing()):
						return true
	
	return menuInputBlocked

func _process(_delta: float) -> void:
	uiVisible = false
	gameplayInputBlocked = false
	menuInputBlocked = false
	
	var UIAmount:int = UIs.size()
	for _i in range(UIAmount):
		var theUI:Control = UIs[UIAmount - _i - 1]
		if(theUI == null || !is_instance_valid(theUI)):
			UIs.remove_at(UIAmount - _i - 1)
			continue
		
		if(internal_isUIVisible(theUI)):
			uiVisible = true
			
		if(theUI.has_method("isGameplayInputBlocked")):
			if(theUI.isGameplayInputBlocked()):
				gameplayInputBlocked = true
		elif(theUI.is_visible_in_tree()):
			gameplayInputBlocked = true
			
		if(theUI.has_method("isMenuInputBlocked")):
			if(theUI.isMenuInputBlocked()):
				menuInputBlocked = true

	if(shouldMouseBeCaptured()):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func internal_isUIVisible(theUI:Control) -> bool:
	if(theUI.has_method("isUIVisible")):
		if(theUI.isUIVisible()):
			return true
	elif(theUI.is_visible_in_tree()):
		return true
	return false

func tryCloseMenu():
	for theUI in UIs:
		if(internal_isUIVisible(theUI)):
			var theLogic:int = theUI.get_meta(META_CLOSE_NAME, CLOSE_QUEUE_FREE)
			
			if(theLogic == CLOSE_TRYCLOSEMENU_FUNC):
				if(theUI.has_method("tryCloseMenu")):
					if(theUI.tryCloseMenu()):
						return true
				else:
					assert(false, "MISSING tryCloseMenu() func")
			elif(theLogic == CLOSE_HIDE):
				theUI.visible = false
				return true
			elif(theLogic == CLOSE_QUEUE_FREE):
				theUI.queue_free()
				return true
			else:
				return true
			
	return false

func releaseUIFocus():
	if(get_viewport().gui_get_focus_owner()):
		get_viewport().gui_get_focus_owner().release_focus()

func addWindow(theWindow:Window):
	windows.append(theWindow)
	#theWindow.tree_exiting.connect(removeWindow.bind(theWindow))

func removeWindow(theWindow:Window):
	windows.erase(theWindow)
