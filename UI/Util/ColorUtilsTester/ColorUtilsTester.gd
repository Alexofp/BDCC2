extends Control

@onready var color_picker_button: ColorPickerButton = %ColorPickerButton
@onready var color_picker_button_2: ColorPickerButton = %ColorPickerButton2
@onready var color_picker_button_3: ColorPickerButton = %ColorPickerButton3
@onready var color_picker_button_6: ColorPickerButton = %ColorPickerButton6

func setPattern(thePattern:ColorUtils.ColorTetra):
	color_picker_button.color = thePattern.color1
	color_picker_button_2.color = thePattern.color2
	color_picker_button_3.color = thePattern.color3
	color_picker_button_6.color = thePattern.color4

func _on_realistic_button_pressed() -> void:
	setPattern(ColorUtils.randomPatternRealistic())

@onready var color_picker_button_4: ColorPickerButton = %ColorPickerButton4

func _on_skin_pale_button_pressed() -> void:
	color_picker_button_4.color = ColorUtils.skinPale()

func _on_skin_fair_button_pressed() -> void:
	color_picker_button_4.color = ColorUtils.skinFair()

func _on_skin_tan_button_pressed() -> void:
	color_picker_button_4.color = ColorUtils.skinTan()

func _on_skin_brown_button_pressed() -> void:
	color_picker_button_4.color = ColorUtils.skinBrown()

func _on_skin_dark_button_pressed() -> void:
	color_picker_button_4.color = ColorUtils.skinDark()

func _on_skin_random_button_pressed() -> void:
	color_picker_button_4.color = ColorUtils.skinToneRandom()

func _on_skin_simple_button_pressed() -> void:
	color_picker_button_4.color = ColorUtils.skinToneSimple(1.0)

func _on_realistic_alt_button_pressed() -> void:
	setPattern(ColorUtils.randomPatternRealisticAlt())

@onready var color_picker_button_5: ColorPickerButton = %ColorPickerButton5

func _on_random_color_button_pressed() -> void:
	color_picker_button_5.color = ColorUtils.randomColor()

func _on_pastel_color_button_pressed() -> void:
	color_picker_button_5.color = ColorUtils.randomPastel()

func _on_vibrant_color_button_pressed() -> void:
	color_picker_button_5.color = ColorUtils.randomVibrant()
