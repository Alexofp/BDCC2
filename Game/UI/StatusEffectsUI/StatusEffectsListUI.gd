extends HFlowContainer

const STATUS_EFFECT_LIST_ENTRY_UI = preload("res://Game/UI/StatusEffectsUI/StatusEffectListEntryUI.tscn")

var holder:StatusEffectsHolder

func setHolder(_effects:StatusEffectsHolder):
	if(holder):
		holder.onEffectsChanged.disconnect(onEffectsChange)
	holder = _effects
	holder.onEffectsChanged.connect(onEffectsChange)
	updateList()

func onEffectsChange():
	updateList()

func updateList():
	Util.delete_children(self)
	
	for theEffectID:String in holder.effects:
		var theEffect:StatusEffectBase = holder.effects[theEffectID]
		
		var newEntry := STATUS_EFFECT_LIST_ENTRY_UI.instantiate()
		add_child(newEntry)
		newEntry.setEffect(theEffect)
