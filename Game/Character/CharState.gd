extends DirtyState
class_name CharState

## Anything that's character related and changes semi-often should go here.
var charID:String = ""

var arousal:float = 0.0
var arousalFade:float = 0.0
var autoMoan:float = 0.0

func _init() -> void:
	fieldToVarName = {
		SyncOption.Arousal: "arousal",
		SyncOption.ArousalFade: "arousalFade",
		SyncOption.AutoMoan: "autoMoan",
	}

func setCharacter(_theChar:BaseCharacter):
	charID = _theChar.getID() if _theChar else ""

func getCharacter() -> BaseCharacter:
	return GM.characterRegistry.getCharacter(charID)

func setArousal(_newVal:float):
	_newVal = clamp(_newVal, 0.0, 1.0)
	if(arousal == _newVal):
		return
	arousal = _newVal
	markDirty(SyncOption.Arousal)

func getArousal() -> float:
	return arousal

func addArousal(_howMuch:float):
	setCheckDirty(SyncOption.ArousalFade, 0.0)
	setArousal(getArousal() + _howMuch)

func setAutoMoan(_val:float):
	setCheckDirty(SyncOption.AutoMoan, _val)

func addAutoMoan(_val:float):
	setAutoMoan(autoMoan+_val)

func addAutoMoanCappedMax(_val:float, maxAutomoan:float):
	if(autoMoan >= maxAutomoan):
		return
	if((autoMoan+_val) >= maxAutomoan):
		setAutoMoan(maxAutomoan)
		return
	setAutoMoan(autoMoan+_val)

func addAutoMoanCappedMin(_val:float, minAutomoan:float):
	if(autoMoan <= minAutomoan):
		return
	if((autoMoan+_val) <= minAutomoan):
		setAutoMoan(minAutomoan)
		return
	setAutoMoan(autoMoan+_val)

func getAutoMoan() -> float:
	return autoMoan

func processTime(_dt:float):
	processDirty(_dt)
	
	if(arousal > 0.0):
		setCheckDirty(SyncOption.ArousalFade, min(arousalFade + _dt, 5.0))
		if(arousalFade >= 2.0):
			setArousal(getArousal() - _dt*0.005*arousalFade)
			
			if(arousal <= 0.0):
				setCheckDirty(SyncOption.ArousalFade, 0.0)
	else:
		setCheckDirty(SyncOption.ArousalFade, 0.0)

	if(shouldAutoMoan()):
		addAutoMoanCappedMin(-_dt, 0.0)

func shouldAutoMoan() -> bool:
	# Only auto-moan if we haven't received stimulation in a bit
	if((arousalFade > 1.0 || arousal <= 0.0) && autoMoan > 0.0):
		return true
	return false

func saveNetworkedData() -> Dictionary:
	return {
		arousal = arousal,
		arousalFade = arousalFade,
	}

func loadNetworkedData(_data:Dictionary):
	arousal = SAVE.loadVar(_data, "arousal", 0.0)
	arousalFade = SAVE.loadVar(_data, "arousalFade", 0.0)
