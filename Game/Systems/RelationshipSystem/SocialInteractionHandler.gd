extends RefCounted
class_name SocialInteractionHandler

var id:String = ""
var agree:float = 0.0
var success:float = 0.0 # A number between -1.0 and 1.0
var showChange:bool = true
var kind:String = ""

var charIDStarter:String = ""
var charIDTarget:String = ""

var agreeChecks:Array[SocialCheckBase] = []

func _init() -> void:
	pass

func setPawns(_pawnStarter:CharacterPawn, _pawnTarget:CharacterPawn):
	charIDStarter = _pawnStarter.getCharID()
	charIDTarget = _pawnTarget.getCharID()

# Calculate if the target should agree
func trySocialInteraction() -> void:
	agree = 1.0
	for check in agreeChecks:
		check.socialHandler = self
		if(!check.shouldAgree()):
			check.socialHandler = null
			agree = 0.0
			return
		check.socialHandler = null

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

const MEH_THRESHOLD := 0.2

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
	
	if(absf(_mult) < MEH_THRESHOLD):
		#if(finalVal > 0.0):
		#	pawn1.addSmallText("Affection~~", Color.YELLOW)
		#	pawn2.addSmallText("Affection~~", Color.YELLOW)
		#else:
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

func getAffection() -> float:
	return GM.main.relationshipSystem.getAffection(charIDStarter, charIDTarget)

func affectionPenalty(_minAffection:float, _penalty:float, _minPenaltyRatio:float = 0.5) -> float:
	var theAffection:float = getAffection()
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

func affectTargetSocialExhaustion(_am:float, _affectStarter:bool = true):
	var theAff := getAffection()
	
	var theTarget := getTargetPawn()
	var currentExhaustion := theTarget.getSocialExhaustion()
	if(_am > 0.0 && currentExhaustion > 1.0): # Damping to avoid crazy high values
		_am /= currentExhaustion
	
	if(theAff > 0.0): # Having high affection makes the target get less social exhaustion
		_am *= (1.0 - theAff*0.7)
	
	theTarget.addSocialExhaustion(_am)
	if(_affectStarter):
		getStarterPawn().addSocialExhaustion(_am*0.5)

func addMemoryTarget(_memory:String):
	if(_memory.is_empty()):
		return
	GM.main.memorySystem.addMemory(charIDTarget, _memory, charIDStarter)

func addMemoryStarter(_memory:String):
	if(_memory.is_empty()):
		return
	GM.main.memorySystem.addMemory(charIDStarter, _memory, charIDTarget)
	
const GOOD_NOISE = preload("res://Sounds/UI/Good.ogg")
const BLIP_NOISE := preload("res://Sounds/UI/Blip.ogg")
const ERROR_NOISE := preload("res://Sounds/UI/Error.ogg")

func playNoise(_noise:AudioStream, _volumeAdd:float = -25.0, _pitch:float = 1.0):
	if(_pitch <= 0.0):
		return
	
	var reScaledPitch:float = remap(_pitch, 0.0, 1.0, 0.6, 1.0)
	
	var theTarget := getTargetPawn()
	var theStarter := getStarterPawn()
	if(!theTarget || !theStarter):
		return
	var theTargetNode := theStarter
	if(theStarter.isControlledByUs()):
		theTargetNode = theTarget
		
	Audio.playSound3DAdvanced(theTargetNode, _noise, _volumeAdd, reScaledPitch, 10.0)

func playSuccessNoise(_mult:float):
	if(absf(_mult) < MEH_THRESHOLD):
		playNoise(BLIP_NOISE, -25.0, 1.0)
		#pawn1.addSmallText("Affection~~", Color.YELLOW)
		#pawn2.addSmallText("Affection~~", Color.YELLOW)
		pass
	else:
		var _charAm:int = 1
		if(absf(_mult) >= 2.5):
			_charAm = 3
		elif(absf(_mult) >= 1.5):
			_charAm = 2
		
		if(_mult > 0.0):
			playNoise(GOOD_NOISE, -25.0, _mult)
			#var theChars:String = "+".repeat(charAm)
			#pawn1.addSmallText("Affection"+theChars, Color.GREEN)
			#pawn2.addSmallText("Affection"+theChars, Color.GREEN)
			pass
		elif(_mult < 0.0):
			playNoise(ERROR_NOISE, -25.0, -_mult)
			#var theChars:String = "-".repeat(charAm)
			#pawn1.addSmallText("Affection"+theChars, Color.RED)
			#pawn2.addSmallText("Affection"+theChars, Color.RED)
			pass

func showInteractionSuccess():
	#playSuccessNoise(success)
	var pawn2 := getTargetPawn()
	pawn2.addSmallText("Success: "+str(int(success*100.0))+"%", Color.SKY_BLUE)

func addAgreeCheck(_check:SocialCheckBase):
	agreeChecks.append(_check)
