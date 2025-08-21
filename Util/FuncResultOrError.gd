extends RefCounted
class_name FuncResultOrError

var result:Variant
var error:int = 0

static func createResult(_res:Variant) -> FuncResultOrError:
	var theResult := FuncResultOrError.new()
	theResult.error = 0
	theResult.result = _res
	return theResult

static func createError(_err:int, _res:Variant = null) -> FuncResultOrError:
	var theResult := FuncResultOrError.new()
	theResult.error = _err
	theResult.result = _res
	return theResult

func isError() -> bool:
	return error != 0
