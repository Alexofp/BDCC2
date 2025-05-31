extends Object
class_name IntComArg

const TypeInt = 1
const TypeString = 2
const TypeArray = 3
const TypeFloat = 4
const TypeDict = 5
const TypeAny = 6

static func isValid(theType:int, theValue:Variant) -> bool:
	if(theType == TypeInt && theValue is int):
		return true
	if(theType == TypeString && theValue is String):
		return true
	if(theType == TypeArray && theValue is Array):
		return true
	if(theType == TypeFloat && theValue is float):
		return true
	if(theType == TypeDict && theValue is Dictionary):
		return true
	if(theType == TypeAny && (theValue==null || theValue is int || theValue is String || theValue is Array || theValue is float || theValue is Dictionary || theValue is Color || theValue is Vector2 || theValue is Vector3 || theValue is bool)):
		return true
	
	return false

static func getDebugName(theType:int) -> String:
	if(theType == TypeInt):
		return "Int"
	if(theType == TypeString):
		return "String"
	if(theType == TypeArray):
		return "Array"
	if(theType == TypeFloat):
		return "Float"
	if(theType == TypeDict):
		return "Dictionary"
	if(theType == TypeAny):
		return "Any"
	
	return "UNKNOWN:"+str(theType)

static func getDebugNameForList(theArgs:Array) -> String:
	var newResult:Array = []
	
	for theArgType in theArgs:
		newResult.append(getDebugName(theArgType))
	
	return str(newResult)
