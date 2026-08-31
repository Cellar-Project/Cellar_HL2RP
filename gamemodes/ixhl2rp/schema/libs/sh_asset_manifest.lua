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
	materials["cellar/chat/roll.png"]      = "icon16/dice.png"
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
	models["models/cellar/items/radio.mdl"] = "models/props_lab/citizenradio.mdl"

	-- Reagent containers (`plugins/!reagents/items/reagent_holder/*`).
	-- All glass / pitcher variants point at lost cellar meshes; group
	-- them onto a stock glass jar so loot drops still look like
	-- liquid containers rather than `models/error.mdl`.
	local reagentJar = "models/props_junk/glassjug01.mdl"
	models["models/cellar/items/reagents/glass1.mdl"]  = reagentJar
	models["models/cellar/items/reagents/glass2.mdl"]  = reagentJar
	models["models/cellar/items/reagents/glass3.mdl"]  = reagentJar
	models["models/cellar/items/reagents/glass4.mdl"]  = reagentJar
	models["models/cellar/items/reagents/glass5.mdl"]  = reagentJar
	models["models/cellar/items/reagents/glass6.mdl"]  = reagentJar
	models["models/cellar/items/reagents/glass7.mdl"]  = reagentJar
	models["models/cellar/items/reagents/glass8.mdl"]  = reagentJar
	models["models/cellar/items/reagents/glass9.mdl"]  = reagentJar
	models["models/cellar/items/reagents/glass10.mdl"] = reagentJar
	models["models/cellar/items/reagents/pitcher.mdl"] = "models/props_junk/glassjug01.mdl"
end

-- ---------------------------------------------------------------------
-- Sounds
-- The Cellar UI sound family (`sound/cellar/ui/*`) is entirely lost.
-- Rather than route every UI cue through this manifest, individual
-- call sites pass an appropriate Helix-shipped fallback (e.g.
-- `Helix.Whoosh`, `Helix.Press`) directly via the helper's second
-- argument. The default `common/null.wav` therefore acts as a silent
-- last-resort for any sound that nothing has explicitly remapped.
-- ---------------------------------------------------------------------

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
