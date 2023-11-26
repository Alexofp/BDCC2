extends Node

var trackingUIs = []

signal onAnyUIVisibleChanged(newVisible)
var savedAnyVisibible = false

func addUI(newUI:Node):
	if(trackingUIs.has(newUI)):
		return
	
	trackingUIs.append(newUI)
	var newCallable = Callable(self, "onUINodeTreeExited")
	newCallable.bind(newUI)
	# Handle tree_entered too maybe
	newUI.tree_exited.connect(newCallable)
	if((newUI is Control) || (newUI is CanvasLayer)):
		newUI.visibility_changed.connect(onSomeUINodeVisibilityChanged)
	
	checkAnyVisible()

func onUINodeTreeExited(uiNode:Node):
	trackingUIs.erase(uiNode)

func onSomeUINodeVisibilityChanged():
	checkAnyVisible()

func checkAnyVisible():
	if(hasAnyUIVisible() && !savedAnyVisibible):
		savedAnyVisibible = true
		emit_signal("onAnyUIVisibleChanged", savedAnyVisibible)
	elif(!hasAnyUIVisible() && savedAnyVisibible):
		savedAnyVisibible = false
		emit_signal("onAnyUIVisibleChanged", savedAnyVisibible)

func hasAnyUIVisible() -> bool:
	for uiNode in trackingUIs:
		if(uiNode.visible):
			return true
	return false
