-- The vendored Helix character menu loads before schema initialization.
Schema = Schema or {}
include("ixhl2rp/schema/libs/sh_assets.lua")
include("ixhl2rp/schema/libs/sh_asset_manifest.lua")

DeriveGamemode("helix")
