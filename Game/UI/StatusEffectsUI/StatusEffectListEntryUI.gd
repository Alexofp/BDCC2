extends TextureRect

@onready var effect_icon: TextureRect = %EffectIcon
@onready var time_label: Label = %TimeLabel

var effect:StatusEffectBase

func setEffect(_effect:StatusEffectBase):
	effect = _effect
	fullUpdate()

func fullUpdate():
	if(!effect):
		return
	effect_icon.texture = effect.getIcon()
	effect_icon.self_modulate = effect.getIconColor()
	self_modulate = effect.getIconBackgroundColor()
	time_label.visible = effect.isTimed()
	fastUpdate()

func fastUpdate():
	if(!effect):
		return
	
	if(effect.timed):
		time_label.text = effect.getTimeStringForUI()

func _physics_process(_delta: float) -> void:
	fastUpdate()

func _on_mouse_entered() -> void:
	if(!effect):
		return
	TooltipSystem.showTooltip(self, effect.getName(), effect.getDescriptionForStatusEffect())

func _on_mouse_exited() -> void:
	TooltipSystem.hideTooltip(self)
