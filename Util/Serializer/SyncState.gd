extends RefCounted
class_name SyncState

var obj:Object #Requires getSyncVar and setSyncVar
var fields:Array[String] = []
var fieldToIndx:Dictionary[String, int] = {}
var cachedValues:Dictionary[int, Variant] = {}
var dirtyFields:Dictionary[int, bool] = {}
var saveTypes:Array[int] = []
var dirtyTime:float = 0.0

const UPDATE_FULL = 65535

func setSyncVar(_var:String, _val:Variant):
	set(_var, _val)
func getSyncVar(_var:String) -> Variant:
	return get(_var)

func _init(_obj:Object, _fields:Array[String], _saveTypes:Array[int]):
	assert(_fields.size() <= 15, "SyncState supports only up to 15 fields")
	assert(_obj.has_method("setSyncVar"), "Object needs a setSyncVar method")
	assert(_obj.has_method("getSyncVar"), "Object needs a getSyncVar method")
	obj = _obj
	fields = _fields
	saveTypes = _saveTypes
	assert(saveTypes.size() == fields.size())
	fieldToIndx.clear()
	for _i in range(fields.size()):
		fieldToIndx[fields[_i]] = _i

func processSyncState(_dt:float):
	if(!Network.isServerNotSingleplayer()): # Make this a setting?
		return
	
	for _i in range(fields.size()):
		var field:String = fields[_i]
		var theValue:Variant = obj.getSyncVar(field)
		
		if(!cachedValues.has(_i) || cachedValues[_i] != theValue):
			cachedValues[_i] = theValue
			if(!dirtyFields.has(_i)):
				dirtyFields[_i] = true
	
	if(isDirty()):
		dirtyTime += _dt

func isDirty() -> bool:
	return !dirtyFields.is_empty()

func getDirtyTime() -> float:
	return dirtyTime

func getDelta(isCompressed:bool=false) -> PackedByteArray:
	# Full update
	if(fields.size() == dirtyFields.size()):
		var Ar:Array = [Bins.U16, UPDATE_FULL]
		for _i in range(fields.size()):
			Ar.append_array([ saveTypes[_i], cachedValues[_i] ])
		return Bins.saveStartEnd(Ar).getBytes() if !isCompressed else Bins.saveStartEnd(Ar).getBytesCompressedSimple()
	else: # Partial update
		var theUpdateMask:int = 0
		for dirtyIndx in dirtyFields:
			theUpdateMask = Util.setBitOn(theUpdateMask, dirtyIndx)
		assert(theUpdateMask != UPDATE_FULL)
		
		var Ar:Array = [Bins.U16, theUpdateMask]
		
		for _i in range(fields.size()):
			if(!dirtyFields.has(_i)):
				continue
			Ar.append_array([ saveTypes[_i], cachedValues[_i] ])
		
		return Bins.saveStartEnd(Ar).getBytes() if !isCompressed else Bins.saveStartEnd(Ar).getBytesCompressedSimple()

func resetDelta():
	dirtyFields.clear()
	dirtyTime = 0.0

func applyDelta(_delta:PackedByteArray, isCompressed:bool=false):
	#Log.Print("APPLY DELTA! Bytes="+str(_delta.size()))
	var theBins := Bins.readUncompressed(_delta) if !isCompressed else Bins.readCompressedSimple(_delta)
	theBins.loadStart()
	var theUpdateMask:int = theBins.readU16()
	if(theUpdateMask == UPDATE_FULL):
		for _i in range(fields.size()):
			var theType := saveTypes[_i]
			var theVal:Variant = theBins.read(theType)
			obj.setSyncVar(fields[_i], theVal)
	else:
		for _i in range(fields.size()):
			if(!Util.getBit(theUpdateMask, _i)):
				continue
			var theType := saveTypes[_i]
			var theVal:Variant = theBins.read(theType)
			obj.setSyncVar(fields[_i], theVal)
			
	theBins.endLoad()
