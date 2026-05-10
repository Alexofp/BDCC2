extends Control

@onready var texture_rect: TextureRect = $TextureRect
@onready var my_layered_texture_new: MyLayeredTextureNew = $MyLayeredTextureNew

func _ready() -> void:
	my_layered_texture_new.addColorMaskLayer(
		"res://Mesh/Parts/SharedTextures/HairPatterns/SideHair/BigStrands.png", Color.AQUA, Color.CORAL, Color.DEEP_PINK,
	)
	my_layered_texture_new.addSimpleLayerAt(
		"res://icon.svg",
		Color.RED, Vector2(0.1, 0.1), Vector2(0.2, 0.2),
	)
	my_layered_texture_new.addSimpleLayerAt(
		"res://icon.svg",
		Color.RED, Vector2(0.3, 0.1), Vector2(0.2, 0.2),
	)

func _on_my_layered_texture_new_on_texture_updated(newTexture: DrawableTexture2D) -> void:
	texture_rect.texture = newTexture

func _on_clear_button_pressed() -> void:
	my_layered_texture_new.clearLayers()
