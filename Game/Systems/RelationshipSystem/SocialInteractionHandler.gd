extends RefCounted
class_name SocialInteractionHandler

const STATUS_UNCHANGED := -1
const STATUS_DENY := 0
const STATUS_AGREE := 1

var id:String = ""
var status:int = STATUS_DENY
var success:float = 0.0 # A number between 0.0 and 1.0. Never below zero, even if denied
var showChange:bool = true
var answer:int = STATUS_AGREE
var critical:bool = false

var charIDStarter:String = ""
var charIDTarget:String = ""

var chances:Vector3 = Vector3(1.0, 0.05, 0.05) # Success chance, criticalFailIfNoSuccess, criticalWinIfSuccess

var shouldPlaySuccessNoise:bool = true
var shouldPlayDenyNoise:bool = true

func saveData() -> Dictionary:
	return {
		id = id,
		s = status,
		su = success,
		sc = showChange,
		a = answer,
		c = critical,
		ids = charIDStarter,
		idt = charIDTarget,
		ch = chances,
	}

func loadData(_data:Dictionary):
	id = SAVE.loadStr(_data, "id")
	status = SAVE.loadInt(_data, "s", STATUS_DENY)
	success = SAVE.loadFloat(_data, "su")
	showChange = SAVE.loadBool(_data, "sc")
	answer = SAVE.loadInt(_data, "a", STATUS_AGREE)
	critical = SAVE.loadBool(_data, "c")
	charIDStarter = SAVE.loadStr(_data, "ids")
	charIDTarget = SAVE.loadStr(_data, "idt")
	chances = SAVE.loadVec3(_data, "ch")

func _init() -> void:
	pass

func setPawns(_pawnStarter:CharacterPawn, _pawnTarget:CharacterPawn):
	charIDStarter = _pawnStarter.getCharID()
	charIDTarget = _pawnTarget.getCharID()

func setChanceCalculatorResult(_chances:Vector3):
	chances = _chances

# Calculate if the target should agree
func trySocialInteraction() -> void:
	var _theAgreeChance:float = chances.x
	if(_theAgreeChance >= 1.0):
		status = STATUS_AGREE
	elif(_theAgreeChance <= 0.0):
		status = STATUS_DENY
	else:
		status = RNG.chance(_theAgreeChance*100.0)
	
# Should the target agree?
func scoreAgree() -> float:
	return (1.0 if (status == STATUS_AGREE) else 0.0)
	
func scoreStatus(_status:int) -> float:
	return (1.0 if (status == _status) else 0.0)

# The interaction is just about to start
func onStart() -> void:
	pass

# Gets called the moment the npc/player pick the agree/deny option
func onAnswer(_actualStatus:int, _allowCrits:bool = true):
	answer = _actualStatus
	if(_actualStatus == STATUS_AGREE):
		critical = _allowCrits && RNG.chance(chances.z*100.0)
		if(critical):
			playNoise(PawnNoise.GOOD_VERY, -15.0, 1.0)
		onAgree()
	if(_actualStatus == STATUS_DENY):
		critical = _allowCrits && RNG.chance(chances.y*100.0)
		if(critical):
			playNoise(PawnNoise.BAD_VERY, -15.0, 1.0)
		onDeny()
	
func onAgree():
	pass

func onDeny():
	pass

func isSuccess() -> bool:
	return answer == STATUS_AGREE

func isFail() -> bool:
	return answer == STATUS_DENY

func isCriticalSuccess() -> bool:
	return critical && isSuccess()

func isCriticalFail() -> bool:
	return critical && isFail()

# The interaction has ended
func onEnd() -> void:
	var _actualStatus:int = answer
	#var _isCritical:bool = critical
	
	if(shouldPlaySuccessNoise && _actualStatus == STATUS_AGREE):
		playSuccessNoise(success)
	if(shouldPlayDenyNoise && _actualStatus == STATUS_DENY):
		playSuccessNoise(-1.0*success)

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

func showValueChange(_text:String, _am:float, _mult:float = 1.0, _colorGood:Color = Color.GREEN, _colorBad:Color = Color.RED, _colorMeh:Color = Color.YELLOW) -> void:
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
		pawn1.addSmallText(_text+"~~", _colorMeh)
		pawn2.addSmallText(_text+"~~", _colorMeh)
	else:
		var charAm:int = 1
		if(absf(finalVal) >= 2.5):
			charAm = 3
		elif(absf(finalVal) >= 1.5):
			charAm = 2
		
		if(finalVal > 0.0):
			var theChars:String = "+".repeat(charAm)
			pawn1.addSmallText(_text+theChars, _colorGood)
			pawn2.addSmallText(_text+theChars, _colorGood)
		elif(finalVal < 0.0):
			var theChars:String = "-".repeat(charAm)
			pawn1.addSmallText(_text+theChars, _colorBad)
			pawn2.addSmallText(_text+theChars, _colorBad)

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
		_am *= (1.0 - clampf(theAff*0.2, 0.0, 0.5))
	
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
	
func playNoise(_noise:int, _volumeAdd:float = -25.0, _pitch:float = 1.0):
	if(_pitch <= 0.0):
		return
	
	var reScaledPitch:float = remap(_pitch, 0.0, 1.0, 0.6, 1.0)
	
	var theTarget := getTargetPawn()
	var theStarter := getStarterPawn()
	if(!theTarget || !theStarter):
		return
	var theTargetNode := theStarter
	#if(theStarter.isControlledByUs()):
	#	theTargetNode = theTarget
	
	theTargetNode.playPawnNoise(_noise, _volumeAdd, reScaledPitch)

func playSuccessNoise(_mult:float):
	if(absf(_mult) < MEH_THRESHOLD):
		playNoise(PawnNoise.BLIP, -15.0, 1.0)
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
			playNoise(PawnNoise.GOOD, -25.0, _mult)
			#var theChars:String = "+".repeat(charAm)
			#pawn1.addSmallText("Affection"+theChars, Color.GREEN)
			#pawn2.addSmallText("Affection"+theChars, Color.GREEN)
			pass
		elif(_mult < 0.0):
			playNoise(PawnNoise.ERROR, -15.0, -_mult)
			#var theChars:String = "-".repeat(charAm)
			#pawn1.addSmallText("Affection"+theChars, Color.RED)
			#pawn2.addSmallText("Affection"+theChars, Color.RED)
			pass

func showInteractionSuccess():
	#playSuccessNoise(success)
	var pawn2 := getTargetPawn()
	pawn2.addSmallText("Success: "+str(int(success*100.0))+"%", Color.SKY_BLUE)
