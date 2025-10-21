extends RefCounted
class_name SexParticipantAI

var info:WeakRef

func onSexStart():
	pass

func processAI(_dt:float):
	pass


func isPlayer() -> bool:
	return getChar().isControlledByAnyPlayer()

func setParticipant(_info:SexParticipantInfo):
	info = weakref(_info)

func getInfo() -> SexParticipantInfo:
	return info.get_ref() # if info is null, something is really wrong

func getSexEngine() -> SexEngine:
	return getInfo().getSexEngine()

func getChar() -> BaseCharacter:
	return getInfo().getChar()

func isDom() -> bool:
	return getInfo().isDom()

func isSub() -> bool:
	return getInfo().isSub()

func canDoDomActions() -> bool:
	return getInfo().canDoDomActions()

func getID() -> String:
	return getInfo().getID()
