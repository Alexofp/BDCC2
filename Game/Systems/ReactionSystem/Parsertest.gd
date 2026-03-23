extends Node

func _ready() -> void:
	if(!GlobalRegistry.finishedInit):
		await GlobalRegistry.initialized
	
	var theSystem := ReactionSystem.new()
	theSystem.setDataBanks([GlobalRegistry.mainReactionBank])
	
	var theSysResult := theSystem.generateReaction("Greet", null)
	
	#var someElse := theSystem.splitSubReactions("%Hello% \\%world\\% how \\%are %you% doing.")
	
	if(true):
		return
	
	#var theRunner := ReactionSystemRunner.new()
	#var theRunnerResult := theRunner.runExpression("true and false")
	##var theRunnerResult := theRunner.runExpression("1 if 12<6 else 0")
	#
	#print(theRunnerResult.value)
	#print(theRunnerResult.errors)
	#
	#if(true):
		#return
	var theLexer:ReactionSystemLexer = ReactionSystemLexer.new()
	var theResult := theLexer.parse(Util.readFile("res://Game/Systems/ReactionSystem/ReactionTest.txt"))
	
	print("TOKENS: ", theResult.getTokensDebug())
	print("HAD ERRORS: ", theResult.hadErrors)
	if(theResult.hadErrors):
		print("ERRORS: ", theResult.errors)
	
	var theParser:ReactionSystemParser = ReactionSystemParser.new()
	#var someThing := theParser.parseStandaloneExpression(theResult)
	
	var theFinalResult := theParser.parseLexerResult(theResult)
	
	print(theFinalResult.defs,"\n",theFinalResult.fills)
	print("HAD ERRORS: ", theFinalResult.hadErrors)
	if(theFinalResult.hadErrors):
		print("ERRORS: ", theFinalResult.errors)
	pass
