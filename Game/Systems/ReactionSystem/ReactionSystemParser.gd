extends RefCounted
class_name ReactionSystemParser

const MAX_ERRORS := 10

class ParseResult:
	var defs:Dictionary[String, ReactionEntry]
	var fills:Dictionary[String, Array] # Array of Fills
	
	var hadErrors:bool = false
	var errors:Array[String]

var curI:int
var curResult:ParseResult
var curLen:int
var curLexerResult:ReactionSystemLexer.ParseResult
func parseLexerResult(_result:ReactionSystemLexer.ParseResult) -> ParseResult:
	curResult = ParseResult.new()
	curI = 0
	curLexerResult = _result
	curLen = curLexerResult.tokens.size()
	
	while(!isEOF()):
		var theT := curr()
		var theType := theT.type if theT else -1
		
		if(checkEOL()):
			continue
		if(checkEOF()):
			break
		
		if(theType == ReactionSystemLexer.TOKEN.DEF):
			var theDef := parseDefinition()
			if(theDef):
				curResult.defs[theDef.id] = theDef
			continue
		
		if(theType == ReactionSystemLexer.TOKEN.FILL):
			var theFill := parseFill()
			if(theFill):
				if(!curResult.fills.has(theFill.reactionID)):
					var Ar:Array[ReactionFill] = [theFill]
					curResult.fills[theFill.reactionID] = Ar
				else:
					curResult.fills[theFill.reactionID].append(theFill)
			continue
		
		handleUnexpectedToken()
	
	return curResult

func parseFill() -> ReactionFill:
	consume() # Consume the fill
	var result := ReactionFill.new()
	
	if(currType() != ReactionSystemLexer.TOKEN.WORD):
		pushError("Expected def ID")
		return null
		
	var theIDToken := consume()
	result.reactionID = str(theIDToken.value)
	
	if(currType() != ReactionSystemLexer.TOKEN.EOL && currType() != ReactionSystemLexer.TOKEN.EOF):
		pushError("Expected END OF LINE or END OF FILE")
		return null
	consume() # Consume the eol/eof
	
	# Finding properties
	while(!isEOF()):
		if(checkEOL()):
			continue
		if(checkEOF()):
			break
		if(currType() == ReactionSystemLexer.TOKEN.END):
			consume()
			break # The definition has ended
		if(didNewDefBegan()):
			break # The definition has ended, something else has started
		
		if(currType() == ReactionSystemLexer.TOKEN.LINES):
			var theLines := consume()
			result.lines.append_array(theLines.value)
			continue
		
		if(currType() == ReactionSystemLexer.TOKEN.WORD):
			var thePropertyToken := consume()
			var theProperty:String = thePropertyToken.value
			if(theProperty == "priority"):
				if(currType() == ReactionSystemLexer.TOKEN.INT):
					result.priority = consume().value
				else:
					pushError("Priority must be an integer number", SKIP_UNTIL_NEW_LINE)
					continue

			elif(theProperty == "score"):
				if(currType() == ReactionSystemLexer.TOKEN.FLOAT):
					result.score = consume().value
				else:
					pushError("Score must be a floating number", SKIP_UNTIL_NEW_LINE)
					continue
			elif(theProperty == "cond"):
				var theExpr := parseExpression()
				if(!theExpr):
					continue
				if(!result.condition):
					result.condition = theExpr
				else:
					result.condition = ReactionExpression.Binary.create(result.condition, ReactionExpression.OPERATOR.AND, theExpr)
			else:
				pushError("Expected priority, score, cond or < lines >", SKIP_UNTIL_NEW_LINE)
				continue
			
			continue
		
		pushError("Expected priority, score, cond or < lines >", SKIP_UNTIL_NEW_LINE)
	
	return result

func didNewDefBegan() -> bool:
	var theCurr := currType()
	if(theCurr == ReactionSystemLexer.TOKEN.FILL || theCurr == ReactionSystemLexer.TOKEN.DEF):
		return true
	return false

func parseDefinition() -> ReactionEntry:
	consume() # Consume the def
	var result := ReactionEntry.new()
	
	if(currType() != ReactionSystemLexer.TOKEN.WORD):
		pushError("Expected def ID")
		return null
	
	var theIDToken := consume()
	result.id = str(theIDToken.value)
	
	if(currType() != ReactionSystemLexer.TOKEN.EOL && currType() != ReactionSystemLexer.TOKEN.EOF):
		pushError("Expected END OF LINE or END OF FILE")
		return null
	consume() # Consume the eol/eof
	
	# Finding arguments
	while(!isEOF()):
		if(checkEOL()):
			continue
		if(checkEOF()):
			break
		if(currType() == ReactionSystemLexer.TOKEN.END):
			consume()
			break # The definition has ended
		if(didNewDefBegan()):
			break # The definition has ended, something else has started
		if(currType() == ReactionSystemLexer.TOKEN.LINES):
			var theLines := consume()
			result.fallback.append_array(theLines.value)
			continue
		if(currType() == ReactionSystemLexer.TOKEN.ARG):
			consume()
			if(currType() != ReactionSystemLexer.TOKEN.WORD):
				pushError("Expected argument name after arg", SKIP_UNTIL_NEW_LINE)
				continue
			var theArgNameToken := consume()
			if(currType() != ReactionSystemLexer.TOKEN.WORD):
				pushError("Expected argument type after argument name", SKIP_UNTIL_NEW_LINE)
				continue
			var theTypeToken := consume()
			var newArg:ReactionEntry.Argument = ReactionEntry.Argument.new()
			if(theTypeToken.value == "PAWN"):
				newArg.type = ReactionEntry.ArgType.PAWN
			elif(theTypeToken.value == "BOOL"):
				newArg.type = ReactionEntry.ArgType.BOOL
			elif(theTypeToken.value == "INT"):
				newArg.type = ReactionEntry.ArgType.INT
			elif(theTypeToken.value == "FLOAT"):
				newArg.type = ReactionEntry.ArgType.FLOAT
			elif(theTypeToken.value == "STRING"):
				newArg.type = ReactionEntry.ArgType.STRING
			else:
				pushError("INVALID ARGUMENT TYPE (Could be PAWN,BOOL,INT,FLOAT,STRING)", SKIP_UNTIL_NEW_LINE)
				continue
			
			if(checkEOL() || checkEOF()):
				newArg.default = ReactionEntry.getDefaultValueForArgType(newArg.type)
				result.args[theArgNameToken.value] = newArg
				continue
			elif(currType() == ReactionSystemLexer.TOKEN.TRUE):
				consume()
				if(newArg.type == ReactionEntry.ArgType.BOOL):
					newArg.default = true
				else:
					pushError("INVALID ARGUMENT DEFAULT VALUE FOR THIS TYPE", SKIP_UNTIL_NEW_LINE)
					continue
			elif(currType() == ReactionSystemLexer.TOKEN.FALSE):
				consume()
				if(newArg.type == ReactionEntry.ArgType.BOOL):
					newArg.default = false
				else:
					pushError("INVALID ARGUMENT DEFAULT VALUE FOR THIS TYPE", SKIP_UNTIL_NEW_LINE)
					continue
			#elif(currType() == ReactionSystemLexer.TOKEN.WORD):
				#var theValueToken := consume()
				#if(newArg.type == ReactionEntry.ArgType.BOOL):
					#if(theValueToken.value == "true"):
						#newArg.default = true
					#elif(theValueToken.value == "false"):
						#newArg.default = false
					#else:
						#pushError("INVALID ARGUMENT DEFAULT VALUE (Could be true or false)", SKIP_UNTIL_NEW_LINE)
						#continue
				#else:
					#pushError("INVALID ARGUMENT DEFAULT VALUE", SKIP_UNTIL_NEW_LINE)
					#continue
			elif(currType() == ReactionSystemLexer.TOKEN.INT):
				var theValueToken := consume()
				if(newArg.type == ReactionEntry.ArgType.INT):
					newArg.default = theValueToken.value
				else:
						pushError("INVALID ARGUMENT DEFAULT VALUE (Expected an integer number)", SKIP_UNTIL_NEW_LINE)
						continue
			elif(currType() == ReactionSystemLexer.TOKEN.FLOAT):
				var theValueToken := consume()
				if(newArg.type == ReactionEntry.ArgType.FLOAT):
					newArg.default = theValueToken.value
				else:
						pushError("INVALID ARGUMENT DEFAULT VALUE (Expected a floating number)", SKIP_UNTIL_NEW_LINE)
						continue
			else:
				pushError("Expected default value or end of line after argument name", SKIP_UNTIL_NEW_LINE)
				continue
			
			if(checkEOL() || checkEOF()):
				result.args[theArgNameToken.value] = newArg
			else:
				pushError("Expected end of line after the argument", SKIP_UNTIL_NEW_LINE)
				continue
			continue
		
		handleUnexpectedToken()
	
	return result

func handleUnexpectedToken():
	if(!pushError("Unexpected token")):
		consume() # pushError returns false if it didn't consume any tokens, this is a safe-guard

func checkEOL() -> bool:
	if(currType() == ReactionSystemLexer.TOKEN.EOL):
		consume()
		return true
	return false

func checkEOF() -> bool:
	if(currType() == ReactionSystemLexer.TOKEN.EOF):
		consume()
		if(!isEOF()):
			pushError("Got tokens after the END OF FILE token.")
		return true
	return false

func skipUntilSafe() -> bool:
	var didAnyConsumes:bool = false
	while(!isEOF()):
		var curToken:int = currType()
		
		if(curToken < 0):
			break
		if(curToken == ReactionSystemLexer.TOKEN.DEF):
			break
		if(curToken == ReactionSystemLexer.TOKEN.FILL):
			break
		if(curToken == ReactionSystemLexer.TOKEN.END):
			consume()
			didAnyConsumes = true
			break
		consume()
		didAnyConsumes = true
	return didAnyConsumes

func skipUntilNewLine() -> bool:
	var didAnyConsumes:bool = false
	while(!isEOF()):
		var curToken:int = currType()
		
		if(curToken == ReactionSystemLexer.TOKEN.EOL):
			consume()
			didAnyConsumes = true
			break
		consume()
		didAnyConsumes = true
	return didAnyConsumes

func curr() -> ReactionSystemLexer.ParseToken:
	if(curI >= curLen):
		return null
	return curLexerResult.tokens[curI]

func currType() -> int:
	if(curI >= curLen):
		return -1
	return curLexerResult.tokens[curI].type

func next(_howFar:int = 1) -> ReactionSystemLexer.ParseToken:
	if((curI+_howFar) >= curLen):
		return null
	return curLexerResult.tokens[curI+_howFar]

func nextType(_howFar:int = 1) -> int:
	if((curI+_howFar) >= curLen):
		return -1
	return curLexerResult.tokens[curI+_howFar].type

func consume() -> ReactionSystemLexer.ParseToken:
	curI += 1
	return next(-1)

func isEOF() -> bool:
	return curI >= curLen

const SKIP_UNTIL_NEXT_DEF := 0
const SKIP_UNTIL_NEW_LINE := 1
const SKIP_DISABLE := 2

func pushError(_error:String, _skipPolicy:int = SKIP_UNTIL_NEXT_DEF) -> bool:
	curResult.hadErrors = true
	if(curResult.errors.size() < MAX_ERRORS):
		var curToken := curr()
		
		if(curToken):
			curResult.errors.append(curToken.getErrorDebugString()+": "+_error)
		else:
			curResult.errors.append(_error)
		if(curResult.errors.size() == MAX_ERRORS):
			curResult.errors.append("TOO MANY ERRORS, IGNORING THE REST")
	
	if(_skipPolicy == SKIP_UNTIL_NEXT_DEF):
		return skipUntilSafe()
	elif(_skipPolicy == SKIP_UNTIL_NEW_LINE):
		return skipUntilNewLine()
	else:
		return true

func parseExpression() -> ReactionExpression:
	var theEquality := parseLogicOr()
	if(!theEquality):
		return null
	
	# Ternary
	if(currType() == ReactionSystemLexer.TOKEN.IF):
		consume()
		
		var theConditionExpr := parseExpression()
		if(!theConditionExpr):
			return null
		if(currType() != ReactionSystemLexer.TOKEN.ELSE):
			pushError("Expected 'else'", SKIP_UNTIL_NEW_LINE)
			return null
		consume()
		
		var falseExpr := parseExpression()
		if(!falseExpr):
			return null
		var theTern := ReactionExpression.Ternary.create(theConditionExpr, theEquality, falseExpr)
		return theTern
	
	return theEquality

func parseLogicOr() -> ReactionExpression:
	var expr := parseLogicAnd()
	if(!expr):
		return null

	while(currType() == ReactionSystemLexer.TOKEN.OR):
		var theToken := consume()
		var right := parseLogicAnd()
		if(!right):
			return null
		expr = ReactionExpression.Binary.create(expr, ReactionExpression.tokenToOperator(theToken.type), right)
	
	return expr

func parseLogicAnd() -> ReactionExpression:
	var expr := parseEquality()
	if(!expr):
		return null

	while(currType() == ReactionSystemLexer.TOKEN.AND):
		var theToken := consume()
		var right := parseEquality()
		if(!right):
			return null
		expr = ReactionExpression.Binary.create(expr, ReactionExpression.tokenToOperator(theToken.type), right)
	
	return expr

func parseEquality() -> ReactionExpression:
	var expr := parseComparison()
	if(!expr):
		return null
	
	while(currType() in [ReactionSystemLexer.TOKEN.MATH_EQUALEQUAL, ReactionSystemLexer.TOKEN.MATH_BANGEQUAL]):
		var theToken := consume()
		var right := parseComparison()
		if(!right):
			return null
		expr = ReactionExpression.Binary.create(expr, ReactionExpression.tokenToOperator(theToken.type), right)
	
	return expr

func parseComparison() -> ReactionExpression:
	var expr := parseTerm()
	if(!expr):
		return null
	
	while(currType() in [ReactionSystemLexer.TOKEN.MATH_MORE, ReactionSystemLexer.TOKEN.MATH_LESS, ReactionSystemLexer.TOKEN.MATH_MOREOREQUAL, ReactionSystemLexer.TOKEN.MATH_LESSOREQUAL]):
		var theToken := consume()
		var right := parseTerm()
		if(!right):
			return null
		expr = ReactionExpression.Binary.create(expr, ReactionExpression.tokenToOperator(theToken.type), right)
	
	return expr

func parseTerm() -> ReactionExpression:
	var expr := parseFactor()
	if(!expr):
		return null
	
	while(currType() in [ReactionSystemLexer.TOKEN.MATH_PLUS, ReactionSystemLexer.TOKEN.MATH_MINUS]):
		var theToken := consume()
		var right := parseFactor()
		if(!right):
			return null
		expr = ReactionExpression.Binary.create(expr, ReactionExpression.tokenToOperator(theToken.type), right)
	
	return expr

func parseFactor() -> ReactionExpression:
	var expr := parseUnary()
	if(!expr):
		return null
	
	while(currType() in [ReactionSystemLexer.TOKEN.MATH_DIV, ReactionSystemLexer.TOKEN.MATH_MULT]):
		var theToken := consume()
		var right := parseUnary()
		if(!right):
			return null
		expr = ReactionExpression.Binary.create(expr, ReactionExpression.tokenToOperator(theToken.type), right)
	
	return expr

func parseUnary() -> ReactionExpression:
	var theType := currType()
	if(theType == ReactionSystemLexer.TOKEN.MATH_MINUS || theType == ReactionSystemLexer.TOKEN.BANG):
		var theToken := consume()
		var right := parseUnary()
		if(!right):
			return null
		return ReactionExpression.Unary.create(ReactionExpression.tokenToOperator(theToken.type), right)
	
	return parseCall()

func parseCall() -> ReactionExpression:
	var expr := parsePrimary()
	if(!expr):
		return null
	
	while(true):
		var theType := currType()
		
		if(theType == ReactionSystemLexer.TOKEN.PAREN_LEFT):
			consume()
			
			var args:Array[ReactionExpression]
			# Arguments
			while(currType() != ReactionSystemLexer.TOKEN.PAREN_RIGHT):
				var anArg := parseExpression()
				if(!anArg):
					return null
				args.append(anArg)
				
				if(currType() == ReactionSystemLexer.TOKEN.COMMA):
					consume()
			
			if(currType() == ReactionSystemLexer.TOKEN.PAREN_RIGHT):
				consume()
				
				if(expr is ReactionExpression.Variable):
					expr = ReactionExpression.CallDirect.create(expr.name, args, expr.line)
				elif(expr is ReactionExpression.Property):
					if(expr.left is ReactionExpression.Variable):
						expr = ReactionExpression.CallDirectOn.create(expr.left.name, expr.property, args, expr.line)
					else:
						expr = ReactionExpression.CallOn.create(expr.left, expr.property, args)
				elif(expr is ReactionExpression.PropertyDirect):
					expr = ReactionExpression.CallDirectOn.create(expr.target, expr.property, args, expr.line)
				else:
					expr = ReactionExpression.Call.create(expr, args)
			else:
				pushError("Expected ')' after arguments of the function call", SKIP_UNTIL_NEW_LINE)
				return null
		elif(theType == ReactionSystemLexer.TOKEN.DOT):
			consume()
			
			if(currType() == ReactionSystemLexer.TOKEN.WORD):
				var theVal := consume()
				if(expr is ReactionExpression.Variable):
					expr = ReactionExpression.PropertyDirect.create(expr.name, theVal.value, expr.line)
				else:
					expr = ReactionExpression.Property.create(expr, theVal.value)
			else:
				pushError("Expected an ID after a dot", SKIP_UNTIL_NEW_LINE)
				return null
		else:
			break
	
	return expr
	
func parsePrimary() -> ReactionExpression:
	var theType := currType()
	if(theType == ReactionSystemLexer.TOKEN.FALSE):
		return ReactionExpression.Literal.create(false, consume().line)
	if(theType == ReactionSystemLexer.TOKEN.TRUE):
		return ReactionExpression.Literal.create(true, consume().line)
	if(theType == ReactionSystemLexer.TOKEN.INT):
		var theVal := consume()
		return ReactionExpression.Literal.create(theVal.value, theVal.line)
	if(theType == ReactionSystemLexer.TOKEN.FLOAT):
		var theVal := consume()
		return ReactionExpression.Literal.create(theVal.value, theVal.line)
	
	if(theType == ReactionSystemLexer.TOKEN.WORD):
		var theVal := consume()
		
		#if(currType() == ReactionSystemLexer.TOKEN.PAREN_LEFT):
			#consume()
			#
			#var args:Array[ReactionExpression]
			## Arguments
			#while(currType() != ReactionSystemLexer.TOKEN.PAREN_RIGHT):
				#var anArg := parseExpression()
				#if(!anArg):
					#return null
				#args.append(anArg)
			#
			#if(currType() == ReactionSystemLexer.TOKEN.PAREN_RIGHT):
				#consume()
				#
				#return ReactionExpression.CallDirect.create(theVal.value, args, theVal.line)
			#else:
				#pushError("Expected ')' after arguments of the function call", SKIP_UNTIL_NEW_LINE)
				#return null
		
		return ReactionExpression.Variable.create(theVal.value, theVal.line)
	
	if(theType == ReactionSystemLexer.TOKEN.PAREN_LEFT):
		consume()
		var expr := parseExpression()
		if(!expr):
			return null
		if(currType() != ReactionSystemLexer.TOKEN.PAREN_RIGHT):
			pushError("Expected ')' after expression", SKIP_UNTIL_NEW_LINE)
			return null
		consume()
		return ReactionExpression.Grouping.create(expr)
	
	pushError("Expected expression", SKIP_UNTIL_NEW_LINE)
	return null

func parseStandaloneExpression(_result:ReactionSystemLexer.ParseResult) -> ReactionExpression:
	curResult = ParseResult.new()
	curI = 0
	curLexerResult = _result
	curLen = curLexerResult.tokens.size()
	
	return parseExpression()
