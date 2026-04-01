extends RefCounted
class_name ReactionSystemRunner

var lexer := ReactionSystemLexer.new()
var parser := ReactionSystemParser.new()
var errors:Array[String]

var targetObject

class ExpressionResult:
	var value:Variant
	var hadErrors:bool = false
	var errors:Array[String]

func runExpression(_str:String) -> ExpressionResult:
	internal_prepare()
	var result := ExpressionResult.new()

	var theLexerResult := lexer.parse(_str)
	if(theLexerResult.hadErrors):
		result.hadErrors = true
		return result
	
	var theExpression := parser.parseStandaloneExpression(theLexerResult)
	if(!theExpression):
		result.hadErrors = true
		return result
	
	result.value = execute(theExpression)
	result.hadErrors = hadErrors()
	if(result.hadErrors):
		result.errors = errors.duplicate()
	return result

func execute(_expr:ReactionExpression) -> Variant:
	if(!_expr):
		pushError(_expr, "Null expression found")
		assert(false, "Null expression found")
		return null
	
	if(_expr is ReactionExpression.Literal):
		return _expr.value
	if(_expr is ReactionExpression.Grouping):
		var theRes:Variant = execute(_expr.expression)
		if(hadErrors()):
			return null
		return theRes
	
	if(_expr is ReactionExpression.Variable):
		var theRes := getVariable(_expr.name)
		if(theRes.hadError):
			pushError(_expr, theRes.error)
			return null
		var someVal:Variant = theRes.value
		if(someVal == null):
			pushError(_expr, "Received null")
			return null
		return someVal

	if(_expr is ReactionExpression.Property):
		var theTarget:Variant = execute(_expr.left)
		if(hadErrors()):
			return null
		var theRes := getPropertyValueOf(theTarget, _expr.property)
		if(theRes.hadError):
			pushError(_expr, theRes.error)
			return null
		var someVal:Variant = theRes.value
		if(someVal == null):
			pushError(_expr, "Received null")
			return null
		return someVal

	if(_expr is ReactionExpression.CallDirect):
		var theArgs:Array = []
		for theArgExpr in _expr.arguments:
			var newArgVal:Variant = execute(theArgExpr)
			if(hadErrors()):
				return null
			theArgs.append(newArgVal)
		
		var theRes := doFunctionCall(_expr.functionName, theArgs)
		if(theRes.hadError):
			pushError(_expr, theRes.error)
			return null
		var someVal:Variant = theRes.value
		if(someVal == null):
			pushError(_expr, "Received null")
			return null
		return someVal

	if(_expr is ReactionExpression.CallOn):
		var theTarget:Variant = execute(_expr.left)
		if(hadErrors()):
			return null
		
		var theArgs:Array = []
		for theArgExpr in _expr.arguments:
			var newArgVal:Variant = execute(theArgExpr)
			if(hadErrors()):
				return null
			theArgs.append(newArgVal)
		
		var theRes := doFunctionCallOnObject(theTarget, _expr.functionName, theArgs)
		if(theRes.hadError):
			pushError(_expr, theRes.error)
			return null
		var someVal:Variant = theRes.value
		if(someVal == null):
			pushError(_expr, "Received null")
			return null
		return someVal
	
	if(_expr is ReactionExpression.Unary):
		var rightValue:Variant = execute(_expr.right)
		if(hadErrors()):
			return null
		
		if(_expr.operator == ReactionExpression.OPERATOR.MINUS):
			if((rightValue is int) || (rightValue is float)):
				return -rightValue
			else:
				pushError(_expr, "Trying to make a non-number value negative: "+str(rightValue))
		elif(_expr.operator == ReactionExpression.OPERATOR.BANG):
			return !rightValue
		
		pushError(_expr, "Unknown unary operand")
		return null
	
	if(_expr is ReactionExpression.Binary):
		var leftValue:Variant = execute(_expr.left)
		if(hadErrors()):
			return null
		var rightValue:Variant = execute(_expr.right)
		if(hadErrors()):
			return null
		
		var theOp:int = _expr.operator
		if(theOp == ReactionExpression.OPERATOR.PLUS):
			return leftValue + rightValue
		elif(theOp == ReactionExpression.OPERATOR.MINUS):
			return leftValue - rightValue
		elif(theOp == ReactionExpression.OPERATOR.MULT):
			return leftValue * rightValue
		elif(theOp == ReactionExpression.OPERATOR.DIV):
			return leftValue / rightValue
		elif(theOp == ReactionExpression.OPERATOR.LESS):
			return leftValue < rightValue
		elif(theOp == ReactionExpression.OPERATOR.MORE):
			return leftValue > rightValue
		elif(theOp == ReactionExpression.OPERATOR.LESS_OR_EQUAL):
			return leftValue <= rightValue
		elif(theOp == ReactionExpression.OPERATOR.MORE_OR_EQUAL):
			return leftValue >= rightValue
		elif(theOp == ReactionExpression.OPERATOR.EQUAL):
			return leftValue == rightValue
		elif(theOp == ReactionExpression.OPERATOR.NOT_EQUAL):
			return leftValue != rightValue
		elif(theOp == ReactionExpression.OPERATOR.AND):
			return leftValue && rightValue
		elif(theOp == ReactionExpression.OPERATOR.OR):
			return leftValue || rightValue
		pushError(_expr, "Unknown binary operand")
		return null
	if(_expr is ReactionExpression.Ternary):
		var conditionResult:Variant = execute(_expr.condition)
		if(hadErrors()):
			return null
		if(conditionResult):
			var theVal:Variant = execute(_expr.trueExpr)
			if(hadErrors()):
				return null
			return theVal
		else:
			var theVal:Variant = execute(_expr.falseExpr)
			if(hadErrors()):
				return null
			return theVal
	
	pushError(_expr, "Unhandled expression")
	return null

class ResultOrError:
	var value:Variant
	var error:String
	var hadError:bool = false
	
	static func createError(_text:String) -> ResultOrError:
		var newRes := ResultOrError.new()
		newRes.hadError = true
		newRes.error = _text
		return newRes
	
	static func create(_val:Variant) -> ResultOrError:
		var newRes := ResultOrError.new()
		newRes.value = _val
		return newRes

enum ArgumentType {
	Bool,
	Int,
	Float,
	Number,
	Pawn,
	String,
	Any,
}
const ArgumentTypeString:Array[String] = ["Bool", "Int", "Float", "Number", "Pawn", "String", "Any"]
static func getArgumentTypeString(_argType:int) -> String:
	if(_argType < 0 || _argType >= ArgumentTypeString.size()):
		return "UNKNOWN"
	return ArgumentTypeString[_argType]

func checkArguments(_required:Array[int], _args:Array) -> ResultOrError:
	if(_required.size() != _args.size()):
		return ResultOrError.createError("Wrong amount of arguments. Expected: "+str(_required.size())+", Got: "+str(_args.size()))
	
	var argAm:int = _args.size()
	for _i in argAm:
		var _reqType:int = _required[_i]
		var _reqTypeString:String = getArgumentTypeString(_reqType)
		var _gotValue:Variant = _args[_i]
		
		if(_reqType == ArgumentType.Any):
			continue
		if(_reqType == ArgumentType.Bool):
			if(_gotValue is bool):
				continue
		if(_reqType == ArgumentType.Int):
			if(_gotValue is int):
				continue
		if(_reqType == ArgumentType.Float):
			if(_gotValue is float):
				continue
		if(_reqType == ArgumentType.Number):
			if(_gotValue is float):
				continue
			if(_gotValue is int):
				continue
		if(_reqType == ArgumentType.String):
			if(_gotValue is String):
				continue
		if(_reqType == ArgumentType.Pawn):
			if(_gotValue is CharacterPawn):
				continue
		
		return ResultOrError.createError("Bad argument at pos "+str(_i+1)+", got: "+str(_gotValue)+", expected: "+_reqTypeString)
	
	return null

func getVariable(_property:String) -> ResultOrError:
	if(targetObject):
		return targetObject.getVariable(self, _property)
	#if(_property == "meow"):
	#	return ResultOrError.create(123)
	return ResultOrError.createError("Undefined property "+_property)

func getPropertyValueOf(_target:Variant, _property:String) -> ResultOrError:
	if(targetObject):
		return targetObject.getPropertyValueOf(self, _target, _property)
	return ResultOrError.createError("Undefined property "+str(_target)+"."+_property)

func doFunctionCall(_method:String, _args:Array) -> ResultOrError:
	if(targetObject):
		return targetObject.doFunctionCall(self, _method, _args)
	return ResultOrError.createError("Undefined function "+_method)

func doFunctionCallOnObject(_target:Variant, _method:String, _args:Array) -> ResultOrError:
	if(targetObject):
		return targetObject.doFunctionCallOnObject(self, _target, _method, _args)
	return ResultOrError.createError("Undefined function "+str(_target)+"."+_method)

func internal_prepare():
	errors.clear()

func pushError(_expr:ReactionExpression, _str:String):
	if(!_expr):
		errors.append(_str)
		return
	var theLine := "Line "+str(_expr.line)+": "+_expr.getName()+": "+_str
	errors.append(theLine)
	Log.Printerr(theLine)

func hadErrors() -> bool:
	return !errors.is_empty()

func createError(_text:String) -> ResultOrError:
	return ResultOrError.createError(_text)

func createValue(_value:Variant) -> ResultOrError:
	return ResultOrError.create(_value)
