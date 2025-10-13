extends RefCounted
class_name SGTPResult #Simple game text parser result

var text:String
var error:String

static func make(_text:String) -> SGTPResult:
	var theResult:SGTPResult = SGTPResult.new()
	theResult.text = _text
	return theResult

static func makeError(_error:String) -> SGTPResult:
	var theResult:SGTPResult = SGTPResult.new()
	theResult.error = _error
	return theResult
