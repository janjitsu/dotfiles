-- Input configuration
hl.env("HYPRCURSOR_SIZE","64")
hl.env("HYPRCURSOR_THEME","Mytheme")
hl.env("XCURSOR_SIZE","64")
hl.env("XCURSOR_THEME","Mytheme")
hl.config({
    input = {

	kb_layout = "us",
	kb_variant = "colemak",
	kb_options = "caps:backspace",

        sensitivity = 3,
        accel_profile = "flat",
    },
    -- Uncomment the section below to enable software cursors; this can help with cursor display or behavior issues
    -- cursor = {
    --     no_hardware_cursors = 1,
    -- },
})

hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down",       action = "close" })
hl.gesture({ fingers = 3, direction = "up",         action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "left",       action = "float" })

hl.device({
    name = "logitech-wireless-touch-keyboard-k400",
    sensitivity = 1.0, -- Adjust from -1.0 to 1.0; positive values make it faster
})
