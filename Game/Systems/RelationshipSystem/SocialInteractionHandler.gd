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

var shouldPlaySuccessNoise:bool = true
var shouldPlayDenyNoise:bool = true

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
			Log.Print("Not agreed by: "+str(check))
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
	for theCheck in agreeChecks:
		theCheck.socialHandler = self
		theCheck.onStart()
		theCheck.socialHandler = null
	Log.Print("Success: "+str(int(success*100.0))+"%")

# The interaction has ended
func onEnd() -> void:
	if(shouldPlaySuccessNoise):
		playSuccessNoise(success)
	
	for theCheck in agreeChecks:
		theCheck.socialHandler = self
		theCheck.onEnd(false)
		theCheck.socialHandler = null

# The target has denied us
func onDenied() -> void:
	if(shouldPlayDenyNoise):
		playSuccessNoise(-1.0)
	
	for theCheck in agreeChecks:
		theCheck.socialHandler = self
		theCheck.onEnd(true)
		theCheck.socialHandler = null

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
	GM.main.relationshipSystem.addAffection(charIDStarter, charIDTarget, _am*_mult)
	if(!showChange):
		return
	showValueChange("Affection", _am, _mult, Color.GREEN)

func addLust(_am:float, _mult:float = 1.0) -> void:
	GM.main.relationshipSystem.addLust(charIDStarter, charIDTarget, _am*_mult)
	if(!showChange):
		return
	showValueChange("Lust", _am, _mult, Color.PURPLE)

func showValueChange(_text:String, _am:float, _mult:float = 1.0, _colorGood:Color = Color.GREEN) -> void:
	var finalVal:float = _am*_mult
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
		pawn1.addSmallText(_text+"~~", Color.YELLOW)
		pawn2.addSmallText(_text+"~~", Color.YELLOW)
	else:
		var charAm:int = 1
		if(absf(finalVal) >= 2.5):
			charAm = 3
		elif(absf(finalVal) >= 1.5):
			charAm = 2
		
		if(finalVal > 0.0):
			var theChars:String = "+".repeat(charAm)
			pawn1.addSmallText(_text+theChars, Color.GREEN)
			pawn2.addSmallText(_text+theChars, Color.GREEN)
		elif(finalVal < 0.0):
			var theChars:String = "-".repeat(charAm)
			pawn1.addSmallText(_text+theChars, Color.RED)
			pawn2.addSmallText(_text+theChars, Color.RED)

func getAffection() -> float:
	return GM.main.relationshipSystem.getAffection(charIDStarter, charIDTarget)

func getLust() -> float:
	return GM.main.relationshipSystem.getLust(charIDStarter, charIDTarget)

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

func affectTargetSocialExhaustion(_am:float, _starterMult:float = 0.5):
	var theAff := getAffection()
	
	var theTarget := getTargetPawn()
	var currentExhaustion := theTarget.getSocialExhaustion()
	if(_am > 0.0 && currentExhaustion > 1.0): # Damping to avoid crazy high values
		_am /= currentExhaustion
	
	if(theAff > 0.0): # Having high affection makes the target get less social exhaustion
		_am *= (1.0 - theAff*0.7)
	
	theTarget.addSocialExhaustion(_am)
	if(_starterMult != 0.0):
		getStarterPawn().addSocialExhaustion(_am*_starterMult)

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

func add(_check:SocialCheckBase):
	agreeChecks.append(_check)
