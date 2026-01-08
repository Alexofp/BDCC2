extends RefCounted
class_name InteractCategory

const ENTRY_UNKNOWN = 0
const ENTRY_DO = 1
const ENTRY_TEXT = 2

var categoryName:String = "CHANGE ME"
var interactEntries:Array[InteractEntryBase]
var target

func supplyContext(_context:PawnActionContext):
	_context.target = target
	for entry in interactEntries:
		if(entry is InteractEntryDo):
			_context.args = entry.args
			entry.calcCachedName(_context)

func supplyContextCheckCanDo(_context:PawnActionContext):
	_context.target = target
	
	var amEntries:int = interactEntries.size()
	for _i in amEntries:
		var _indx:int = amEntries - 1 - _i
		var entry := interactEntries[_indx]
		if(entry is InteractEntryDo):
			_context.args = entry.args
			
			if(!entry.action || !entry.action.canDoAction(_context)):
				interactEntries.remove_at(_i)
				continue
			
			entry.calcCachedName(_context)
	
	_context.clearContext()

func saveNetworkData() -> Bins:
	var Ar:Array = [
		Bins.StrShort, categoryName,
		Bins.Var, GI.getUniqueIDOf(target),
		Bins.U16, interactEntries.size(),
	]
	for entry in interactEntries:
		if(entry is InteractEntryDo):
			Ar.append_array([
				Bins.U8, ENTRY_DO,
				Bins.BINS, entry.saveNetworkData(),
			])
		elif(entry is InteractEntryText):
			Ar.append_array([
				Bins.U8, ENTRY_TEXT,
				Bins.BINS, entry.saveNetworkData(),
			])
		else:
			Log.Printerr("Unknown interact entry type: "+str(entry))
			Ar.append_array([
				Bins.U8, ENTRY_UNKNOWN,
			])
	
	return Bins.saveStartEnd(Ar)

func loadNetworkData(_data:Bins):
	_data.loadStart()
	categoryName = _data.readStrShort()
	target = GI.getNodeByUniqueID(_data.readVar())
	var entriesAmount:int = _data.readU16()
	
	interactEntries.clear()
	for _i in entriesAmount:
		var entryType:int = _data.readU8()
		if(entryType == ENTRY_DO):
			var newDoEntry := InteractEntryDo.new()
			newDoEntry.loadNetworkData(_data.readBins())
			interactEntries.append(newDoEntry)
		elif(entryType == ENTRY_TEXT):
			var newTextEntry := InteractEntryText.new()
			newTextEntry.loadNetworkData(_data.readBins())
			interactEntries.append(newTextEntry)
		else:
			pass#nothing
	
	_data.endLoad()

func saveData() -> Dictionary:
	var entriesData:Array = []
	
	for entry in interactEntries:
		if(entry is InteractEntryDo):
			entriesData.append([
				ENTRY_DO,
				entry.saveData(),
			])
		elif(entry is InteractEntryText):
			entriesData.append([
				ENTRY_TEXT,
				entry.saveData(),
			])
	
	return {
		categoryName = categoryName,
		target = GI.getUniqueIDOf(target),
		interactEntries = entriesData,
	}

func loadData(_data:Dictionary):
	categoryName = SAVE.loadVar(_data, "categoryName", "")
	target = GI.getNodeByUniqueID(SAVE.loadVar(_data, "target", []))
	
	var entriesData:Array = SAVE.loadVar(_data, "interactEntries", [])
	interactEntries.clear()
	for entryRaw in entriesData:
		if(entryRaw.size() < 2):
			continue
		var theEntryType:int = entryRaw[0]
		
		if(theEntryType == ENTRY_DO):
			var newDoEntry := InteractEntryDo.new()
			newDoEntry.loadNetworkData(entryRaw[1])
			interactEntries.append(newDoEntry)
		elif(theEntryType == ENTRY_DO):
			var newTextEntry := InteractEntryText.new()
			newTextEntry.loadNetworkData(entryRaw[1])
			interactEntries.append(newTextEntry)
		else:
			pass #nothing
	pass
