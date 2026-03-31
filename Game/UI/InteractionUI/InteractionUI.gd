extends Control

var pawn:CharacterPawn
var savedTrack:Dictionary[CharacterPawn, bool]
var tracked:Dictionary[CharacterPawn, Control]
@onready var character_list: VBoxContainer = %CharacterList
@onready var top_left_panel: PanelContainer = %TopLeftPanel

const INTERACTION_UI_CHARACTER := preload("res://Game/UI/InteractionUI/InteractionUICharacter.tscn")

func _ready() -> void:
	top_left_panel.visible = false
	top_left_panel.modulate = Color.TRANSPARENT

func _physics_process(_delta: float) -> void:
	var theNewPawn := GM.pcPawn
	if(theNewPawn != pawn):
		pawn = theNewPawn
	
	var toTrack:Dictionary[CharacterPawn, bool]
	if(pawn && pawn.interaction):
		var theInteraction := pawn.interaction
		for thePawn in theInteraction.pawnToRole:
			if(pawn == thePawn):
				continue
			toTrack[thePawn] = true
	
	setTrackedPawns(toTrack)
	if(toTrack.is_empty()):
		hideTopLeftPanel()
	else:
		showTopLeftPanel()
	
func setTrackedPawns(_chars:Dictionary[CharacterPawn, bool]):
	if(savedTrack == _chars):
		return
	savedTrack = _chars
	
	var toRemove:Array[CharacterPawn]
	for thePawn in tracked:
		if(_chars.has(thePawn)):
			continue
		toRemove.append(thePawn)
	for thePawn in toRemove:
		tracked[thePawn].queue_free()
		tracked.erase(thePawn)
	
	for thePawn in _chars:
		if(tracked.has(thePawn)):
			continue
		var newUIEntry:Control = INTERACTION_UI_CHARACTER.instantiate()
		character_list.add_child(newUIEntry)
		tracked[thePawn] = newUIEntry
		
		newUIEntry.setPawn(thePawn)

var isShowingLeftTopPanel:bool = false
var topLeftTween:Tween
func showTopLeftPanel():
	if(isShowingLeftTopPanel):
		return
	isShowingLeftTopPanel = true
	if(topLeftTween):
		topLeftTween.kill()
	top_left_panel.visible = true
	topLeftTween = create_tween()
	topLeftTween.tween_property(top_left_panel, "modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	
func hideTopLeftPanel():
	if(!isShowingLeftTopPanel):
		return
	isShowingLeftTopPanel = false
	if(topLeftTween):
		topLeftTween.kill()
	topLeftTween = create_tween()
	topLeftTween.tween_property(top_left_panel, "modulate", Color.TRANSPARENT, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	topLeftTween.tween_callback(func(): top_left_panel.visible = false)
