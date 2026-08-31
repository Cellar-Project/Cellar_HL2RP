--[[
	Centralized asset fallback layer for ixhl2rp.

	The Cellar HL2RP schema historically depended on a large amount of
	server-specific content (custom UI textures, sounds, item models,
	custom weapon worldmodels and so on) that is no
	longer shipped with the codebase. Without those assets, raw
	`Material("cellar/...")` / `Model("models/cellar/...")` calls
	produce pink-and-black missing textures and `models/error.mdl`
	placeholders.

	This library exposes a small set of helpers under `Schema.assets`
	that wrap those calls. Each helper resolves a path in this order:

		1. The requested path itself, if it exists on disk.
		2. The caller-supplied fallback path, if it exists on disk.
		3. A manifest entry mapped from the requested path, if defined
		   in `sh_asset_manifest.lua` and the mapped path exists on
		   disk.
		4. A safe vanilla-shipped placeholder.

	The helpers cache the resolved path so subsequent calls (e.g. from
	`PANEL:Paint`) do not repeatedly hit `file.Exists`. Resolution is
	performed lazily, at the first call site for a given path.

	Because step 1 always wins when the original asset is present, the
	gamemode automatically picks up the original Cellar pack again if a
	user later restores it; no code changes are required.
]]

Schema.assets = Schema.assets or {}

-- ---------------------------------------------------------------------
-- Default placeholders
-- These are intentionally vanilla-only paths that ship with HL2 / GMod
-- and are practically guaranteed to exist on every install. They are
-- only used as the absolute last resort, after the manifest has also
-- failed to provide an existing replacement.
-- ---------------------------------------------------------------------
Schema.assets.defaultMaterialPath = "vgui/white"
Schema.assets.defaultModelPath    = "models/props_junk/cardboard_box003a.mdl"
Schema.assets.defaultSoundPath    = "common/null.wav"
Schema.assets.defaultFont         = "DermaDefault"

-- ---------------------------------------------------------------------
-- Manifest storage
-- The manifest is populated by `sh_asset_manifest.lua` (loaded right
-- after this file). It is a plain table keyed by asset kind so the
-- lookup is O(1) per call.
-- ---------------------------------------------------------------------
Schema.assets.manifest = Schema.assets.manifest or {
	materials = {},
	models    = {},
	sounds    = {},
	fonts     = {},
}

-- ---------------------------------------------------------------------
-- Internal caches
-- Keyed by the originally-requested path so repeat lookups are cheap.
-- The material object cache additionally keys by material flags so a
-- caller asking for the same texture with different `Material()` flags
-- still gets distinct material instances.
-- ---------------------------------------------------------------------
local materialPathCache   = {}
local materialObjectCache = {}
local modelPathCache      = {}
local soundPathCache      = {}

-- ---------------------------------------------------------------------
-- Existence helpers
-- ---------------------------------------------------------------------

-- `Material("path", "flags")` accepts an optional second flag string,
-- but call sites occasionally pass the flags concatenated into the
-- first argument (e.g. `"foo/bar smooth"`). We strip those here so the
-- existence check sees only the actual file path.
local function NormalizeMaterialPath(path)
	if (not isstring(path)) then return nil end
	return (path:gsub("%s.*$", ""))
end

local function MaterialFileExists(path)
	path = NormalizeMaterialPath(path)
	if (not path or path == "") then return false end

	-- If the caller already specified an extension (e.g. .png) the
	-- file must literally exist as-is under `materials/`. Otherwise
	-- the engine looks for a `.vmt`, optionally backed by a `.png` or
	-- `.jpg` of the same name.
	local ext = path:match("%.([%a%d]+)$")
	if (ext) then
		return file.Exists("materials/" .. path, "GAME")
	end

	return file.Exists("materials/" .. path .. ".vmt", "GAME")
		or file.Exists("materials/" .. path .. ".png", "GAME")
		or file.Exists("materials/" .. path .. ".jpg", "GAME")
		or file.Exists("materials/" .. path .. ".jpeg", "GAME")
end

local function ModelFileExists(path)
	if (not isstring(path) or path == "") then return false end
	return file.Exists(path, "GAME")
end

local function SoundFileExists(path)
	if (not isstring(path) or path == "") then return false end
	return file.Exists("sound/" .. path, "GAME")
end

-- ---------------------------------------------------------------------
-- Manifest resolution
-- A manifest entry is only honoured when the mapped path itself
-- resolves on disk; this prevents one missing asset from being
-- silently replaced by another missing asset.
-- ---------------------------------------------------------------------
local function ResolveFromManifest(kind, path, existsFn)
	local entries = Schema.assets.manifest[kind]
	if (not entries) then return nil end

	local mapped = entries[path]
	if (mapped and existsFn(mapped)) then
		return mapped
	end

	return nil
end

-- ---------------------------------------------------------------------
-- Public path resolvers
-- ---------------------------------------------------------------------

--- Resolves a material path, returning a string suitable for
--  `Material()` / `surface.SetMaterial()`. The original path is used
--  whenever it exists on disk; otherwise the supplied fallback,
--  manifest mapping, or built-in placeholder is returned.
-- @realm shared
-- @string path Original (possibly-missing) material path.
-- @string[opt] fallbackPath Caller-supplied stock replacement.
-- @treturn string Resolved material path that is guaranteed to exist.
function Schema.assets.MaterialPath(path, fallbackPath)
	if (not isstring(path) or path == "") then
		return Schema.assets.defaultMaterialPath
	end

	local cached = materialPathCache[path]
	if (cached ~= nil) then return cached end

	local resolved
	if (MaterialFileExists(path)) then
		resolved = path
	elseif (fallbackPath and MaterialFileExists(fallbackPath)) then
		resolved = fallbackPath
	else
		local manifestPath = ResolveFromManifest("materials", NormalizeMaterialPath(path), MaterialFileExists)
		resolved = manifestPath or Schema.assets.defaultMaterialPath
	end

	materialPathCache[path] = resolved
	return resolved
end

--- Returns a cached `IMaterial` for the given path, falling back to
--  stock content when the original asset is missing. Mirrors the
--  signature of `Material()` so call sites can swap with minimal
--  changes.
-- @realm shared
-- @string path Original (possibly-missing) material path.
-- @string[opt] fallbackPath Caller-supplied stock replacement.
-- @string[opt] materialFlags Optional flag string forwarded to `Material()`.
-- @treturn IMaterial Cached material object.
function Schema.assets.Material(path, fallbackPath, materialFlags)
	local resolved = Schema.assets.MaterialPath(path, fallbackPath)
	local cacheKey = resolved .. "\1" .. (materialFlags or "")

	local mat = materialObjectCache[cacheKey]
	if (not mat) then
		mat = Material(resolved, materialFlags)
		materialObjectCache[cacheKey] = mat
	end

	return mat
end

--- Resolves a model path. Returns a string usable in `Model()`,
--  `Entity:SetModel()`, `ITEM.model`, etc.
-- @realm shared
-- @string path Original (possibly-missing) model path.
-- @string[opt] fallbackPath Caller-supplied stock replacement.
-- @treturn string Resolved model path that is guaranteed to exist.
function Schema.assets.Model(path, fallbackPath)
	if (not isstring(path) or path == "") then
		return Schema.assets.defaultModelPath
	end

	local cached = modelPathCache[path]
	if (cached ~= nil) then return cached end

	local resolved
	if (ModelFileExists(path)) then
		resolved = path
	elseif (fallbackPath and ModelFileExists(fallbackPath)) then
		resolved = fallbackPath
	else
		local manifestPath = ResolveFromManifest("models", path, ModelFileExists)
		resolved = manifestPath or Schema.assets.defaultModelPath
	end

	modelPathCache[path] = resolved
	return resolved
end

--- Resolves a sound path. Returns a string usable in
--  `surface.PlaySound`, `EmitSound`, `sound.Add({sound = ...})`, etc.
-- @realm shared
-- @string path Original (possibly-missing) sound path (relative to `sound/`).
-- @string[opt] fallbackPath Caller-supplied stock replacement.
-- @treturn string Resolved sound path that is guaranteed to exist.
function Schema.assets.Sound(path, fallbackPath)
	if (not isstring(path) or path == "") then
		return Schema.assets.defaultSoundPath
	end

	local cached = soundPathCache[path]
	if (cached ~= nil) then return cached end

	local resolved
	if (SoundFileExists(path)) then
		resolved = path
	elseif (fallbackPath and SoundFileExists(fallbackPath)) then
		resolved = fallbackPath
	else
		local manifestPath = ResolveFromManifest("sounds", path, SoundFileExists)
		resolved = manifestPath or Schema.assets.defaultSoundPath
	end

	soundPathCache[path] = resolved
	return resolved
end

-- ---------------------------------------------------------------------
-- Existence helpers (public)
-- ---------------------------------------------------------------------

--- Returns true if `path` exists in the mounted content.
-- @realm shared
function Schema.assets.MaterialExists(path) return MaterialFileExists(path) end
function Schema.assets.ModelExists(path)    return ModelFileExists(path) end
function Schema.assets.SoundExists(path)    return SoundFileExists(path) end

-- ---------------------------------------------------------------------
-- Font fallbacks
-- There is no reliable way to detect installed system fonts at
-- runtime, so we rely on a small registry of known-missing families
-- and route them to safe alternates. Unknown fonts are returned as-is
-- so most call sites remain unaffected.
-- ---------------------------------------------------------------------

--- Resolves a font family name to a guaranteed-safe replacement when
--  the original family is registered as missing.
-- @realm client
-- @string fontName Requested font family.
-- @treturn string Safe font family name.
function Schema.assets.Font(fontName)
	if (not isstring(fontName) or fontName == "") then
		return Schema.assets.defaultFont
	end

	local mapped = Schema.assets.manifest.fonts[fontName]
	if (mapped) then return mapped end

	return fontName
end

--- Registers a fallback for a font family name. Useful for call sites
--  that want to extend the manifest in place rather than editing the
--  manifest file.
-- @realm client
-- @string fontName Requested font family.
-- @string fallbackName Font family to use instead.
function Schema.assets.RegisterFontFallback(fontName, fallbackName)
	Schema.assets.manifest.fonts[fontName] = fallbackName
end

-- ---------------------------------------------------------------------
-- Cache management
-- Mostly useful from console for live debugging of new manifest
-- entries; in normal play the caches live for the duration of the
-- session.
-- ---------------------------------------------------------------------
function Schema.assets.ClearCache()
	table.Empty(materialPathCache)
	table.Empty(materialObjectCache)
	table.Empty(modelPathCache)
	table.Empty(soundPathCache)
end
