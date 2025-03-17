extends SettingsBase
class_name GraphicsSettings

enum FULLSCREEN {
	DISABLED,
	BORDERLESS,
	EXCLUSIVE,
}
var fullscreen:int

enum RENDERSCALE {
	SCALE100,
	SCALE90,
	SCALE75,
	SCALE60,
	SCALE50,
	SCALE33,
	SCALE25,
	SCALE20,
	SCALE10,
}
var renderScale:int

enum UPSCALER {
	BILINEAR,
	FSR1,
	FSR2,
}
var upscaler:int

enum FPSCAP {
	VSYNC,
	VSYNCFAST,
	FPS24,
	FPS25,
	FPS30,
	FPS45,
	FPS60,
	FPS75,
	FPS90,
	FPS100,
	FPS120,
	FPS144,
	FPS165,
	FPS180,
	FPS240,
	FPS300,
	UNCAPPED,
}
var fpsCap:int

enum TEXTURESCHARACTERS {
	MAX,
	MEDIUM,
	LOW,
}
var texturesChar:int

enum SSAO {
	DISABLED,
	ENABLED,
	ENABLED_SSIL,
}
var ssao:int

enum GI {
	DISABLED,
	REDUCED,
	ENABLED,
}
var gi:int

enum AA {
	DISABLED,
	AAX2,
	AAX4,
	AAX8,
}
var aa:int

enum SSAA {
	DISABLED,
	FXAA,
	SMAA,
}
var ssaa:int

enum GLOW {
	DISABLED,
	ENABLED,
}
var glow:int

enum FOG {
	DISABLED,
	SIMPLE,
	VOLUMETRIC,
}
var fog:int

func getSettings() -> Dictionary:
	return {
		"fullscreen": {
			name = "Fullscreen",
			type = "selector",
			values = [
				[FULLSCREEN.DISABLED, "Windowed"],
				[FULLSCREEN.BORDERLESS, "Borderless Fullscreen"],
				[FULLSCREEN.EXCLUSIVE, "Exclusive Fullscreen"],
			],
			default = FULLSCREEN.DISABLED,
		},
		"renderScale": {
			name = "Rendering scale",
			type = "selector",
			values = [
				[RENDERSCALE.SCALE100, "100%"],
				[RENDERSCALE.SCALE90, "90%"],
				[RENDERSCALE.SCALE75, "75%"],
				[RENDERSCALE.SCALE60, "60%"],
				[RENDERSCALE.SCALE50, "50%"],
				[RENDERSCALE.SCALE33, "33%"],
				[RENDERSCALE.SCALE25, "25%"],
				[RENDERSCALE.SCALE20, "20%"],
				[RENDERSCALE.SCALE10, "10%"],
			],
			default = RENDERSCALE.SCALE100,
		},
		"upscaler": {
			name = "Upscaling Method",
			type = "selector",
			values = [
				[UPSCALER.BILINEAR, "Bilinear (Fastest)"],
				[UPSCALER.FSR1, "FSR 1.0 (Fast)"],
				[UPSCALER.FSR2, "FSR 2.2 (Slow)"],
			],
			default = UPSCALER.BILINEAR,
		},
		"fpsCap": {
			name = "FPS Cap",
			type = "selector",
			values = [
				[FPSCAP.VSYNC, "V-Sync"],
				[FPSCAP.VSYNCFAST, "V-Sync Uncapped"],
				[FPSCAP.FPS24, "24 FPS"],
				[FPSCAP.FPS25, "25 FPS"],
				[FPSCAP.FPS30, "30 FPS"],
				[FPSCAP.FPS45, "45 FPS"],
				[FPSCAP.FPS60, "60 FPS"],
				[FPSCAP.FPS75, "75 FPS"],
				[FPSCAP.FPS90, "90 FPS"],
				[FPSCAP.FPS100, "100 FPS"],
				[FPSCAP.FPS120, "120 FPS"],
				[FPSCAP.FPS144, "144 FPS"],
				[FPSCAP.FPS165, "165 FPS"],
				[FPSCAP.FPS180, "180 FPS"],
				[FPSCAP.FPS240, "240 FPS"],
				[FPSCAP.FPS300, "300 FPS"],
				[FPSCAP.UNCAPPED, "Uncapped"],
			],
			default = FPSCAP.FPS60,
			addSeparator = true,
		},
		"texturesChar": {
			name = "Character textures",
			type = "selector",
			values = [
				[TEXTURESCHARACTERS.MAX, "Max"],
				[TEXTURESCHARACTERS.MEDIUM, "Medium"],
				[TEXTURESCHARACTERS.LOW, "Low"],
			],
			default = TEXTURESCHARACTERS.MAX,
			addSeparator = true,
		},
		"ssaa": {
			name = "Screen-Space Anti-Aliasing",
			type = "selector",
			values = [
				[SSAA.DISABLED, "Disabled (Fastest)"],
				[SSAA.FXAA, "FXAA (Fast)"],
				[SSAA.SMAA, "SMAA (Fast)"],
			],
			default = SSAA.SMAA,
		},
		"aa": {
			name = "Anti-Aliasing",
			type = "selector",
			values = [
				[AA.DISABLED, "Disabled (Fastest)"],
				[AA.AAX2, "MSAA 2x (Average)"],
				[AA.AAX4, "MSAA 4x (Slow)"],
				[AA.AAX8, "MSAA 8x (Very Slow)"],
			],
			default = AA.DISABLED,
			addSeparator = true,
		},
		"ssao": {
			name = "SSAO",
			type = "selector",
			values = [
				[SSAO.DISABLED, "Disabled (Fast)"],
				[SSAO.ENABLED, "Enabled (Average)"],
				[SSAO.ENABLED_SSIL, "SSAO+SSIL (Slow)"],
			],
			default = SSAO.ENABLED,
		},
		"glow": {
			name = "Glow",
			type = "selector",
			values = [
				[GLOW.DISABLED, "Disabled (Fast)"],
				[GLOW.ENABLED, "Enabled (Average)"],
			],
			default = GLOW.ENABLED,
		},
		"gi": {
			name = "Global Illumination",
			type = "selector",
			values = [
				[GI.DISABLED, "Disabled (Fast)"],
				[GI.REDUCED, "Reduced (Slow)"],
				[GI.ENABLED, "Enabled (Very Slow)"],
			],
			default = GI.REDUCED,
		},
		"fog": {
			name = "Fog",
			type = "selector",
			values = [
				[FOG.DISABLED, "Disabled (Fastest)"],
				[FOG.SIMPLE, "Simple (Fast)"],
				[FOG.VOLUMETRIC, "Volumetric (Slow)"],
			],
			default = FOG.VOLUMETRIC,
		},
	}

var gameEnv := preload("res://Mesh/Enviroment/GameEnv.tres")
var gameCompositor := preload("res://Mesh/Enviroment/GameCompositor.tres")

func applySettingValue(_settingID:String, newVal:Variant):
	match _settingID:
		"ssao":
			gameEnv.ssao_enabled = (newVal in [SSAO.ENABLED, SSAO.ENABLED_SSIL])
			gameEnv.ssil_enabled = (newVal == SSAO.ENABLED_SSIL)
		"gi":
			gameEnv.sdfgi_enabled = (newVal in [GI.ENABLED, GI.REDUCED])
			gameEnv.sdfgi_energy = (5.0 if (newVal==GI.ENABLED) else 2.0)
			RenderingServer.gi_set_use_half_resolution((newVal in [GI.DISABLED, GI.REDUCED]))
			RenderingServer.environment_set_sdfgi_ray_count(RenderingServer.ENV_SDFGI_RAY_COUNT_128 if (newVal == GI.ENABLED) else RenderingServer.ENV_SDFGI_RAY_COUNT_32)
		"ssaa":
			gameCompositor.compositor_effects[0].enabled = (newVal == SSAA.SMAA)
			OPTIONS.get_viewport().screen_space_aa = Viewport.SCREEN_SPACE_AA_FXAA if (newVal == SSAA.FXAA) else Viewport.SCREEN_SPACE_AA_DISABLED 
		"aa":
			if(newVal == AA.AAX2):
				OPTIONS.get_viewport().msaa_3d = Viewport.MSAA_2X
			elif(newVal == AA.AAX4):
				OPTIONS.get_viewport().msaa_3d = Viewport.MSAA_4X
			elif(newVal == AA.AAX8):
				OPTIONS.get_viewport().msaa_3d = Viewport.MSAA_8X
			else:
				OPTIONS.get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		"fpsCap":
			var fpsValues:Array = [60, 60, 24, 25, 30, 45, 60, 75, 90, 100, 120, 144, 165, 180, 240, 300, 0]
			if(newVal < 0):
				newVal = 0
			if(newVal >= fpsValues.size()):
				newVal = fpsValues.size() - 1
			if(newVal == FPSCAP.VSYNC):
				Engine.max_fps = 0
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
			elif(newVal == FPSCAP.VSYNCFAST):
				Engine.max_fps = 0
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)
			else:
				Engine.max_fps = fpsValues[newVal]
				DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		"glow":
			gameEnv.glow_enabled = (newVal in [GLOW.ENABLED])
		"fog":
			gameEnv.volumetric_fog_enabled = (newVal in [FOG.VOLUMETRIC])
			gameEnv.fog_enabled = (newVal in [FOG.SIMPLE])
		"renderScale":
			var scaleValues:Array = [1.0, 0.9, 0.75, 0.6, 0.5, 0.33, 0.25, 0.2, 0.1]
			if(newVal < 0):
				newVal = 0
			if(newVal >= scaleValues.size()):
				newVal = scaleValues.size() - 1
			RenderingServer.viewport_set_scaling_3d_scale(OPTIONS.get_viewport().get_viewport_rid(), scaleValues[newVal])
		"upscaler":
			if(newVal == UPSCALER.FSR1):
				RenderingServer.viewport_set_scaling_3d_mode(OPTIONS.get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_SCALING_3D_MODE_FSR)
			elif(newVal == UPSCALER.FSR2):
				RenderingServer.viewport_set_scaling_3d_mode(OPTIONS.get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_SCALING_3D_MODE_FSR2)
			else:
				RenderingServer.viewport_set_scaling_3d_mode(OPTIONS.get_viewport().get_viewport_rid(), RenderingServer.VIEWPORT_SCALING_3D_MODE_BILINEAR)

		"fullscreen":
			if(newVal == FULLSCREEN.BORDERLESS):
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			elif(newVal == FULLSCREEN.EXCLUSIVE):
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			else:
				if(DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_WINDOWED && DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_MAXIMIZED):
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		"texturesChar":
			OPTIONS.triggerCharTextureQualityChange()
