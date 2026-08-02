extends Object
class_name GenColorMapTo

const FUR_COLOR1 := 0
const FUR_COLOR2 := 1
const FUR_COLOR3 := 2
const FUR_COLOR4 := 3
const FUR_COLOR_PICK := 10

const RANDOM_COLOR := 4
const RANDOM_COLOR_DARK := 5
const RANDOM_COLOR_PASTEL := 6
const RANDOM_COLOR_VIBRANT := 7

const TATTOO_COLOR1 := 8
const TATTOO_COLOR2 := 9

const FLESH_COLOR := 11

static func getColor(_mapTo:int, _gen:CharacterGenerator) -> Color:
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
	
	Log.Printerr("Unknown GenColorMapTo value: "+str(_mapTo))
	return Color.DEEP_PINK
