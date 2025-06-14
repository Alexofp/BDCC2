extends RefCounted
class_name InteractionSystem

var interactions:Array[InteractionBase] = []

func startInteraction(_interactionID:String, _roles:Dictionary[String, CharacterPawn], _args:Array = []) -> InteractionBase:
	var theInteraction:InteractionBase = GlobalRegistry.createInteraction(_interactionID)
	if(!theInteraction):
		return null
	interactions.append(theInteraction)
	theInteraction.startFinal(_roles, _args)
	return theInteraction

func processInteractions(_dt:float):
	for interaction in interactions:
		interaction.processInteraction(_dt)

func removeInteraction(_interaction:InteractionBase):
	interactions.erase(_interaction)
