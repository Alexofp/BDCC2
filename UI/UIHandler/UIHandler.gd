extends RefCounted
class_name UIHandler

static var UIs:Array = []
static var mouseCaptures:Array = []

static func addUI(theUI:Control):
	if(theUI == null || !is_instance_valid(theUI)):
		return
	if(UIs.has(theUI)):
		return
	UIs.append(theUI)
	theUI.tree_exiting.connect(removeUI.bind(theUI))

static func removeUI(theUI:Control):
	if(UIs.has(theUI)):
		UIs.erase(theUI)

static func hasAnyUIVisible() -> bool:
	var UIAmount:int = UIs.size()
	for _i in range(UIAmount):
		var theUI:Control = UIs[UIAmount - _i - 1]
		if(theUI == null || !is_instance_valid(theUI)):
			UIs.remove_at(UIAmount - _i - 1)
			continue
		
		if(theUI.is_visible_in_tree()):
			return true
	return false

static func addMouseCapturer(theNode:Node):
	if(theNode == null || !is_instance_valid(theNode)):
		return
	if(mouseCaptures.has(theNode)):
		return
	if(!theNode.has_method("shouldCaptureMouse")):
		assert(false, "No shouldCaptureMouse method found")
		return
	mouseCaptures.append(theNode)
	theNode.tree_exiting.connect(removeMouseCapturer.bind(theNode))

static func removeMouseCapturer(theNode:Node):
	if(mouseCaptures.has(theNode)):
		mouseCaptures.erase(theNode)

static func shouldMouseBeCaptured() -> bool:
	for node in mouseCaptures:
		if(node.shouldCaptureMouse()):
			return true
	return false
