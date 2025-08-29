extends Control

func _ready() -> void:
	OPTIONS.graphics.onSettingChange.connect(onGraphicsSettingChange)
	updateShouldShow()

func updateShouldShow():
	var isEnabled:bool = (OPTIONS.graphics.getSettingValue("glow") == GraphicsSettings.GLOW.ANAMORPHIC)
	visible = isEnabled

func onGraphicsSettingChange(_setting:String, _value:Variant):
	updateShouldShow()
