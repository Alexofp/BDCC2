extends RefCounted
class_name ReactionSystemLexer

const MAX_ERRORS := 10

enum TOKEN {
	WORD, # any word
	EOL, # end of line \n
	DEF, # def
	FILL, # fill
	END, # end
	ARG, # arg
	DOT, # .
	COMMA, # ,
	FLOAT, # 0.5
	INT, # 5
	TRUE, # true
	FALSE, # false
	LINES, # < lines >
	EQUAL, # =
	MATH_LESS, # <
	MATH_MORE, # >
	MATH_LESSOREQUAL, # <=
	MATH_MOREOREQUAL, # >=
	MATH_EQUALEQUAL, # ==
	MATH_BANGEQUAL, # !=
	PAREN_LEFT, # (
	PAREN_RIGHT, # )
	AND, # and
	OR, # or
	BANG, # !
	MATH_PLUS, # +
	MATH_MINUS, # -
	MATH_MULT, # *
	MATH_DIV, # /
	IF, # if
	ELSE, # ELSE
	EOF, # end of file
}
const TOKENSTR := ["WORD", "EOL", "DEF", "FILL", "END", "ARG", "DOT", "COMMA", "FLOAT", "INT", "TRUE", "FALSE", "LINES", "=", "<", ">", "<=", ">=", "==", "!=", "(", ")", "AND", "OR", "NOT", "+", "-", "*", "/", "IF", "ELSE", "EOF"]
const SPECIAL:Dictionary[String, int] = {
	"def": TOKEN.DEF,
	"fill": TOKEN.FILL,
	"end": TOKEN.END,
	"arg": TOKEN.ARG,
	"and": TOKEN.AND,
	"or": TOKEN.OR,
	"not": TOKEN.BANG,
	"true": TOKEN.TRUE,
	"false": TOKEN.FALSE,
	"if": TOKEN.IF,
	"else": TOKEN.ELSE,
}
const SIMPLE:Dictionary[String, int] = {
	".": TOKEN.DOT,
	"(": TOKEN.PAREN_LEFT,
	")": TOKEN.PAREN_RIGHT,
	"+": TOKEN.MATH_PLUS,
	"-": TOKEN.MATH_MINUS,
	"*": TOKEN.MATH_MULT,
	"/": TOKEN.MATH_DIV,
	"!": TOKEN.BANG,
	",": TOKEN.COMMA,
}

class ParseToken:
	var type:int
	var value
	var line:int
	
	func getErrorDebugString() -> String:
		if(value != null):
			return "Line "+str(line)+":"+TOKENSTR[type]+":"+str(value).replace("\n","|")
		return "Line "+str(line)+":"+TOKENSTR[type]

class ParseResult:
	var tokens:Array[ParseToken]
	
	var hadErrors:bool = false
	var errors:Array[String]
	
	func getTokensDebug() -> Array[String]:
		var res:Array[String]
		for theToken in tokens:
			if(theToken.value != null):
				res.append(TOKENSTR[theToken.type]+":"+str(theToken.value).replace("\n","|"))
			else:
				res.append(TOKENSTR[theToken.type])
		return res

var curI:int
var curResult:ParseResult
var curLine:int
var curLen:int
var curText:String
func parse(_text:String) -> ParseResult:
	curResult = ParseResult.new()
	curI = 0
	curLine = 1
	curText = _text
	
	curLen = _text.length()
	while(!isEOF()):
		var theC:String = curr()
		
		if(theC == "\n"):
			pushToken(TOKEN.EOL)
			consume()
			continue
		
		if(UtilParsing.isASCIILetter(theC)):
			parseID()
			continue
		
		if(UtilParsing.isDigit(theC) || (theC == "-" && UtilParsing.isDigit(next()))):
			parseNumber()
			continue
		
		# Comments
		if(theC == "#"):
			while(!isEOF()): # Skip until the end of file or end of line
				var theLetter := consume()
				if(theLetter == "\n"):
					pushToken(TOKEN.EOL)
					break
			continue
		
		if(consumeIfText("<\n")):
			var theLines:Array[String]
			var foundEnd:bool = false
			while(!isEOF()):
				var theLine := consumeLineRaw()
				
				if(theLine.strip_edges() == ">"):
					foundEnd = true
					break
				#elif(!theLine.is_empty()):
				else:
					theLines.append(theLine)
			
			if(!foundEnd):
				pushError("<lines block wasn't closed with a >end")
			else:
				pushToken(TOKEN.LINES, theLines)
			continue
		
		if(tryParseMath()):
			continue
		
		if(SIMPLE.has(theC)):
			pushToken(SIMPLE[theC])
			consume()
			continue
		
		if(theC == " " || theC == "\t"):
			consume()
			continue
			
		pushError("Unknown character \""+theC+"\"")
		consume()
	
	pushToken(TOKEN.EOF)
	return curResult

func tryParseMath() -> bool:
	var theC := curr()
	if(theC == "=" && isNext("=")):
		pushToken(TOKEN.MATH_EQUALEQUAL)
		consume()
		consume()
		return true
	if(theC == "!" && isNext("=")):
		pushToken(TOKEN.MATH_BANGEQUAL)
		consume()
		consume()
		return true
	if(consumeTokenSimple("=", TOKEN.EQUAL)):
		return true
	if(theC == "<" && isNext("=")):
		pushToken(TOKEN.MATH_LESSOREQUAL)
		consume()
		consume()
		return true
	if(consumeTokenSimple("<", TOKEN.MATH_LESS)):
		return true
	if(theC == ">" && isNext("=")):
		pushToken(TOKEN.MATH_MOREOREQUAL)
		consume()
		consume()
		return true
	if(consumeTokenSimple(">", TOKEN.MATH_MORE)):
		return true
	return false

func parseNumber():
	var theNom:String = consume()
	var hasDot:bool = false
	
	while(!isEOF()):
		var nextC := curr()
		
		if(UtilParsing.isDigit(nextC)):
			theNom += consume()
		elif(nextC == "."):
			if(!hasDot):
				hasDot = true
				theNom += "."
				consume()
			else:
				pushError("Bad float number, too many dots")
				consume()
		else:
			break
	
	if(hasDot):
		pushToken(TOKEN.FLOAT, float(theNom))
	else:
		pushToken(TOKEN.INT, int(theNom))
	
func parseID():
	var theID:String = consume()
	#var _hasDot:bool = false
	
	while(!isEOF()):
		var nextC := curr()
		if(nextC == "_" || UtilParsing.isASCIILetter(nextC) || UtilParsing.isDigit(nextC)):
			theID += consume()
		#elif(nextC == "."): # Breaks with stuff like test.test2.
		#	_hasDot = true
		#	theID += consume()
		else:
			break
	
	if(SPECIAL.has(theID)):
		pushToken(SPECIAL[theID])
		return
	#if(hasDot):
	#	pushToken(TOKEN.CALL, theID)
	#else:
	pushToken(TOKEN.WORD, theID)

func curr() -> String:
	if(curI >= curLen):
		return ""
	return curText[curI]

func isCur(_text:String) -> bool:
	return curr() == _text

func next(_howFar:int = 1) -> String:
	if((curI+_howFar) >= curLen):
		return ""
	return curText[curI+_howFar]

func isNext(_text:String, _howFar:int = 1) -> bool:
	return next(_howFar) == _text

func consume() -> String:
	if(curr() == "\n"):
		curLine += 1
	curI += 1
	return next(-1)

func consumeTokenSimple(_text:String, _tokenID:int) -> bool:
	if(curr() == _text):
		consume()
		pushToken(_tokenID)
		return true
	return false

func consumeLineRaw() -> String:
	var theLine:String = ""
	while(!isEOF()):
		var theC := curr()
		if(theC == "\n"):
			consume()
			return theLine
		theLine += consume()
	return theLine
	
func consumeIfText(_text:String) -> bool:
	var _textLen:int = _text.length()
	for _i in _textLen:
		if(_text[_i] != next(_i)):
			return false
	for _i in _textLen:
		consume()
	return true

func isEOF() -> bool:
	return curI >= curLen

func pushToken(_t:int, _val=null):
	var newToken := ParseToken.new()
	newToken.type = _t
	newToken.value = _val
	newToken.line = curLine
	curResult.tokens.append(newToken)

func pushError(_error:String):
	curResult.hadErrors = true
	if(curResult.errors.size() < MAX_ERRORS):
		curResult.errors.append("LINE "+str(curLine)+": "+_error)
		if(curResult.errors.size() == MAX_ERRORS):
			curResult.errors.append("TOO MANY ERRORS, IGNORING THE REST")
