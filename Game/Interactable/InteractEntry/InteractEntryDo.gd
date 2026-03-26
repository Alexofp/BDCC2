extends InteractEntryBase
class_name InteractEntryDo

var action:PawnActionBase
var args:Array
var cachedName:String = ""
var disabled:bool = false

static func create(_id:String, _args:Array = []) -> InteractEntryDo:
	var newEntry := InteractEntryDo.new()
	newEntry.action = GlobalRegistry.getPawnAction(_id)
	newEntry.args = _args
	if(newEntry.action):
		newEntry.subCategory = newEntry.action.getSubCategory()
	return newEntry

func setDisabled(_b:bool) -> InteractEntryDo:
	disabled = _b
	return self

func calcCachedName(_context:PawnActionContext):
	if(!action):
		cachedName = str(action)
		return
	cachedName = action.getVisibleName(_context)

func saveNetworkData() -> Bins:
	return Bins.saveStartEnd([
		Bins.StrShort, action.id if action else "",
		Bins.StrShort, cachedName,
		Bins.StringArrayShort, subCategory,
		Bins.Bool, disabled,
		#Bins.Var, args,
	])

func loadNetworkData(_data:Bins):
	_data.loadStart()
	var actionID := _data.readStrShort()
	action = GlobalRegistry.getPawnAction(actionID)
	cachedName = _data.readStrShort()
	subCategory = _data.readStringArrayShort()
	disabled = _data.readBool()
	#args = _data.readVar()
	_data.endLoad()
			
func saveData() -> Dictionary:
	return {
		actionID = action.id if action else "",
		subCategory = subCategory,
		disabled = disabled,
		#args = args,
	}

func loadData(_data:Dictionary):
	var actionID:String = SAVE.loadVar(_data, "actionID", "")
	action = GlobalRegistry.getPawnAction(actionID)
	subCategory = SAVE.loadVar(_data, "subCategory", subCategory)
	disabled = SAVE.loadVar(_data, "disabled", false)
	#args = SAVE.loadVar(_data, "args", [])
	pass
