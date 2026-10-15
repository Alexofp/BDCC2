extends RefCounted
class_name FetishHolder

var charRef:WeakRef

var performing:FetishSet = FetishSet.new()
var receiving:FetishSet = FetishSet.new()

signal onFetishUpdate(fetishID:String, isPerforming:bool, value:float)
signal onFetishesUpdated
signal onFetishFullUpdate

func _init() -> void:
	performing.onFetishChange.connect(func(fetishID:String, val:float):
		onFetishUpdate.emit(fetishID, true, val))
	performing.onUpdate.connect(func():
		onFetishesUpdated.emit())
	performing.onFullUpdate.connect(func():
		onFetishFullUpdate.emit())
	
	receiving.onFetishChange.connect(func(fetishID:String, val:float):
		onFetishUpdate.emit(fetishID, false, val))
	receiving.onUpdate.connect(func():
		onFetishesUpdated.emit())
	receiving.onFullUpdate.connect(func():
		onFetishFullUpdate.emit())

func setChar(_char:BaseCharacter):
	charRef = weakref(_char) if _char else null

func getChar() -> BaseCharacter:
	return charRef.get_ref() if charRef else null

func setPerforming(_fetishID:String, _val:float):
	performing.setFetish(_fetishID, _val)

func setReceiving(_fetishID:String, _val:float):
	receiving.setFetish(_fetishID, _val)

func getPerforming(_fetishID:String) -> float:
	return performing.getFetish(_fetishID)

func getReceiving(_fetishID:String) -> float:
	return receiving.getFetish(_fetishID)

func generateFetishesGen(_generator:CharacterGenerator):
	generateFetishes(_generator)
	
func generateFetishes(_gen:CharacterGenerator = null):
	var _char:BaseCharacter = getChar() if !_gen else _gen.character
	var theTraits:Array[TraitBase] = _char.traitHolder.getTraits()
	
	for _fetishID:String in GlobalRegistry.fetishes:
		var theFetish:FetishBase = GlobalRegistry.fetishes[_fetishID]
		#if(theFetish.shouldApplyToReceiving(_char)):
		if(true):
			var _value:float = theFetish.generateInitialValueReceiving(_char, _gen)
			
			for theTrait:TraitBase in theTraits:
				if(!theTrait.fetishChangesReceiving.has(_fetishID)):
					continue
				var theVal:Vector2 = theTrait.fetishChangesReceiving[_fetishID]
				_value += randf_range(theVal.x, theVal.y)
			setReceiving(_fetishID, _value)
		#if(theFetish.shouldApplyToPerforming(_char)):
		if(true):
			var _value:float = theFetish.generateInitialValuePerforming(_char, _gen)
			
			for theTrait:TraitBase in theTraits:
				if(!theTrait.fetishChangesPerforming.has(_fetishID)):
					continue
				var theVal:Vector2 = theTrait.fetishChangesPerforming[_fetishID]
				_value += randf_range(theVal.x, theVal.y)
			setPerforming(_fetishID, _value)
		
		
		
func saveNetworkData() -> Bins:
	var Ar:Array = [
		Bins.BINS, performing.saveNetworkData(),
		Bins.BINS, receiving.saveNetworkData(),
	]

	return Bins.saveStartEnd(Ar)

func loadNetworkData(data:Bins):
	data.loadStart()
	performing.loadNetworkData(data.readBins())
	receiving.loadNetworkData(data.readBins())
	data.endLoad()

func saveData() -> Dictionary:
	return {
		performing = performing.saveData(),
		receiving = receiving.saveData(),
	}

func loadData(_data:Dictionary):
	performing.loadData(SAVE.loadVar(_data, "performing", {}))
	receiving.loadData(SAVE.loadVar(_data, "receiving", {}))
