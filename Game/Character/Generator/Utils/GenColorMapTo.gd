extends Object
class_name GenColorMapTo

const FUR_COLOR1 := 0
const FUR_COLOR2 := 1
const FUR_COLOR3 := 2
const FUR_COLOR4 := 3
const FUR_COLOR_PICK := 4

const RANDOM_COLOR := 5
const RANDOM_COLOR_DARK := 6
const RANDOM_COLOR_PASTEL := 7
const RANDOM_COLOR_VIBRANT := 8

const TATTOO_COLOR1 := 9
const TATTOO_COLOR2 := 10

const FLESH_COLOR := 11

const EYE_COLOR1 := 12
const EYE_COLOR2 := 13
const EYE_COLOR3 := 14

const COLOR_BLACK := 15

const NIPPLE_COLOR := 16
const NIPPLE_COLOR_DARK := 17
const NIPPLE_COLOR_HIGHLIGHT := 18

const HAIR_PATTERN_COLOR1 := 19
const HAIR_PATTERN_COLOR2 := 20
const HAIR_PATTERN_COLOR3 := 21

static func getColor(_mapTo:int, _gen:CharacterGenerator, _isRight:bool = false) -> Color:
	if(_mapTo == FUR_COLOR1):
		return _gen.colors.fur.color1
	if(_mapTo == FUR_COLOR2):
		return _gen.colors.fur.color2
	if(_mapTo == FUR_COLOR3):
		return _gen.colors.fur.color3
	if(_mapTo == FUR_COLOR4):
		return _gen.colors.fur.color4
	if(_mapTo == RANDOM_COLOR):
		return ColorUtils.randomColor()
	if(_mapTo == RANDOM_COLOR_DARK):
		return ColorUtils.shadow(ColorUtils.randomColor())
	if(_mapTo == RANDOM_COLOR_PASTEL):
		return ColorUtils.randomPastel()
	if(_mapTo == RANDOM_COLOR_VIBRANT):
		return ColorUtils.randomVibrant()
	if(_mapTo == TATTOO_COLOR1):
		return _gen.colors.tattoo
	if(_mapTo == TATTOO_COLOR2):
		return _gen.colors.tattoo2
	if(_mapTo == FUR_COLOR_PICK):
		return _gen.colors.fur.pick()
	if(_mapTo == FLESH_COLOR):
		return _gen.colors.flesh
	if(_mapTo == EYE_COLOR1):
		if(_isRight):
			return _gen.colors.eyeR.color1
		return _gen.colors.eyeL.color1
	if(_mapTo == EYE_COLOR2):
		if(_isRight):
			return _gen.colors.eyeR.color2
		return _gen.colors.eyeL.color2
	if(_mapTo == EYE_COLOR3):
		if(_isRight):
			return _gen.colors.eyeR.color3
		return _gen.colors.eyeL.color3
	if(_mapTo == COLOR_BLACK):
		return Color.BLACK
	if(_mapTo == NIPPLE_COLOR):
		return _gen.colors.privates
	if(_mapTo == NIPPLE_COLOR_DARK):
		return ColorUtils.shadow(_gen.colors.privates)
	if(_mapTo == NIPPLE_COLOR_HIGHLIGHT):
		return ColorUtils.highlight(_gen.colors.privates)
	if(_mapTo == HAIR_PATTERN_COLOR1):
		return _gen.colors.hairPattern.color1
	if(_mapTo == HAIR_PATTERN_COLOR2):
		return _gen.colors.hairPattern.color2
	if(_mapTo == HAIR_PATTERN_COLOR3):
		return _gen.colors.hairPattern.color3
	
	Log.Printerr("Unknown GenColorMapTo value: "+str(_mapTo))
	return Color.DEEP_PINK
