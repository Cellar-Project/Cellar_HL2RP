local PLUGIN = PLUGIN

PLUGIN.name = "StormFox"
PLUGIN.author = "alexgrist"
PLUGIN.description = "Syncs StormFox to the Helix time and date."

if (CLIENT) then
	return
end

local warned = false

local function CanSyncTime()
	if (StormFox2 and StormFox2.Time and isfunction(StormFox2.Time.Set)) then
		return true
	end

	if (not warned) then
		warned = true
		ErrorNoHalt("[ix StormFox] StormFox2.Time.Set unavailable; time synchronization skipped.\n")
	end

	return false
end

-- StormFox2 2.x emits this after scanning map entities (also after map cleanup).
hook.Add("StormFox2.PostEntityScan", "ixStormFox", function()
	if (CanSyncTime()) then
		StormFox2.Time.Set(ix.date.GetFormatted("%H:%M"))
	end
end)

hook.Add("InitPostEntity", "ixStormFoxAvailability", function()
	-- The addon cannot emit its own hook when absent.
	timer.Simple(0, CanSyncTime)
end)
