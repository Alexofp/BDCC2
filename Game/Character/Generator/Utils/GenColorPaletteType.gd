extends Object
class_name GenColorPaletteType

const Realistic := 0
const OneColor := 1
const Warm := 2
const Pastel := 3
const Neon := 4

static func getRandom() -> int:
	return RNG.pick([
		Realistic,
		OneColor,
		#Warm,
		Pastel,
		Neon,
	])

static func getAllWithNames() -> Array[Array]:
	return [
		[Realistic, "Realistic"],
		[OneColor, "One-color"],
		[Pastel, "Pastel"],
		#[Warm, "Warm"],
		[Neon, "Neon"],
	]
