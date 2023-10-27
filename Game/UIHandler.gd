extends Node

var trackingUIs = []

func addUI(newUI:Node):
	if(trackingUIs.has(newUI)):
		return
	
	trackingUIs.append(newUI)
	var newCallable = Callable(self, "onUINodeTreeExited")
	newCallable.bind(newUI)
	# Handle tree_entered too maybe
	newUI.tree_exited.connect(newCallable)

func onUINodeTreeExited(uiNode:Node):
	trackingUIs.erase(uiNode)

func hasAnyUIVisible() -> bool:
	for uiNode in trackingUIs:
		if(uiNode.visible):
			return true
	return false
