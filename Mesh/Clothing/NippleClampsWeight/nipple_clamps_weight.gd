extends DollPart

@onready var nipple_clamp_weight_l: Node3D = %NippleClampWeightL
@onready var nipple_clamp_weight_r: Node3D = %NippleClampWeightR

func applyPartFlags(_theFlags:Dictionary):
	if(_theFlags.has("HideNipples") && _theFlags["HideNipples"]):
		nipple_clamp_weight_l.visible = false
		nipple_clamp_weight_r.visible = false
	else:
		nipple_clamp_weight_l.visible = true
		nipple_clamp_weight_r.visible = true
