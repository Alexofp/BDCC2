extends Control
class_name CombatUI

@export var menuToConnectTo:Control

@onready var stats_bars: VBoxContainer = %StatsBars
@onready var pain_bar: PanelContainer = %PainBar

var shouldBarsBeVisible := false
var keepUITimer:float = 0.0

func _physics_process(_delta: float) -> void:
	var currentPawn := GM.pcPawn
	
	if(!currentPawn):
		visible = false
		return
	visible = true
	
	var theChar := currentPawn.getCharacter()
	var thePain := theChar.getCharState().getPainLevel()
	
	var shouldShowCombatUI:bool = currentPawn.state.shouldShowCombatUI()
	if(menuToConnectTo && menuToConnectTo.is_visible_in_tree()):
		shouldShowCombatUI = true
	if(pain_bar.setValue(thePain)):
		shouldShowCombatUI = true
	
	if(shouldShowCombatUI):
		fadeIn()
		keepUITimer = 3.0
	else:
		if(keepUITimer > 0.0):
			keepUITimer -= _delta
		else:
			fadeOut()
	
	pain_bar.setRightText(str(int(ceil(thePain*100.0)))+"/100")

var fadeTween:Tween
func fadeIn():
	if(!shouldBarsBeVisible):
		return
	shouldBarsBeVisible = false

	if(fadeTween):
		fadeTween.kill()
	fadeTween = create_tween()
	fadeTween.tween_property(stats_bars, "modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func fadeOut():
	if(shouldBarsBeVisible):
		return
	shouldBarsBeVisible = true
	
	if(fadeTween):
		fadeTween.kill()
	fadeTween = create_tween()
	fadeTween.tween_property(stats_bars, "modulate", Color.TRANSPARENT, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
