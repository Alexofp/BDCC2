extends RefCounted
class_name CharGenColorPalette

var skin:Color
var fur:ColorUtils.ColorTetra

var hair:Color
var hairBand:Color
var hairBow:Color
var hairMisc:Color

var eyeL:ColorUtils.ColorTriade
var eyeR:ColorUtils.ColorTriade

var fluff:Color
var snout:Color
var nails:Color
var claws:Color
var pawPads:Color
var flesh:Color
var privates:Color
var penis:Color

var tattoo:Color
var tattoo2:Color

const HETEROCHROMIA_CHANCE := 10.0

# generate(GenColorPaletteType.Realistic)
func generate(_type:int):
	if(_type == GenColorPaletteType.Realistic):
		generateRealistic()
	elif(_type == GenColorPaletteType.Pastel):
		generatePastel()
	elif(_type == GenColorPaletteType.OneColor):
		generateOneColor()
	elif(_type == GenColorPaletteType.Neon):
		generateNeon()
	else:
		assert(false, "Unknown color palette! type="+str(_type))

func generateRealistic():
	skin = ColorUtils.skinToneRandom()
	fur = ColorUtils.randomPatternRealisticAlt()
	#fur = ColorUtils.randomPatternRealistic()
	
	hair = ColorUtils.randomHairColorNatural()
	if(RNG.chance(25.0)):
		hair.h = fur.pick().h
	elif(RNG.chance(33.3)):
		hair.s = fur.pick().s
	elif(RNG.chance(50.0)):
		hair.v = fur.pick().v
	#hair.h = lerpf(hair.h, fur.pick().h, randf_range(0.0, 0.8))
	
	hairBand = ColorUtils.randomColor()
	hairBow = ColorUtils.randomColor()
	hairMisc = ColorUtils.randomColor()
	
	eyeL = ColorUtils.generateEyeColorPatternFromColor(ColorUtils.randomEyeColorRealistic())
	eyeR = eyeL if !RNG.chance(HETEROCHROMIA_CHANCE) else ColorUtils.generateEyeColorPatternFromColor(ColorUtils.randomEyeColorRealistic())
	
	fluff = ColorUtils.jitter(ColorUtils.shadow(RNG.pick([
		fur.color2, fur.color3, fur.color4,
	])))
	snout = RNG.pick([
		Color("1b1b1bff"),
		Color("262323ff"),
		Color("542b25ff"),
		Color("91413cff"),
	])
	nails = ColorUtils.jitter(skin, 1.0)
	claws = ColorUtils.jitter(fur.pick())
	pawPads = ColorUtils.jitter(RNG.pick([
		Color("212121ff"),
		Color("f77979ff"),
	]), 3.0)
	flesh = ColorUtils.jitter(Color("c95f5fff"))
	privates = ColorUtils.jitter(Color("f77979ff"))
	penis = privates
	
	tattoo = ColorUtils.randomVibrant()
	tattoo2 = ColorUtils.complementary(tattoo)

func generatePastel():
	skin = ColorUtils.skinToneRandom()
	fur = ColorUtils.randomPatternPastel()
	
	hair = ColorUtils.randomHairColorPastel()
	hairBand = ColorUtils.randomPastel()
	hairBow = ColorUtils.randomPastel()
	hairMisc = ColorUtils.randomPastel()
	
	eyeL = ColorUtils.generateEyeColorPatternFromColor(ColorUtils.randomEyeColorRealistic() if RNG.chance(50.0) else ColorUtils.randomVibrant())
	eyeR = eyeL if !RNG.chance(HETEROCHROMIA_CHANCE) else ColorUtils.generateEyeColorPatternFromColor(ColorUtils.randomEyeColorRealistic() if RNG.chance(50.0) else ColorUtils.randomVibrant())
	
	fluff = ColorUtils.jitter(ColorUtils.highlight(RNG.pick([
		fur.color2, fur.color3, fur.color4,
	])))
	snout = Color.from_ok_hsl(fur.pick().h, randf_range(0.5, 0.8), randf_range(0.2, 0.8))
	nails = ColorUtils.randomPastel()
	claws = ColorUtils.jitter(fur.pick())
	pawPads = ColorUtils.jitter(RNG.pick([
		#Color("212121ff"),
		#Color("f77979ff"),
		ColorUtils.randomPastel(),
	]), 3.0)
	flesh = ColorUtils.jitter(Color("c95f5fff"))
	privates = ColorUtils.jitter(Color("f77979ff"))
	penis = privates
	
	tattoo = ColorUtils.randomVibrant() if RNG.chance(20.0) else ColorUtils.randomPastel()
	tattoo2 = ColorUtils.complementary(tattoo)

func generateOneColor():
	var theMainColor := ColorUtils.randomVibrant()
	var theComplimentary := ColorUtils.complementary(theMainColor)
	
	skin = ColorUtils.skinToneRandom()
	#var theFurShadowMax:float = randf_range(0.4, 0.9)
	#fur = ColorUtils.ColorTetra.make(
		#ColorUtils.shadow(theMainColor, theFurShadowMax*0.25, 0.0),
		#ColorUtils.shadow(theMainColor, theFurShadowMax*0.5, 1.0),
		#ColorUtils.shadow(theMainColor, theFurShadowMax*0.75, 2.0),
		#ColorUtils.shadow(theMainColor, theFurShadowMax*1.0, 3.0),
	#)
	fur = ColorUtils.randomPatternOneColor(theMainColor)
	if(RNG.chance(30.0)):
		fur.shuffle()
	elif(RNG.chance(30.0)):
		fur.reverse()
	
	if(RNG.chance(90.0)):
		hair = ColorUtils.shadow(theMainColor, randf_range(0.1, 0.5), randf_range(0.0, 5.0))
	elif(RNG.chance(40.0)):
		hair = ColorUtils.randomVibrant()
	else:
		hair = ColorUtils.shadow(theComplimentary, randf_range(0.1, 0.5), randf_range(0.0, 5.0))
	
	if(RNG.chance(70.0)):
		hairBand = theMainColor
		hairBow = theMainColor
		hairMisc = theMainColor
	else:
		hairBand = theComplimentary
		hairBow = theComplimentary
		hairMisc = theComplimentary
	
	eyeL = ColorUtils.generateEyeColorPatternFromColor(theMainColor if RNG.chance(80.0) else theComplimentary)
	eyeR = eyeL# if !RNG.chance(HETEROCHROMIA_CHANCE) else ColorUtils.generateEyeColorPatternFromColor(ColorUtils.randomEyeColorRealistic() if RNG.chance(50.0) else ColorUtils.randomVibrant())
	
	fluff = ColorUtils.jitter(ColorUtils.highlight(theMainColor if RNG.chance(80.0) else theComplimentary))
	snout = RNG.pick([fur.darkest(), fur.pick()])#ColorUtils.shadow(theMainColor, 0.6, 1.0)
	nails = theMainColor
	claws = theMainColor
	pawPads = theMainColor
	flesh = ColorUtils.highlight(theMainColor)
	privates = (theMainColor) if RNG.chance(60.0) else (theComplimentary)
	#privates = ColorUtils.highlight(privates, randf_range(0.1, 0.4), randf_range(2.0, 10.0))
	privates = Color.from_ok_hsl(privates.h, 0.96, 0.7) if RNG.chance(50.0) else ColorUtils.highlight(privates, randf_range(0.1, 0.4), randf_range(2.0, 10.0))
	penis = privates
	
	tattoo = theMainColor
	tattoo2 = ColorUtils.complementary(tattoo)

func generateNeon():
	skin = ColorUtils.skinToneRandom()
	fur = ColorUtils.randomPatternNeon()
	var theMainColor := fur.color3
	var theComplimentary := fur.color4
	if(RNG.chance(50.0)):
		fur.color4 = fur.color3
	#var theHighlightColor := fur.color4
	#theHighlightColor.r *= 2.2
	#theHighlightColor.g *= 2.2
	#theHighlightColor.b *= 2.2
	#fur.color4 = theHighlightColor
	#if(RNG.chance(30.0)):
	#	fur.shuffle()
	#elif(RNG.chance(30.0)):
	#	fur.reverse()
	
	if(RNG.chance(90.0)):
		hair = ColorUtils.shadow(theMainColor, randf_range(0.1, 0.5), randf_range(0.0, 5.0))
	elif(RNG.chance(40.0)):
		hair = ColorUtils.randomVibrant()
	else:
		hair = ColorUtils.shadow(theComplimentary, randf_range(0.1, 0.5), randf_range(0.0, 5.0))
	
	hairBand = theMainColor
	hairBow = theMainColor
	hairMisc = theMainColor
	
	eyeL = ColorUtils.generateEyeColorPatternFromColor(theMainColor if RNG.chance(80.0) else theComplimentary)
	eyeR = eyeL# if !RNG.chance(HETEROCHROMIA_CHANCE) else ColorUtils.generateEyeColorPatternFromColor(ColorUtils.randomEyeColorRealistic() if RNG.chance(50.0) else ColorUtils.randomVibrant())
	
	fluff = ColorUtils.jitter(ColorUtils.highlight(theMainColor if RNG.chance(80.0) else theComplimentary))
	snout = Color.from_ok_hsl(theMainColor.h, randf_range(0.7, 0.9), randf_range(0.2, 0.4))
	nails = theMainColor
	claws = theMainColor
	pawPads = theMainColor
	flesh = ColorUtils.highlight(theMainColor)
	privates = ColorUtils.highlight(theMainColor)
	penis = privates
	
	tattoo = theMainColor
	tattoo2 = ColorUtils.complementary(tattoo)
