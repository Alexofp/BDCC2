extends RefCounted
class_name UIHandler

static var UIs:Array = []

static func addUI(theUI:Control):
	if(theUI == null || !is_instance_valid(theUI)):
		return
	if(UIs.has(theUI)):
		return
	UIs.append(theUI)

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
