extends Object
class_name ColorUtils

class ColorSplit:
	var color1:Color
	var color2:Color
	static func make(_c1:Color, _c2:Color) -> ColorSplit:
		var theSplit:ColorSplit = ColorSplit.new()
		theSplit.color1 = _c1
		theSplit.color2 = _c2
		return theSplit

class ColorTriade:
	var color1:Color
	var color2:Color
	var color3:Color
	static func make(_c1:Color, _c2:Color, _c3:Color) -> ColorTriade:
		var theTriade:ColorTriade = ColorTriade.new()
		theTriade.color1 = _c1
		theTriade.color2 = _c2
		theTriade.color3 = _c3
		return theTriade

class ColorTetra:
	var color1:Color
	var color2:Color
	var color3:Color
	var color4:Color
	static func make(_c1:Color, _c2:Color, _c3:Color, _c4:Color) -> ColorTetra:
		var theTetra:ColorTetra = ColorTetra.new()
		theTetra.color1 = _c1
		theTetra.color2 = _c2
		theTetra.color3 = _c3
		theTetra.color4 = _c4
		return theTetra

static func luminance(c: Color) -> float:
	return c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722

static func perceivedBrightness(c: Color) -> float:
	return sqrt(
		c.r * c.r * 0.299 +
		c.g * c.g * 0.587 +
		c.b * c.b * 0.114
	)

static func isDark(c: Color) -> bool:
	return luminance(c) < 0.5

static func isLight(c: Color) -> bool:
	return !isDark(c)

static func grayscale(c: Color) -> Color:
	var l := luminance(c)
	return Color(l, l, l, c.a)

static func withAlpha(c: Color, alpha: float) -> Color:
	var out := c
	out.a = clampf(alpha, 0.0, 1.0)
	return out

# COMPLIMENTARY STUFF

## 180 degree hue shift
static func complementary(color: Color, _shift:float = 0.0) -> Color:
	return Color.from_hsv(color.h + 0.5 + _shift, color.s, color.v)

## +- 30 degree hue shift
static func splitComplementary(color: Color) -> ColorSplit:
	var base_h := color.h
	var comp_h := base_h + 0.5
	var angle := 1.0 / 12.0   # 30°
	var h1 := comp_h + angle
	var h2 := comp_h - angle
	
	return ColorSplit.make(
		Color.from_hsv(h1, color.s, color.v),
		Color.from_hsv(h2, color.s, color.v),
	)

## +- 120 degree hue shift
static func splitTriadic(color: Color) -> ColorSplit:
	var h := color.h
	var h1 := h + 1.0 / 3.0
	var h2 := h - 1.0 / 3.0
	return ColorSplit.make(
		Color.from_hsv(h1, color.s, color.v),
		Color.from_hsv(h2, color.s, color.v)
	)

## 90 degree increments
static func splitTetradic(color: Color) -> ColorTriade:
	var h := color.h
	var h1 := h + 0.25
	var h2 := h + 0.5
	var h3 := h + 0.75
	return ColorTriade.make(
		Color.from_hsv(h1, color.s, color.v),
		Color.from_hsv(h2, color.s, color.v),
		Color.from_hsv(h3, color.s, color.v)
	)

## Returns two analogous colors at +-angle_deg from the original
static func analogous(color: Color, angle_deg: float = 30.0) -> ColorSplit:
	var angle := angle_deg / 360.0
	var h := color.h
	var h1 := h + angle
	var h2 := h - angle
	return ColorSplit.make(
		Color.from_hsv(h1, color.s, color.v),
		Color.from_hsv(h2, color.s, color.v)
	)

## Returns an array of monochromatic colors (varying saturation and value)
static func monochromatic(color: Color, num_steps: int = 5) -> Array[Color]:
	var colors:Array[Color] = []
	for i in num_steps:
		var t := float(i) / float(num_steps - 1)
		# Vary saturation and value. s goes from high to low, v from medium to high
		var s := color.s * (1.0 - t * 0.7)
		var v := color.v * (0.6 + t * 0.4)
		colors.append(Color.from_hsv(color.h, s, v))
	return colors

# COMPLIMENTARY STUFF END

static func shadow(color: Color, amount: float = 0.2, hue_shift_deg: float = 5.0) -> Color:
	var h := color.h - (hue_shift_deg / 360.0)
	var s := color.s
	var v := maxf(color.v - amount, 0.0)
	return Color.from_hsv(h, s, v)

static func highlight(color: Color, amount: float = 0.2, hue_shift_deg: float = 5.0) -> Color:
	var h := color.h + (hue_shift_deg / 360.0)
	var s := color.s
	var v := minf(color.v + amount, 1.0)
	return Color.from_hsv(h, s, v)

## mix with white.
static func tint(color: Color, amount: float = 0.5) -> Color:
	return color.lerp(Color.WHITE, amount)

## mix with black.
static func shade(color: Color, amount: float = 0.5) -> Color:
	return color.lerp(Color.BLACK, amount)

## mix with gray (50% gray).
static func tone(color: Color, amount: float = 0.5) -> Color:
	return color.lerp(Color(0.5, 0.5, 0.5), amount)

## amount > 1 increases, <1 decreases
static func adjustContrast(color: Color, amount: float = 1.2) -> Color:
	var r := (color.r - 0.5) * amount + 0.5
	var g := (color.g - 0.5) * amount + 0.5
	var b := (color.b - 0.5) * amount + 0.5
	return Color(clampf(r, 0.0, 1.0), clampf(g, 0.0, 1.0), clampf(b, 0.0, 1.0), color.a)


static func jitter(
	c: Color,
	hue := 5.0,
	saturation := 0.05,
	value := 0.05,
) -> Color:
	var h := randf_range(-hue, hue)
	var s := randf_range(-saturation, saturation)
	var v := randf_range(-value, value)
	return Color.from_hsv(
		c.h + h / 360.0,
		clampf(c.s + s, 0.0, 1.0),
		clampf(c.v + v, 0.0, 1.0),
		c.a,
	)

static func skinToneSimple(variation: float = 0.5) -> Color:
	if variation < 0.001:
		return Color.from_hsv(0.05, 0.4, 0.7)
	var range_h := 0.06 * variation
	var range_s := 0.4 * variation
	var range_v := 0.4 * variation
	var h_offset := (randf() - 0.5) * range_h
	var s_offset := (randf() - 0.5) * range_s
	var v_offset := (randf() - 0.5) * range_v
	var final_h := clampf(0.05 + h_offset, 0.02, 0.08)
	var final_s := clampf(0.4 + s_offset, 0.2, 0.6)
	var final_v := clampf(0.7 + v_offset, 0.5, 0.9)
	return Color.from_hsv(final_h, final_s, final_v)

static func mix(a: Color, b: Color, t: float) -> Color:
	return a.lerp(b, clampf(t, 0.0, 1.0))

static func skinTone(
	melanin := 0.5,
	warmth := 0.5,
	blush := 0.15,
	tann := 0.0
) -> Color:

	melanin = clampf(melanin, 0.0, 1.0)
	warmth = clampf(warmth, 0.0, 1.0)
	blush = clampf(blush, 0.0, 1.0)
	tann = clampf(tann, 0.0, 1.0)

	var lightness := lerpf(
		0.82,
		0.32,
		melanin
	)

	lightness -= tann * 0.12

	var saturation := lerpf(
		0.18,
		0.45,
		melanin
	)

	var hue := lerpf(
		0.075,
		0.035,
		melanin
	)

	hue += lerpf(
		-0.015,
		0.025,
		warmth
	)

	var color := Color.from_ok_hsl(
		hue,
		saturation,
		lightness
	)

	# subtle blood warmth
	color = mix(
		color,
		Color(1.0, 0.35, 0.30),
		blush * 0.12
	)

	return color

static func skinPale() -> Color:
	return skinTone(0.05, 0.45)

static func skinFair() -> Color:
	return skinTone(0.20, 0.50)

static func skinTan() -> Color:
	return skinTone(0.45, 0.60, 0.12, 0.5)

static func skinBrown() -> Color:
	return skinTone(0.70, 0.55)

static func skinDark() -> Color:
	return skinTone(0.90, 0.45)

static func skinToneRandom() -> Color:
	var theRnd:float = randf()
	
	if(theRnd <= 0.2):
		return skinPale()
	if(theRnd <= 0.4):
		return skinFair()
	if(theRnd <= 0.6):
		return skinTan()
	if(theRnd <= 0.8):
		return skinBrown()
	return skinDark()

const FUR_COLORS_REALISTIC:Array[Color] = [
	Color("5B0C0C"),
	Color("914214"),
	Color("f08f6eff"),
	Color("A03B3B"),
	Color("7C3A0E"),
	Color("bf5c32ff"),
	Color("a65c1cff"),
	Color("A56B38"),
	Color("D39E70"),
	Color("F2C46F"),
	Color("A37A47"),
	Color("8E7C79"),
	Color("403432ff"),
	Color("d9d2ceff"),
]

const HAIR_COLORS_NATURAL:Array[Color] = [
	Color("471900"),
	Color("7b3e1d"),
	Color("db1c1c"),
	Color("ae552e"),
	Color("db7a1c"),
	Color("e5c18e"),
]

static func randomFurColor() -> Color:
	return RNG.pick(FUR_COLORS_REALISTIC)

static func randomFurColorBright() -> Color:
	return Color.from_hsv(
		randf_range(0.0, 0.12),
		randf_range(0.3, 0.7),
		randf_range(0.7, 0.9)
	)

static func randomColor() -> Color:
	return Color(randf(), randf(), randf())

static func randomPastel() -> Color:
	return Color.from_hsv(randf(), randf() * 0.3 + 0.1, randf() * 0.3 + 0.7)

static func randomVibrant() -> Color:
	return Color.from_hsv(randf(), randf() * 0.3 + 0.7, randf() * 0.3 + 0.7)


# PATTERNS OF COLORS

static func randomPattern() -> ColorTetra:
	return randomPatternRealisticAlt()

static func randomPatternRealistic() -> ColorTetra:
	var primary := randomFurColor()
	var secondary := randomFurColor() if RNG.chance(50) else shadow(primary, randf() * 0.3 + 0.1)
	
	var accent := Color.BLACK#complementary(primary)
	if(RNG.chance(30.0)):
		accent = shadow(primary)
	elif(RNG.chance(50.0)):
		accent = highlight(primary)
	else:
		accent = Color.from_hsv(primary.h + (randf() - 0.5) * 0.1, primary.s * 0.6, primary.v * 0.8)
	var lastColor := shadow(accent)
	
	if secondary.is_equal_approx(primary):
		secondary = shade(primary, 0.3)
	if accent.is_equal_approx(primary) or accent.is_equal_approx(secondary):
		accent = complementary(primary)
	if lastColor.is_equal_approx(primary) or lastColor.is_equal_approx(secondary) or lastColor.is_equal_approx(accent):
		lastColor = shadow(primary)
	
	primary = jitter(primary)
	secondary = jitter(secondary)
	accent = jitter(accent)
	lastColor = jitter(lastColor)
	return ColorTetra.make(primary, secondary, accent, lastColor)

static func randomPatternRealisticAlt() -> ColorTetra:
	var primary := randomFurColorBright()
	var secondary := Color.from_hsv(
		primary.h - randf_range(0.01, 0.03),
		primary.s + randf_range(0.01, 0.03),
		primary.v * randf_range(0.6, 0.8),
	)
	var accent := Color.from_hsv(
		primary.h - randf_range(0.02, 0.05),
		primary.s + randf_range(-0.05, 0.05),
		primary.v * randf_range(0.4, 0.6),
	)
	var lastColor := Color.from_hsv(
		primary.h - randf_range(0.03, 0.06),
		primary.s + randf_range(-0.07, 0.07),
		primary.v * randf_range(0.2, 0.5),
	)
	return ColorTetra.make(primary, secondary, accent, lastColor)

static func randomEyeColorPattern() -> ColorTriade:
	var mainColor := randomVibrant()
	return ColorTriade.make(
		mainColor,
		jitter(mainColor),
		Color.WHITE,
	)

static func randomHairColorPattern() -> ColorTriade:
	var mainColor:Color = RNG.pick(HAIR_COLORS_NATURAL)#randomVibrant() if RNG.chance(50.0) else randomPastel()
	mainColor = jitter(mainColor)
	return ColorTriade.make(
		mainColor,
		jitter(mainColor),
		jitter(mainColor),
	)
