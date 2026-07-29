extends RefCounted
class_name CharGenColorPalette

var skin:Color
var fur:ColorUtils.ColorTetra

var hair:ColorUtils.ColorTriade
var hairBand:Color
var hairBow:Color
var hairMisc:Color

var eyeL:ColorUtils.ColorTriade
var eyeR:ColorUtils.ColorTriade

var fluff:Color

func generate():
	skin = ColorUtils.skinToneRandom()
	#fur = ColorUtils.randomPatternRealisticAlt()
	fur = ColorUtils.randomPatternRealistic()
	
	eyeL = ColorUtils.randomEyeColorPattern()
	eyeR = eyeL if RNG.chance(90.0) else ColorUtils.randomEyeColorPattern()
	
	hair = ColorUtils.randomHairColorPattern()
	hairBand = ColorUtils.randomColor()
	hairBow = ColorUtils.randomColor()
	hairMisc = ColorUtils.randomColor()
	
	fluff = ColorUtils.jitter(ColorUtils.highlight(RNG.pick([
		fur.color2, fur.color3, fur.color4,
	])))
