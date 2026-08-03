extends Object
class_name GenColorPaletteType

const Realistic := 0
const OneColor := 1
const Pastel := 2
const Neon := 3

static func getRandom() -> int:
	return RNG.pick([
		Realistic,
		OneColor,
		Pastel,
		Neon,
	])

static func getAllWithNames() -> Array[Array]:
	return [
		[Realistic, "Realistic"],
		[OneColor, "One-color"],
		[Pastel, "Pastel"],
		[Neon, "Neon"],
	]
