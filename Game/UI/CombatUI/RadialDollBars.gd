extends Node3D

var character:BaseCharacter
var pawn:CharacterPawn

@onready var pain_bar: MeshInstance3D = %PainBar

var shouldBarsBeVisible := false
var keepUITimer:float = 0.0

func _ready() -> void:
	fadeOut(true)

func setCharacter(_char:BaseCharacter):
	character = _char
	pawn = GM.pawnRegistry.getPawn(character.getID()) if character else null

func setDoll(_doll:DollController):
	setCharacter(_doll.getCharacter() if _doll else null)
const GRADIENT_PAIN = preload("res://Game/UI/CombatUI/GradientPain.tres")

func _physics_process(_delta: float) -> void:
	if(!character || !is_instance_valid(character) || !pawn):
		visible = false
		return
	if(pawn.isControlledByUs()):
		visible = false
		return
	visible = true
	
	#pain_bar.pushValueTowards(character.charState.getPainLevel())

	var shouldShowCombatUI:bool = pawn.state.shouldShowCombatUI()
	#if(menuToConnectTo && menuToConnectTo.is_visible_in_tree()):
	#	shouldShowCombatUI = true
	if(pain_bar.pushValueTowards(character.charState.getPainLevel())):
		shouldShowCombatUI = true
		pain_bar.colorMain = GRADIENT_PAIN.sample(pain_bar.progress)
	
	if(shouldShowCombatUI):
		fadeIn()
		keepUITimer = 3.0
	else:
		if(keepUITimer > 0.0):
			keepUITimer -= _delta
		else:
			fadeOut()
	
	#pain_bar.setRightText(str(int(ceil(thePain*100.0)))+"/100")

#var fadeTween:Tween
func fadeIn(_force:bool = false):
	if(!shouldBarsBeVisible):
		return
	shouldBarsBeVisible = false
	
	pain_bar.fadeIn(_force)
	#if(fadeTween):
	#	fadeTween.kill()
	#fadeTween = create_tween()
	#fadeTween.tween_property(pain_bar, "modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func fadeOut(_force:bool = false):
	if(shouldBarsBeVisible):
		return
	shouldBarsBeVisible = true
	
	pain_bar.fadeOut(_force)
	#if(fadeTween):
	#	fadeTween.kill()
	#fadeTween = create_tween()
	#fadeTween.tween_property(self, "modulate", Color.TRANSPARENT, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
