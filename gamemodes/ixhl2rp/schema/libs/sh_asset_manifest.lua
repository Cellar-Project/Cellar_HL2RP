--[[
	Manifest of Cellar-asset → stock-replacement mappings consumed by
	`Schema.assets`. The helper layer in `sh_assets.lua` only honours
	an entry when the mapped path actually exists on disk, so all
	mappings here are vanilla HL2 / Garry's Mod content (or
	Helix-shipped UI icons) that ship on every install.

	If the original Cellar asset is later restored, the helper picks
	the original path automatically — these mappings are only used as
	fallbacks when the original is missing.

	Adding new mappings:
	* Prefer one-to-one stock equivalents when they obviously exist
	  (e.g. `models/cellar/weapons/w_smg1.mdl` → `models/weapons/w_smg1.mdl`).
	* Otherwise pick a small, neutral grouped placeholder per purpose
	  (cards, reagents, radios, generic clothing, …) so the resulting
	  visuals are at least internally consistent.
	* Do not list assets here that you have not verified exist in
	  vanilla HL2 / GMod / Helix.
]]

Schema.assets = Schema.assets or {}
Schema.assets.manifest = Schema.assets.manifest or {
	materials = {},
	models    = {},
	sounds    = {},
	fonts     = {},
}

local manifest = Schema.assets.manifest

-- ---------------------------------------------------------------------
-- Materials
-- ---------------------------------------------------------------------
do
	local materials = manifest.materials

	-- Chat icons (`schema/sh_hooks.lua`). The originals lived under
	-- `materials/cellar/chat/*.png`; the closest stock equivalents are
	-- the GMod-bundled silk-icon set.
	materials["cellar/chat/ic.png"]        = "icon16/comment.png"
	materials["cellar/chat/whisper.png"]   = "icon16/sound_low.png"
	materials["cellar/chat/yell.png"]      = "icon16/sound.png"
	materials["cellar/chat/dispatch.png"]  = "icon16/transmit.png"
	materials["cellar/chat/broadcast.png"] = "icon16/transmit_blue.png"
	materials["cellar/chat/roll.png"]      = "icon16/calculator.png"
	materials["cellar/chat/radio_hand.png"] = "icon16/transmit.png"
	materials["cellar/chat/eaves_radiohand.png"] = "icon16/sound_low.png"
	materials["cellar/chat/radio_union.png"] = "icon16/transmit_blue.png"
	materials["cellar/chat/request.png"] = "icon16/comment.png"
	materials["cellar/chat/eaves_request.png"] = "icon16/sound_low.png"

	-- UI icons retain their original materials whenever the content is mounted.
	materials["cellar/main/new.png"] = "icon16/user_add.png"
	materials["cellar/main/chars.png"] = "icon16/group.png"
	materials["cellar/main/info.png"] = "icon16/information.png"
	materials["cellar/main/content.png"] = "icon16/box.png"
	materials["cellar/main/exit.png"] = "icon16/door_out.png"
	materials["cellar/main/tab/closebutton16x16.png"] = "icon16/cross.png"
	materials["cellar/main/tab/closebuttonhovered.png"] = "icon16/cross.png"
	materials["cellar/main/tab/crosshovered.png"] = "icon16/cross.png"
	materials["cellar/main/hud/hunger.png"] = "icon16/cake.png"
	materials["cellar/main/hud/thirst.png"] = "icon16/cup.png"
	materials["cellar/main/hud/geiger.png"] = "icon16/error.png"
	materials["cellar/main/hud/filter.png"] = "icon16/shield.png"
	materials["cellar/main/hud/bullets.png"] = "icon16/package.png"
	materials["cellar/main/hud/snowflake.png"] = "icon16/weather_snow.png"

	-- Base backgrounds only. Missing borders, logos and overlays are skipped
	-- at their draw sites rather than replaced with opaque placeholder boxes.
	materials["cellar/main/tab/backgroundalpha.png"] = "vgui/gradient-d"
	materials["cellar/main/tab/backgroundtab.png"] = "vgui/gradient-d"
	materials["cellar/main/tab/backgroundtabmirrored.png"] = "vgui/gradient-d"
	materials["cellar/main/tab/otherbackground.png"] = "vgui/gradient-d"
	materials["cellar/ui/dispatch/bg.png"] = "vgui/gradient-d"

	materials["cellar/ui/dispatch/camera.png"] = "icon16/camera.png"
	materials["cellar/ui/dispatch/leader.png"] = "icon16/star.png"
	materials["cellar/ui/dispatch/ico/gun"] = "icon16/bomb.png"
	materials["cellar/ui/dispatch/ico/attack"] = "icon16/exclamation.png"
	materials["cellar/ui/dispatch/ico/hazard"] = "icon16/error.png"
	materials["cellar/ui/dispatch/ico/factory"] = "icon16/building.png"
	materials["cellar/ui/dispatch/ico/poi"] = "icon16/flag_blue.png"
	materials["cellar/ui/dispatch/ico/protect"] = "icon16/shield.png"
	materials["cellar/ui/dispatch/ico/regroup"] = "icon16/group.png"
	materials["cellar/ui/dispatch/ico/death"] = "icon16/cancel.png"
	materials["cellar/ui/dispatch/ico/warn"] = "icon16/exclamation.png"
	materials["vgui/terminals/reticle_finger.png"] = "icon16/cursor.png"

	-- Weapon tooltip stat icons (`plugins/weapons/items/base/sh_weapons.lua`).
	materials["cellar/ui/weaponry/ap.png"]       = "icon16/shield.png"
	materials["cellar/ui/weaponry/attack.png"]   = "icon16/gun.png"
	materials["cellar/ui/weaponry/limbdmg.png"]  = "icon16/user_red.png"
	materials["cellar/ui/weaponry/shockdmg.png"] = "icon16/lightning.png"
	materials["cellar/ui/weaponry/blooddmg.png"] = "icon16/heart.png"
	materials["cellar/ui/weaponry/bleed.png"]    = "icon16/heart_delete.png"

	-- Critical-state marker drawn over downed players (`plugins/!damagesystem/cl_hooks.lua`).
	materials["cellar/ui/crit.png"] = "icon16/heart_delete.png"
end

-- ---------------------------------------------------------------------
-- Models
-- ---------------------------------------------------------------------
do
	local models = manifest.models

	-- Holstered-weapon worldmodels (`plugins/holsteredswep.lua`).
	-- Stock HL2 already ships canonical SMG / shotgun worldmodels, so
	-- we map the lost Cellar variants directly to those.
	models["models/cellar/weapons/w_smg1.mdl"]    = "models/weapons/w_smg1.mdl"
	models["models/cellar/weapons/w_shotgun.mdl"] = "models/weapons/w_shotgun.mdl"

	-- Citizen ID cards (`plugins/citizenids/items/cards/*`). All cards
	-- share the same lost mesh, so they collapse onto a single small
	-- generic stand-in until the original card model is restored.
	-- `models/props_lab/clipboard.mdl` is a small flat prop that
	-- reads as a card-sized object in inventory previews.
	models["models/vintagethief/cellarproject/cid_card.mdl"] = "models/props_lab/clipboard.mdl"

	-- Radios (`plugins/radio/items/base/sh_radios.lua`). Stock HL2
	-- ships a citizen radio model that is an obvious visual match.
	models["models/cellar/items/handheld_radio.mdl"] = "models/props_lab/citizenradio.mdl"

	-- Reagent containers (`plugins/!reagents/items/reagent_holder/*`).
	-- Match the current item paths and their stock bottle/cup placeholders.
	for _, index in ipairs({1, 4, 5, 7, 8, 9}) do
		models["models/cellar/liquid/glass" .. index .. ".mdl"] = "models/props_junk/garbage_glassbottle003a.mdl"
	end

	for _, index in ipairs({2, 3, 6, 10}) do
		models["models/cellar/liquid/glass" .. index .. ".mdl"] = "models/props_junk/garbage_coffeemug001a.mdl"
	end

	models["models/cellar/liquid/pitcher.mdl"] = "models/props_junk/garbage_milkcarton002a.mdl"
end

-- ---------------------------------------------------------------------
-- Sounds
-- Paths are relative to sound/. Scripted names such as Helix.Press must
-- remain at EmitSound/StopSound call sites, not pass through the resolver.
-- ---------------------------------------------------------------------
do
	local sounds = manifest.sounds

	sounds["cellar/ui/dronelooping.wav"] = "common/null.wav"
	sounds["cellar/ui/otherlooping25.wav"] = "common/null.wav"
	sounds["cellar/ui/info.mp3"] = "common/null.wav"
	sounds["cellar/ui/droneoutro25.mp3"] = "common/null.wav"
	sounds["cellar/ui/infooutro25.mp3"] = "common/null.wav"
	sounds["terminals/button_rollover.ogg"] = "buttons/button15.wav"
	sounds["terminals/button_push.ogg"] = "buttons/button14.wav"
	sounds["terminals/click.wav"] = "buttons/button14.wav"
end

-- ---------------------------------------------------------------------
-- Fonts
-- The Cellar UI uses a handful of custom families that are not bundled
-- with GMod or Helix. Map them onto Roboto / Roboto Th — both ship
-- with Helix and are used by Helix's own derma — so layouts stay
-- legible even when the original families are missing on the client.
-- ---------------------------------------------------------------------
do
	local fonts = manifest.fonts

	fonts["Nagonia"]            = "Roboto"
	fonts["Geometria"]          = "Roboto Th"
	fonts["Open Sans Extrabold"] = "Roboto"
end
