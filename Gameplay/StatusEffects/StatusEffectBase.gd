extends RefCounted
class_name StatusEffectBase

var id:String = "error"
var time:float = 0.0

var defaultTime:float = 30.0
var timed:bool = true # If false, the time isn't used or checked
var alwaysChecked:bool = false # If true, the status effect will check if it should be applied

var staticBuffs:Array[Buff]
var buffsNeedUpdate:bool = true

var holder:WeakRef
var shouldBeRemoved:bool = false

const BG_COLOR_BUFF:Color = Color.GREEN
const BG_COLOR_DEBUFF:Color = Color.RED
const BG_COLOR_LEWD:Color = Color.PURPLE
const BG_COLOR_NEUTRAL:Color = Color(0.27, 0.27, 0.9, 1.0)

func getName() -> String:
	return "Fill me!"

func getDescription() -> String:
	return ""

func onStart(_args:Array):
	pass

func onCombine(_time:float, _args:Array):
	time = maxf(time, _time)

func prepareBuffs() -> Array[Buff]:
	return []

func getBuffs() -> Array[Buff]:
	if(buffsNeedUpdate):
		buffsNeedUpdate = false
		staticBuffs = prepareBuffs()
	return staticBuffs

func markBuffsNeedUpdate():
	buffsNeedUpdate = true

func removeMe():
	shouldBeRemoved = true

func setEffectsHolder(_holder:StatusEffectsHolder):
	holder = weakref(_holder)

func getHolder() -> StatusEffectsHolder:
	if(!holder):
		return null
	return holder.get_ref()

## If this function returns true, the status effect will be applied to the character. Set alwaysChecked to true
func shouldApplyTo(_char:BaseCharacter) -> bool:
	return false

func isTimed() -> bool:
	return timed

## Example return: 5m32s
func getTimeString() -> String:
	return Util.getTimeStringShortF(time)

func getTimeStringForUI() -> String:
	if(!timed):
		return ""
	return getTimeString()

func getIconPath() -> String:
	return ""

func getIcon() -> Texture2D:
	var thePath:String = getIconPath()
	if(thePath.is_empty()):
		return null
	return load(getIconPath())

func getIconBackgroundColor() -> Color:
	return BG_COLOR_NEUTRAL

func getIconColor() -> Color:
	return Color.WHITE

func getDescriptionForStatusEffect() -> String:
	var theResult:String = getDescription()
	
	var theBuffsLines := Util.getBuffsTexts(getBuffs())
	if(!theBuffsLines.is_empty()):
		theResult += "\n"+Util.join(theBuffsLines, "\n")
	
	return theResult

func saveData() -> Dictionary:
	return {
		t = time,
	}

func loadData(_data:Dictionary):
	time = SAVE.loadVar(_data, "t", 0.0)

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.Float, time,
	])

func loadNetworkData(_bins:Bins):
	_bins.loadStart()
	time = _bins.readFloat()
	_bins.endLoad()
