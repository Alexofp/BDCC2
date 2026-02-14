extends RefCounted
class_name CharState

## Anything that's character related and changes semi-often should go here.
var charID:String = ""

var arousal:float = 0.0
var arousalFade:float = 0.0
var autoMoan:float = 0.0

var pain:float = 0.0

var syncState:SyncState = SyncState.new(self,
	["arousal", "arousalFade", "autoMoan", "pain"],
	[Bins.Float, Bins.Float, Bins.Float, Bins.Float],
)
func setSyncVar(_var:String, _val:Variant):
	set(_var, _val)
func getSyncVar(_var:String) -> Variant:
	return get(_var)

func _init() -> void:
	pass

func setCharacter(_theChar:BaseCharacter):
	charID = _theChar.getID() if _theChar else ""

func getCharacter() -> BaseCharacter:
	return GM.characterRegistry.getCharacter(charID)

func setArousal(_newVal:float):
	_newVal = clamp(_newVal, 0.0, 1.0)
	arousal = _newVal

func getArousal() -> float:
	return arousal

func addArousal(_howMuch:float):
	arousalFade = 0.0
	arousal += _howMuch

func setAutoMoan(_val:float):
	autoMoan = _val

func addAutoMoan(_val:float):
	autoMoan += _val

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
	if(arousal > 0.0):
		arousalFade = min(arousalFade + _dt, 5.0)
		if(arousalFade >= 2.0):
			setArousal(getArousal() - _dt*0.005*arousalFade)
			
			if(arousal <= 0.0):
				arousalFade = 0.0
	else:
		arousalFade = 0.0
	
	# Arousal cap after all arousal calculations
	if(arousal > 1.0):
		arousal = 1.0
	
	if(shouldAutoMoan()):
		addAutoMoanCappedMin(-_dt, 0.0)
	
	syncState.processSyncState(_dt)

func shouldAutoMoan() -> bool:
	# Only auto-moan if we haven't received stimulation in a bit
	if((arousalFade > 1.0 || arousal <= 0.0) && autoMoan > 0.0):
		return true
	return false

func setPain(_p:float):
	pain = clampf(_p, 0.0, 1.0)

func addPain(_p:float):
	setPain(pain + _p)

func getPain() -> float:
	return pain

func getPainMax() -> float:
	return 1.0

func getPainLevel() -> float:
	return getPain() / getPainMax()

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.BINS, syncState.saveNetworkData(),
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	syncState.loadNetworkData(_data.readBins())
	_data.endLoad()

func saveData() -> Dictionary:
	return {
		syncState = syncState.saveData(),
	}

func loadData(_data:Dictionary):
	syncState.loadData(SAVE.loadVar(_data, "syncState", {}))
