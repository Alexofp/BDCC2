extends Object
class_name ObeyTask

const Nothing := 0
const Follow := 1 # Follow the dom
const Look := 2 # Stand still and look at dom
const Stand := 3 # Just stand still

static func getName(_task:int) -> String:
	if(_task == Nothing):
		return "Nothing"
	if(_task == Follow):
		return "Follow"
	if(_task == Look):
		return "Look"
	if(_task == Stand):
		return "Stand"
	
	return "Unknown"
