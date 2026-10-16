extends RefCounted
class_name ItemValue

func calcValueFor(_ctx:ItemValueContext) -> float:
	return 0.0

func calcValueForFinal(_value:float, _ctx:ItemValueContext) -> float:
	return _value

class BaseValue extends ItemValue:
	var value:float = 0.0
	func calcValueFor(_ctx:ItemValueContext) -> float:
		return value
static func baseValue(_v:float) -> BaseValue:
	var theV := BaseValue.new()
	theV.value = _v
	return theV

class PersonalityBasedValue extends ItemValue:
	var stat:String = PersonalityStat.Mean
	var mod:float = 1.0
	var onlyPositive:bool = false
	func calcValueFor(_ctx:ItemValueContext) -> float:
		var thePersValue:float = _ctx.target.personality.getStat(stat)
		var theValue:float = thePersValue*mod
		if(onlyPositive):
			theValue = maxf(theValue, 0.0)
		return theValue
static func personalityBased(_stat:String, _mod:float = 1.0, _onlyPositive:bool = false) -> PersonalityBasedValue:
	var theV := PersonalityBasedValue.new()
	theV.stat = _stat
	theV.mod = _mod
	theV.onlyPositive = _onlyPositive
	return theV

class ItemValueTagBased extends ItemValue:
	var tag:int
	var mod:float = 1.0
	func calcValueFor(_ctx:ItemValueContext) -> float:
		var _value:float = 0.0
		for theTrait:TraitBase in _ctx.target.traitHolder.getTraits():
			if(theTrait.itemTagValue.has(tag)):
				_value += theTrait.itemTagValue[tag]
		return _value*mod
static func itemValueTagBased(_tag:int, _mod:float = 1.0) -> ItemValueTagBased:
	var theV := ItemValueTagBased.new()
	theV.tag = _tag
	theV.mod = _mod
	return theV
