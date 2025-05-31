extends Object
class_name FaceValue

# NEVER TAKE ANYTHING AT FACE VALUE

enum {
	EyesClosed,
	EyesSexy,
	
	BrowsShy,
	BrowsAngry,
	
	MouthOpen,
	MouthPanting,
	MouthBlep,
	MouthSmile,
	MouthSad,
	MouthSnarl,
	
	LookDir,
	LookCross,
}

static func getAll() -> Array:
	return [
		EyesClosed,
		EyesSexy,
		
		BrowsShy,
		BrowsAngry,
		
		MouthOpen,
		MouthPanting,
		MouthBlep,
		MouthSmile,
		MouthSad,
		MouthSnarl,
		
		LookDir,
		LookCross,
	]

static func getAllTexts() -> Array:
	return [
		"EyesClosed",
		"EyesSexy",
		
		"BrowsShy",
		"BrowsAngry",
		
		"MouthOpen",
		"MouthPanting",
		"MouthBlep",
		"MouthSmile",
		"MouthSad",
		"MouthSnarl",
		
		"LookDir",
		"LookCross",
	]

const FACE_VALUE_FLOAT = 0
const FACE_VALUE_VEC2 = 1

static func getType(_faceVal:int) -> int:
	if(_faceVal == LookDir):
		return FACE_VALUE_VEC2
	return FACE_VALUE_FLOAT

static func getName(_faceVal:int) -> String:
	var theTexts:Array = getAllTexts()
	
	if(_faceVal < 0 || _faceVal >= theTexts.size()):
		return "ERROR"
	return theTexts[_faceVal]
