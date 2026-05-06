extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var affection_bar: PanelContainer = %AffectionBar
@onready var exhaustion: PanelContainer = %Exhaustion
@onready var mood_label: Label = %MoodLabel

var pawn:CharacterPawn
const GRADIENT_AFFECTION_GOOD := preload("res://Game/UI/InteractionUI/GradientAffectionGood.tres")
const GRADIENT_AFFECTION_BAD := preload("res://Game/UI/InteractionUI/GradientAffectionBad.tres")

func setPawn(_p:CharacterPawn):
	pawn = _p
	if(pawn):
		var theCharacter := pawn.getCharacter()
		if(theCharacter):
			name_label.text = theCharacter.getName()
	affection_bar.setRightText("")
	exhaustion.setRightText("")

func _physics_process(_delta: float) -> void:
	if(!pawn || !is_instance_valid(pawn)):
		return
	var thePCPawn:CharacterPawn = GM.pcPawn
	if(!thePCPawn):
		return
	
	var theAffectionValueRaw:float = GM.main.relationshipSystem.getAffection(thePCPawn.getCharID(), pawn.getCharID())
	var theAffectionValue:float = RelationshipSystem.affectionToVisualAffection(theAffectionValueRaw)
	if(theAffectionValue >= 0.0):
		affection_bar.gradient = GRADIENT_AFFECTION_GOOD
		affection_bar.setValue(theAffectionValue)
	else:
		affection_bar.gradient = GRADIENT_AFFECTION_BAD
		affection_bar.setValue(-theAffectionValue)
	affection_bar.setRightText(str(Util.roundF(theAffectionValueRaw*100.0, 1))+"%")
	
	exhaustion.setValue(pawn.getSocialExhaustion())
	
	mood_label.text = pawn.mood.getMoodName()
