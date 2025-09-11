extends TextureVariantMany

func _init():
	idprefix = "PaintbrushTail_"
	type = TextureVariantType.TailPattern
	subType = "PaintbrushTail"
	
	textures = {
		"Felina": {
			name = "Felina",
			colormask = "res://Mesh/Parts/Tail/PaintbrushTail/Textures/Layers/Felina.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
		"TipLad": {
			name = "TipLad",
			colormask = "res://Mesh/Parts/Tail/PaintbrushTail/Textures/Layers/TipLad.png",
			flags = {
				hasR=true,
				hasG=true,
				hasB=true,
			},
		},
	}
