extends RefCounted
class_name SocialInteractionBase

var id:String = ""
var agree:float = 0.0
var success:float = 0.0 # A number between -1.0 and 1.0
var showChange:bool = true

var charIDStarter:String = ""
var charIDTarget:String = ""

func setPawns(_pawnStarter:CharacterPawn, _pawnTarget:CharacterPawn):
	charIDStarter = _pawnStarter.getCharID()
	charIDTarget = _pawnTarget.getCharID()

# Calculate if the target should agree
func trySocialInteraction() -> void:
	agree = 1.0

# Should the target agree?
func scoreAgree() -> float:
	return agree

# The interaction is just about to start
func onStart() -> void:
	success = 1.0

# The interaction has ended
func onEnd() -> void:
	addAffection(0.1)

# The target has denied us
func onDenied() -> void:
	addAffection(-0.1)

func setInteraction(_interaction:InteractionSocialBase):
	pass


# util
func getStarterPawn() -> CharacterPawn:
	return GM.main.pawn_registry.getPawn(charIDStarter)
func getTargetPawn() -> CharacterPawn:
	return GM.main.pawn_registry.getPawn(charIDTarget)
func getStarterChar() -> BaseCharacter:
	return GM.main.characterRegistry.getCharacter(charIDStarter)
func getTargetChar() -> BaseCharacter:
	return GM.main.characterRegistry.getCharacter(charIDTarget)

func addAffection(_am:float, _mult:float = 1.0) -> void:
	var finalVal:float = _am*_mult
	GM.main.relationshipSystem.addAffection(charIDStarter, charIDTarget, _am*_mult)
	if(!showChange):
		return
	var pawn1 := getStarterPawn()
	var pawn2 := getTargetPawn()
	if(!pawn1 || !pawn2):
		return
	#var theSign := signf(finalVal)
	
	if(absf(_mult < 0.2)):
		if(finalVal > 0.0):
			pawn1.addSmallText("Affection~~", Color.YELLOW)
			pawn2.addSmallText("Affection~~", Color.YELLOW)
		else:
			pawn1.addSmallText("Affection~~", Color.YELLOW)
			pawn2.addSmallText("Affection~~", Color.YELLOW)
	else:
		var charAm:int = 1
		if(absf(finalVal) >= 2.5):
			charAm = 3
		elif(absf(finalVal) >= 1.5):
			charAm = 2
		
		if(finalVal > 0.0):
			var theChars:String = "+".repeat(charAm)
			pawn1.addSmallText("Affection"+theChars, Color.GREEN)
			pawn2.addSmallText("Affection"+theChars, Color.GREEN)
		elif(finalVal < 0.0):
			var theChars:String = "-".repeat(charAm)
			pawn1.addSmallText("Affection"+theChars, Color.RED)
			pawn2.addSmallText("Affection"+theChars, Color.RED)

func affectionPenalty(_minAffection:float, _penalty:float, _minPenaltyRatio:float = 0.5) -> float:
	var theAffection:float = GM.main.relationshipSystem.getAffection(charIDStarter, charIDTarget)
	if(theAffection < 0.0):
		theAffection = 0.0

	if(theAffection >= _minAffection):
		return 0.0
	var scaledPenalty:float = remap(theAffection, 0.0, _minAffection, _penalty, 0.0)
	
	return -(_penalty*_minPenaltyRatio + (1.0 - _minPenaltyRatio)*scaledPenalty)

func socialExhaustionPenalty(_startAbove:float, _am:float) -> float:
	var _target := getTargetPawn()
	var theExhaustion:float = _target.getSocialExhaustion()
	if(theExhaustion <= _startAbove):
		return 0.0
	return -theExhaustion*_am

func affectTargetSocialExhaustion(_am:float):
	var theTarget := getTargetPawn()
	var currentExhaustion := theTarget.getSocialExhaustion()
	if(_am > 0.0 && currentExhaustion > 1.0): # Damping to avoid crazy high values
		_am /= currentExhaustion
	theTarget.addSocialExhaustion(_am)

func addMemoryTarget(_memory:String):
	GM.main.memorySystem.addMemory(charIDTarget, _memory, charIDStarter)

func addMemoryStarter(_memory:String):
	GM.main.memorySystem.addMemory(charIDStarter, _memory, charIDTarget)
