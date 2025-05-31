extends Object
class_name PronounType

enum {
	HeShe,
	HisHer,
	HimHer,
	HasS,
	HimselfHerself,
}

static func getAll() -> Array:
	return [HeShe, HisHer, HimHer, HasS, HimselfHerself]
