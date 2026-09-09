local PLUGIN = PLUGIN
PLUGIN.name = "Combine Assassin"
PLUGIN.author = "Schwarz Kruppzo"
PLUGIN.description = ""

ix.util.Include("sh_anims.lua")

-- Slots an assassin cannot use: their armor is built into the rig. Everything from
-- slot 9 up (EQUIP_CID, EQUIP_RADIO, the reserved slots) stays available so they keep
-- their ID card, radio and request device. Written as literals rather than the EQUIP_*
-- globals because a nil table key would be a hard error if that plugin were disabled.
PLUGIN.blockedEquipmentSlots = {
	[1] = true, -- EQUIP_HEAD
	[2] = true, -- EQUIP_EYE
	[3] = true, -- EQUIP_EARS
	[4] = true, -- EQUIP_MASK
	[5] = true, -- EQUIP_TORSO
	[6] = true, -- EQUIP_HANDS
	[7] = true, -- EQUIP_LEGS
	[8] = true  -- EQUIP_BACK
}

ix.config.Add("assassinArmor", 8, "Built-in armor points an assassin has on every hitgroup. Compares to an equipment item's Stats value; 0 disables it.", nil, {
	data = {min = 0, max = 40},
	category = "categoryAssassin"
})

ix.config.Add("assassinSprintEvasion", 50, "How much an assassin's chance of being hit is reduced while sprinting (%).", nil, {
	data = {min = 0, max = 90},
	category = "categoryAssassin"
})

ix.config.Add("assassinNoFallDamage", true, "Whether assassins are immune to fall damage.", nil, {
	category = "categoryAssassin"
})

ix.config.Add("assassinProportionFix", true, "Layer the rig's proportion correction onto stock animations (raised weapons, prone). Turn off to compare; the bespoke relaxed animations are never affected.", nil, {
	category = "categoryAssassin"
})

ix.config.Add("assassinRunSpeedBonus", 25, "Extra sprint speed for assassins (%).", nil, {
	data = {min = 0, max = 100},
	category = "categoryAssassin"
})

ix.config.Add("assassinHeartbeatRange", 512, "How far an assassin's heartbeat sense reaches (units).", nil, {
	data = {min = 128, max = 2048},
	category = "categoryAssassin"
})

ix.config.Add("assassinCloakDrain", 3, "Stamina an active cloak consumes every 5 seconds.", nil, {
	data = {min = 0, max = 25, decimals = 1},
	category = "categoryAssassin"
})

ix.config.Add("assassinCloakReveal", 5, "How long an assassin stays revealed and unable to cloak after attacking (seconds).", nil, {
	data = {min = 0, max = 30, decimals = 1},
	category = "categoryAssassin"
})

ix.lang.AddTable("english", {
	categoryAssassin = "Assassin",
	assassinNoEquipment = "Your armor is built in - you cannot wear this.",
	assassinCloakOn = "Cloak engaged.",
	assassinCloakOff = "Cloak disengaged.",
	assassinCloakRevealed = "Your cloak is disrupted.",
	assassinCloakNoStamina = "You are too exhausted to cloak.",
	assassinPulseOn = "Heartbeat sense engaged.",
	assassinPulseOff = "Heartbeat sense disengaged."
})

ix.lang.AddTable("russian", {
	categoryAssassin = "Ассассин",
	assassinNoEquipment = "Ваша броня встроена - вы не можете это надеть.",
	assassinCloakOn = "Маскировка включена.",
	assassinCloakOff = "Маскировка выключена.",
	assassinCloakRevealed = "Ваша маскировка сорвана.",
	assassinCloakNoStamina = "Вы слишком истощены для маскировки.",
	assassinPulseOn = "Сенсор пульса включен.",
	assassinPulseOff = "Сенсор пульса выключен."
})

--- Blocks clothing and armor for assassins. Called from the single central gate in
-- !!inventoryenhances; returning nil leaves other factions untouched. Shared so the
-- inventory UI refuses the drag with the same rule the server enforces.
function PLUGIN:PlayerCanWearEquipment(client, item, slot)
	if (!IsValid(client) or !client:IsAssassin()) then
		return
	end

	slot = slot or item.slot

	if (self.blockedEquipmentSlots[slot]) then
		return false, "assassinNoEquipment"
	end

	-- Legacy outfits carry no slot; they are all worn clothing.
	if (!slot and (item.outfitCategory or item.isOutfit)) then
		return false, "assassinNoEquipment"
	end
end

--- Whether this player may currently turn abilities on. Kept here so the client
-- can grey things out with the same rule the server enforces.
function PLUGIN:CanUseAbilities(client)
	if (!IsValid(client) or !client:IsAssassin()) then
		return false
	end

	-- Reads the crit netvar directly: PLAYER:InCriticalState is server-only.
	return client:GetCharacter() != nil and client:Alive() and !client:GetNetVar("crit")
end

-- Registered shared so they show up in the help menu and autocomplete; OnRun only
-- ever executes on the server, where ToggleCloak/TogglePulse are defined.
ix.command.Add("Cloak", {
	description = "Toggle your cloak.",
	OnCheckAccess = function(self, client)
		return client:IsAssassin()
	end,
	OnRun = function(self, client)
		PLUGIN:ToggleCloak(client)
	end
})

ix.command.Add("Pulse", {
	description = "Toggle your heartbeat sense.",
	OnCheckAccess = function(self, client)
		return client:IsAssassin()
	end,
	OnRun = function(self, client)
		PLUGIN:TogglePulse(client)
	end
})

ix.util.Include("sv_assassin.lua")
ix.util.Include("cl_assassin.lua")