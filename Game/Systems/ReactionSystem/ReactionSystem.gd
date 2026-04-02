extends RefCounted
class_name ReactionSystem

var runner:ReactionSystemRunner = ReactionSystemRunner.new()
var dataBanks:Array[ReactionBank]

class ReactionContext:
	var main:BaseCharacter
	var target:BaseCharacter
	var args:Dictionary[String, Variant]

class ReactionResult:
	var line:String

func _init() -> void:
	runner.targetObject = self

var defaultContext:ReactionContext = ReactionContext.new()
var context:ReactionContext
func setContext(_context:ReactionContext):
	context = _context
	currentDepth = 0

var currentDepth:int = 0
func reactPawnGenerate(_pawn:CharacterPawn, _reaction:String, _target:CharacterPawn = null, _args:Dictionary[String, Variant] = {}) -> ReactionResult:
	context = defaultContext
	context.main = _pawn.getCharacter()
	context.target = _target.getCharacter()
	context.args = _args
	currentDepth = 0
	
	return generateReaction(_reaction, context)
	
func generateReaction(_reaction:String, _context:ReactionContext) -> ReactionResult:
	setContext(_context)
	var theLine := generateReactionLineSmart(_reaction)
	if(!theLine || theLine.hadError):
		return null
	
	var theProcessedText:String = processString(theLine.value)
		
	var theResult := ReactionResult.new()
	theResult.line = processStringFinal(theProcessedText)
	return theResult

func processStringFinal(_text:String) -> String:
	var theResult := GM.textParser.parseString(_text, getSimpleGameTextParserTextSimple)
	return theResult.text

func getSimpleGameTextParserTextSimple(_id:String, _command:String, _arg:String) -> SGTPResult:
	var theResult:SGTPResult = null
	if(context):
		if(_id == "main"):
			theResult = GM.characterRegistry.getSimpleGameTextParserText(context.main.getID(), _command, _arg)
		elif(_id == "target"):
			theResult = GM.characterRegistry.getSimpleGameTextParserText(context.target.getID(), _command, _arg)
		elif(context.args.has(_id)):
			if(context.args[_id] is BaseCharacter):
				theResult = GM.characterRegistry.getSimpleGameTextParserText(context.args[_id].getID(), _command, _arg)
			if(context.args[_id] is CharacterPawn):
				theResult = GM.characterRegistry.getSimpleGameTextParserText(context.args[_id].getCharID(), _command, _arg)
		
	return theResult

func processString(_text:String) -> String:
	var theDepth:int = currentDepth
	var theParts := splitSubReactions(_text)
	
	var result:String = ""
	for thePartEntry in theParts:
		if(thePartEntry[0] == SUB_JUST_TEXT):
			result += thePartEntry[1]
		elif(thePartEntry[0] == SUB_REACTION):
			currentDepth = theDepth + 1
			if(currentDepth > 10):
				continue
			
			var theReactionTextRaw:String = thePartEntry[1]
			var theReactionResult := generateReactionLineSmart(theReactionTextRaw)
			
			if(theReactionResult && !theReactionResult.hadError):
				var theNewLine:String = theReactionResult.value
				theNewLine = processString(theNewLine)
				result += theNewLine
			
	return result

const SUB_JUST_TEXT := 0
const SUB_REACTION := 1
func splitSubReactions(_text:String) -> Array:
	var curS:int = 0
	var curE:int = -1
	var textLen:int = _text.length()
	
	var theParts:Array
	
	var curReactType:int = SUB_JUST_TEXT
	for _i in textLen:
		var theC:String = _text[_i]
		
		if(theC == "%" && (_i == 0 || (_i > 0 && _text[_i-1] != "\\"))):
			if((curE-curS+1) > 0):
				var textSub:String = _text.substr(curS, curE-curS+1)
				theParts.append([curReactType, textSub])
			
			if(curReactType == SUB_JUST_TEXT):
				curReactType = SUB_REACTION
			else:
				curReactType = SUB_JUST_TEXT
			
			curS = _i + 1
			curE = _i
		else:
			curE = _i
	
	if((curE-curS+1) > 0):
		theParts.append([curReactType, _text.substr(curS, curE-curS+1)])
	
	return theParts

# returns [id, prefix, postfix, array of options, fallback line]
func parseReactionIDSmart(_id:String) -> Array:
	var theFallback:String = ""
	var theFallbackSplit:Array = Util.splitOnFirst(_id, "^")
	if(theFallbackSplit.size() > 1):
		theFallback = theFallbackSplit[1]
	
	var theSplit:Array = theFallbackSplit[0].split("|")
	
	var theFirst:String = theSplit[0]
	theSplit.pop_front()
	
	var thePrefix:String = ""
	var thePostfix:String = ""
	var theID:String = ""
	var theState:int = 0 #0 = prefix, 1 = id, 2 = postfix
	
	for ch in theFirst:
		if(theState == 0):
			if(UtilParsing.ASCIILetters.has(ch)):
				theState = 1
				theID += ch
			else:
				thePrefix += ch
		elif(theState == 1):
			if(!UtilParsing.ASCIILetters.has(ch) && ch != "_"):
				theState = 2
				thePostfix += ch
			else:
				theID += ch
		elif(theState == 2):
			thePostfix += ch
	
	return [theID, thePrefix, thePostfix, theSplit, theFallback]

func generateReactionLineSmart(_id:String) -> ReactionSystemRunner.ResultOrError:
	var theStuff := parseReactionIDSmart(_id)
	
	var theLine := generateReactionLine(theStuff[0])
	if(!theLine || theLine.hadError):
		var theFallback:String = theStuff[4]
		if(!theFallback.is_empty()):
			return createValue(theFallback)
		return theLine
	
	var newText:String = theLine.value
	for theOption in theStuff[3]:
		if(theOption == "uncap"):
			if(newText.length() > 0):
				newText[0] = newText[0].to_lower()
		elif(theOption == "uncapAll"):
			newText = newText.to_lower()
		elif(theOption == "cap"):
			if(newText.length() > 0):
				newText[0] = newText[0].to_upper()
		elif(theOption == "capAll"):
			newText = newText.to_upper()
	
	newText = theStuff[1] + newText + theStuff[2]
	theLine.value = newText
	return theLine

func generateReactionLine(_id:String) -> ReactionSystemRunner.ResultOrError:
	var theEntry := findReactionEntryOrFallback(_id)
	if(!theEntry):
		return null
	
	var theFill := generateFill(theEntry)
	if(theFill):
		return createValue(theFill.getRandomLine())
	if(theEntry.fallback.is_empty()):
		return null
	return createValue(RNG.pick(theEntry.fallback))

func generateFill(theEntry:ReactionEntry) -> ReactionFill:
	var _id:String = theEntry.id
	var curPrio:int = -99999
	var possibleFills:Dictionary[ReactionFill, float]
	
	for theData in dataBanks:
		if(!theData.fills.has(_id)):
			continue
		var theFills:Array[ReactionFill] = theData.fills[_id]
		
		for theFill in theFills:
			if(theFill.condition && !runner.execute(theFill.condition)): # condition not satisfied
				continue
			var theScore:float = theFill.score * theFill.lines.size()
			if(theScore <= 0.0):
				continue
				
			var thePrio:int = theFill.priority
			if(thePrio > curPrio):
				curPrio = thePrio
				possibleFills.clear()
			else:
				continue
			
			possibleFills[theFill] = theScore
	
	if(possibleFills.is_empty()):
		return null
	return RNG.pickWeightedDict(possibleFills)

func setDataBanks(_datas:Array[ReactionBank]):
	dataBanks = _datas

func findReactionEntry(_id:String) -> ReactionEntry:
	for theBlock in dataBanks:
		if(theBlock.defs.has(_id)):
			return theBlock.defs[_id]
	return null

func findReactionEntryOrFallback(_id:String) -> ReactionEntry:
	var theEntry := findReactionEntry(_id)
	if(!theEntry):
		return theEntry
	var hasAnyFills:bool = false
	for theBlock in dataBanks:
		if(theBlock.fills.has(_id) && !theBlock.fills[_id].is_empty()):
			hasAnyFills = true
			break
	if(hasAnyFills || !theEntry.fallback.is_empty()):
		return theEntry
	if(!theEntry.fallbackID.is_empty()):
		return findReactionEntryOrFallback(theEntry.fallbackID)
	return theEntry

const ArgBool := ReactionSystemRunner.ArgumentType.Bool
const ArgNumber := ReactionSystemRunner.ArgumentType.Number
const ArgInt := ReactionSystemRunner.ArgumentType.Int
const ArgFloat := ReactionSystemRunner.ArgumentType.Float
const ArgString := ReactionSystemRunner.ArgumentType.String
const ArgPawn := ReactionSystemRunner.ArgumentType.Pawn

func createError(_text:String) -> ReactionSystemRunner.ResultOrError:
	return ReactionSystemRunner.ResultOrError.createError(_text)

func createValue(_value:Variant) -> ReactionSystemRunner.ResultOrError:
	return ReactionSystemRunner.ResultOrError.create(_value)

func getContextChar(_id:String) -> BaseCharacter:
	if(_id == "main"):
		return context.main
	if(_id == "target"):
		return context.target
	if(context.args.has(_id)):
		if(context.args[_id] is CharacterPawn):
			return context.args[_id].getCharacter()
		if(context.args[_id] is BaseCharacter):
			return context.args[_id]
	return null

func hasContextChar(_id:String) -> bool:
	return getContextChar(_id) != null

func getContextPawn(_id:String) -> CharacterPawn:
	if(_id == "main"):
		return context.main.getPawn()
	if(_id == "target"):
		return context.target.getPawn()
	if(context.args.has(_id)):
		if(context.args[_id] is CharacterPawn):
			return context.args[_id]
		if(context.args[_id] is BaseCharacter):
			return context.args[_id].getPawn()
	return null

func hasContextPawn(_id:String) -> bool:
	return getContextPawn(_id) != null

func getVariable(_runner:ReactionSystemRunner, _varName:String) -> ReactionSystemRunner.ResultOrError:
	if(hasContextChar(_varName)):
		return createValue(getContextChar(_varName))
	if(context.args.has(_varName)):
		var theArg:Variant = context.args[_varName]
		return createValue(theArg)
	if(_varName == "depth"):
		return createValue(currentDepth)
		
	return createError("Undefined variable "+_varName)

func doFunctionCall(_runner:ReactionSystemRunner, _method:String, _args:Array) -> ReactionSystemRunner.ResultOrError:
	if(_method == "chance"):
		var argCheck := _runner.checkArguments([ArgNumber], _args)
		if(argCheck):
			return argCheck
		return createValue(RNG.chance(_args[0]))
	if(_method == "randfRange"):
		var argCheck := _runner.checkArguments([ArgNumber, ArgNumber], _args)
		if(argCheck):
			return argCheck
		return createValue(RNG.randfRange(_args[0], _args[1]))

	return createError("Undefined function "+_method)

# Add this func to your obj
#func getReactionProperty(_runner:ReactionSystemRunner, _property:String) -> ReactionSystemRunner.ResultOrError:
#	return _runner.createValue(123)

func getPropertyValueOf(_runner:ReactionSystemRunner, _target:Variant, _property:String) -> ReactionSystemRunner.ResultOrError:
	if(_target is CharacterPawn):
		return getPawnProperty(_target, _property)
	if(_target is BaseCharacter):
		return getCharacterProperty(_target, _property)
	if(_target && _target.has_method("getReactionProperty")):
		var theVal = _target.getReactionProperty(_runner, _property)
		if(theVal is ReactionSystemRunner.ResultOrError):
			return theVal
		if(theVal):
			return createValue(theVal)
	return createError("Undefined property "+str(_target)+"."+_property)

# Add this func to your obj
#func doReactionFunctionCall(_runner:ReactionSystemRunner, _method:String, _args:Array) -> ReactionSystemRunner.ResultOrError:
#	return _runner.createValue(123)

func doFunctionCallOnObject(_runner:ReactionSystemRunner, _target:Variant, _method:String, _args:Array) -> ReactionSystemRunner.ResultOrError:
	#if(_target is BaseCharacter):
		#if(_method == "hasMemoryWith"):
			#var argCheck := _runner.checkArguments([ArgString, ArgPawn], _args)
			#if(argCheck):
				#return argCheck
			#return createValue( _target.memoryHolder.hasMemoryWith(_args[0], _args[1].getID()) )
		#if(_method == "getMemoryAmountWith"):
			#var argCheck := _runner.checkArguments([ArgString, ArgPawn], _args)
			#if(argCheck):
				#return argCheck
			#return createValue( _target.memoryHolder.getMemoryAmountWith(_args[0], _args[1].getID()) )

	if(_target && _target.has_method("doReactionFunctionCall")):
		var theVal = _target.doReactionFunctionCall(_runner, _method, _args)
		if(theVal is ReactionSystemRunner.ResultOrError):
			return theVal
		if(theVal != null):
			return createValue(theVal)
	
	return createError("Undefined function "+str(_target)+"."+_method)

#func getValueCallDirectOn(_runner:ReactionSystemRunner, _target:String, _method:String, _args:Array) -> ReactionSystemRunner.ResultOrError:
	#if(_target == "RNG"):
		#if(_method == "chance"):
			#var argCheck := _runner.checkArguments([ArgNumber], _args)
			#if(argCheck):
				#return argCheck
			#return createValue(RNG.chance(_args[0]))
		#if(_method == "randfRange"):
			#var argCheck := _runner.checkArguments([ArgNumber, ArgNumber], _args)
			#if(argCheck):
				#return argCheck
			#return createValue(RNG.randfRange(_args[0], _args[1]))
	
	#var thePawn := getContextPawn(_target)
	#if(thePawn):
		#if(_method == "hasMemoryWith"):
			#var argCheck := _runner.checkArguments([ArgString, ArgPawn], _args)
			#if(argCheck):
				#return argCheck
			#return createValue( thePawn.getCharacter().memoryHolder.hasMemoryWith(_args[0], _args[1].getID()) )
		#if(_method == "getMemoryAmountWith"):
			#var argCheck := _runner.checkArguments([ArgString, ArgPawn], _args)
			#if(argCheck):
				#return argCheck
			#return createValue( thePawn.getCharacter().memoryHolder.getMemoryAmountWith(_args[0], _args[1].getID()) )
	#
	#return createError("Undefined function "+_target+"."+_method)

func getPawnProperty(_pawn:CharacterPawn, _property:String) -> ReactionSystemRunner.ResultOrError:
	if(!_pawn):
		return createError("Pawn is missing")
	
	var theCharacter := _pawn.getCharacter()
	
	if(_property == "memory"):
		return createValue(theCharacter.memoryHolder)
	if(_property == "pain"):
		return createValue(theCharacter.getPainLevel())
	if(_property == "annoy"):
		if(_pawn == context.main.getPawn()):
			return createValue(_pawn.getAnnoyance(context.target.getPawn()))
		else:
			return createValue(_pawn.getAnnoyance(context.main.getPawn()))
	
	return null

func getCharacterProperty(_char:BaseCharacter, _property:String) -> ReactionSystemRunner.ResultOrError:
	if(!_char):
		return createError("Char is missing")
	
	var _pawn := _char.getPawn()
	
	if(_property == "memory"):
		return createValue(_char.memoryHolder)
	if(_property == "pain"):
		return createValue(_char.getPainLevel())
	if(_pawn):
		return getPawnProperty(_pawn, _property)
	
	return null
