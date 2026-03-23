extends RefCounted
class_name ReactionExpression

enum OPERATOR {
	PLUS,
	MINUS,
	MULT,
	DIV,
	BANG,
	MORE,
	LESS,
	MORE_OR_EQUAL,
	LESS_OR_EQUAL,
	EQUAL,
	NOT_EQUAL,
	AND,
	OR,
}

const TOKEN_MAP:Dictionary[int, int] = {
	ReactionSystemLexer.TOKEN.MATH_PLUS: OPERATOR.PLUS,
	ReactionSystemLexer.TOKEN.MATH_MINUS: OPERATOR.MINUS,
	ReactionSystemLexer.TOKEN.MATH_MULT: OPERATOR.MULT,
	ReactionSystemLexer.TOKEN.MATH_DIV: OPERATOR.DIV,
	ReactionSystemLexer.TOKEN.BANG: OPERATOR.BANG,
	ReactionSystemLexer.TOKEN.MATH_MORE: OPERATOR.MORE,
	ReactionSystemLexer.TOKEN.MATH_LESS: OPERATOR.LESS,
	ReactionSystemLexer.TOKEN.MATH_MOREOREQUAL: OPERATOR.MORE_OR_EQUAL,
	ReactionSystemLexer.TOKEN.MATH_LESSOREQUAL: OPERATOR.LESS_OR_EQUAL,
	ReactionSystemLexer.TOKEN.MATH_EQUALEQUAL: OPERATOR.EQUAL,
	ReactionSystemLexer.TOKEN.MATH_BANGEQUAL: OPERATOR.NOT_EQUAL,
	ReactionSystemLexer.TOKEN.AND: OPERATOR.AND,
	ReactionSystemLexer.TOKEN.OR: OPERATOR.OR,
}
static func tokenToOperator(_token:int) -> int:
	return TOKEN_MAP.get(_token, -1)

var line:int = 0

func setLine(_l:int) -> ReactionExpression:
	line = _l
	return self
func getName() -> String:
	return "CHANGE ME"

class Ternary extends ReactionExpression:
	var condition:ReactionExpression
	var trueExpr:ReactionExpression
	var falseExpr:ReactionExpression
	static func create(_cond:ReactionExpression, _trueExpr:ReactionExpression, _falseExpr:ReactionExpression) -> Ternary:
		var newExpr := Ternary.new()
		newExpr.condition = _cond
		newExpr.trueExpr = _trueExpr
		newExpr.falseExpr = _falseExpr
		newExpr.line = _cond.line
		return newExpr
	func getName() -> String:
		return "Ternary"
	const ExprName := "Ternary"

class Call extends ReactionExpression:
	var left:ReactionExpression
	var arguments:Array[ReactionExpression]
	static func create(_left:ReactionExpression, _args:Array[ReactionExpression]) -> Call:
		var newExpr := Call.new()
		newExpr.left = _left
		newExpr.arguments = _args
		newExpr.line = _left.line
		return newExpr
	func getName() -> String:
		return "Call"
	const ExprName := "Call"

class CallDirect extends ReactionExpression:
	var functionName:String
	var arguments:Array[ReactionExpression]
	static func create(_func:String, _args:Array[ReactionExpression], _line:int = -1) -> CallDirect:
		var newExpr := CallDirect.new()
		newExpr.functionName = _func
		newExpr.arguments = _args
		newExpr.line = _line
		return newExpr
	func getName() -> String:
		return "CallDirect"
	const ExprName := "CallDirect"

class CallOn extends ReactionExpression:
	var left:ReactionExpression
	var functionName:String
	var arguments:Array[ReactionExpression]
	static func create(_left:ReactionExpression, _func:String, _args:Array[ReactionExpression]) -> CallOn:
		var newExpr := CallOn.new()
		newExpr.left = _left
		newExpr.functionName = _func
		newExpr.arguments = _args
		newExpr.line = _left.line
		return newExpr
	func getName() -> String:
		return "CallOn"
	const ExprName := "CallOn"

class CallDirectOn extends ReactionExpression:
	var target:String
	var functionName:String
	var arguments:Array[ReactionExpression]
	static func create(_target:String, _func:String, _args:Array[ReactionExpression], _line:int = -1) -> CallDirectOn:
		var newExpr := CallDirectOn.new()
		newExpr.target = _target
		newExpr.functionName = _func
		newExpr.arguments = _args
		newExpr.line = _line
		return newExpr
	func getName() -> String:
		return "CallDirectOn"
	const ExprName := "CallDirectOn"

class PropertyDirect extends ReactionExpression:
	var target:String
	var property:String
	static func create(_target:String, _prop:String, _line:int = -1) -> PropertyDirect:
		var newExpr := PropertyDirect.new()
		newExpr.target = _target
		newExpr.property = _prop
		newExpr.line = _line
		return newExpr
	func getName() -> String:
		return "PropertyDirect"
	const ExprName := "PropertyDirect"

class Property extends ReactionExpression:
	var left:ReactionExpression
	var property:String
	static func create(_left:ReactionExpression, _prop:String) -> Property:
		var newExpr := Property.new()
		newExpr.left = _left
		newExpr.property = _prop
		newExpr.line = _left.line
		return newExpr
	func getName() -> String:
		return "Property"
	const ExprName := "Property"

class Variable extends ReactionExpression:
	var name:String
	static func create(_name:String, _line:int = -1) -> Variable:
		var newExpr := Variable.new()
		newExpr.name = _name
		newExpr.line = _line
		return newExpr
	func getName() -> String:
		return "Variable"
	const ExprName := "Variable"

class Unary extends ReactionExpression:
	var operator:int
	var right:ReactionExpression
	static func create(_op:int, _right:ReactionExpression) -> Unary:
		var newExpr := Unary.new()
		newExpr.operator = _op
		newExpr.right = _right
		newExpr.line = _right.line
		return newExpr
	func getName() -> String:
		return "Unary"
	const ExprName := "Unary"

class Logical extends ReactionExpression:
	var left: ReactionExpression
	var operator:int
	var right:ReactionExpression
	static func create(_left:ReactionExpression, _op:int, _right:ReactionExpression) -> Logical:
		var newExpr := Logical.new()
		newExpr.left = _left
		newExpr.operator = _op
		newExpr.right = _right
		newExpr.line = _left.line
		return newExpr
	func getName() -> String:
		return "Logical"
	const ExprName := "Logical"

class Literal extends ReactionExpression:
	var value:Variant
	static func create(_value:Variant, _lineNumber:int=-1) -> Literal:
		var newExpr := Literal.new()
		newExpr.value = _value
		newExpr.line = _lineNumber
		return newExpr
	func getName() -> String:
		return "Literal"
	const ExprName := "Literal"

class Grouping extends ReactionExpression:
	var expression:ReactionExpression
	static func create(_expression:ReactionExpression) -> Grouping:
		var newExpr := Grouping.new()
		newExpr.expression = _expression
		newExpr.line = _expression.line
		return newExpr
	func getName() -> String:
		return "Grouping"
	const ExprName := "Grouping"

class Binary extends ReactionExpression:
	var left: ReactionExpression
	var operator:int
	var right:ReactionExpression
	static func create(_left:ReactionExpression, _op:int, _right:ReactionExpression) -> Binary:
		var newExpr := Binary.new()
		newExpr.left = _left
		newExpr.operator = _op
		newExpr.right = _right
		newExpr.line = _left.line
		return newExpr
	func getName() -> String:
		return "Binary"
	const ExprName := "Binary"
