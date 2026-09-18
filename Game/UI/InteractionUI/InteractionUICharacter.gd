extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var affection_bar: PanelContainer = %AffectionBar
@onready var exhaustion: PanelContainer = %Exhaustion
@onready var mood_label: Label = %MoodLabel
@onready var lust_bar: PanelContainer = %LustBar
@onready var power_balance_bar: PanelContainer = %PowerBalanceBar

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
	
	var theAffectionValue:float = GM.main.relationshipSystem.getAffection(thePCPawn.getCharID(), pawn.getCharID())
	affection_bar.setValue(theAffectionValue)
	affection_bar.setRightText(str(Util.roundF(theAffectionValue*100.0, 1))+"%")
	
	var theLustValue:float = GM.main.relationshipSystem.getLust(thePCPawn.getCharID(), pawn.getCharID())
	lust_bar.setValue(theLustValue)
	lust_bar.setRightText(str(Util.roundF(theLustValue*100.0, 1))+"%")
	
	var thePowerBalance:float = GM.main.relationshipSystem.getPowerBalance(thePCPawn.getCharID(), pawn.getCharID())
	power_balance_bar.setValue(thePowerBalance)
	power_balance_bar.setRightText(str(Util.roundF(thePowerBalance*100.0, 1))+"%")
	
	exhaustion.setValue(pawn.getSocialExhaustion())
	
	mood_label.text = pawn.mood.getMoodName()
