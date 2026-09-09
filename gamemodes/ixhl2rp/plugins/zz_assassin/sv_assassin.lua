local PLUGIN = PLUGIN

util.AddNetworkString("ixAssassinCloak")

local STAMINA_INTERVAL = 5 -- the drain config is expressed per this many seconds

--- Applies or clears the faction's built-in armor.
-- GetArmorDamageReduction sums `item.Stats[hitGroup]` over `client.ArmorItems`, so a
-- plain table with a Stats field is all that is needed; the other two loops over that
-- table only read `WeaponSkillBuff` and `IsArmored`, which stay nil here.
function PLUGIN:RefreshBuiltInArmor(client)
	client.ArmorItems = client.ArmorItems or {}

	if (client.ixAssassinArmor) then
		client.ArmorItems[client.ixAssassinArmor] = nil
		client.ixAssassinArmor = nil
	end

	if (!client:IsAssassin()) then
		return
	end

	local value = ix.config.Get("assassinArmor", 0)

	if (value <= 0) then
		return
	end

	-- Every hitgroup including the legs, which equipment items normally leave at 0.
	local stats = {}

	for hitGroup = 0, 7 do
		stats[hitGroup] = value
	end

	client.ixAssassinArmor = {Stats = stats, isBuiltInArmor = true}
	client.ArmorItems[client.ixAssassinArmor] = true
end

function PLUGIN:PostPlayerLoadout(client)
	self:RefreshBuiltInArmor(client)
end

function PLUGIN:PlayerLoadedCharacter(client, character, previousCharacter)
	self:SetCloaked(client, false)
	client:SetLocalVar("assassinPulse", nil)
	self:RefreshBuiltInArmor(client)
end

--[[
	Ability 2 - sprinting halves the chance of being hit.
]]
function PLUGIN:IsSprinting(client)
	return client:KeyDown(IN_SPEED) and !client:GetNetVar("brth", false) and
		client:GetVelocity():LengthSqr() >= client:GetWalkSpeed() ^ 2
end

function PLUGIN:GetHitChanceMultiplier(target, targetCharacter, attacker)
	if (!IsValid(target) or !target:IsPlayer() or !target:IsAssassin()) then
		return
	end

	if (!self:IsSprinting(target)) then
		return
	end

	local reduction = math.Clamp(ix.config.Get("assassinSprintEvasion", 0), 0, 90)

	if (reduction <= 0) then
		return
	end

	return 1 - (reduction / 100)
end

--[[
	Passive - no fall damage.

	Plugin hooks run before gamemode methods in Helix's hook.Call, so returning 0 here
	pre-empts the !damagesystem override of GetFallDamage without editing it. Returning
	nil for everyone else leaves that formula untouched. With no fall damage there is
	also no DMG_FALL event, so the leg damage the fall branch of CalculatePlayerDamage
	would normally apply never happens either.
]]
function PLUGIN:GetFallDamage(client, velocity)
	if (client:IsAssassin() and ix.config.Get("assassinNoFallDamage", true)) then
		return 0
	end
end

--[[
	Ability 3 - faster sprint.
]]
function PLUGIN:GetRunSpeedMultiplier(client)
	if (!IsValid(client) or !client:IsAssassin()) then
		return
	end

	local bonus = ix.config.Get("assassinRunSpeedBonus", 0)

	if (bonus <= 0) then
		return
	end

	return 1 + (bonus / 100)
end

--[[
	Ability 4 - cloak.
]]
function PLUGIN:SetCloaked(client, state, bSilent)
	local wasCloaked = client:GetNetVar("assassinCloak", false)

	if (state == wasCloaked) then
		return
	end

	client:SetNetVar("assassinCloak", state or nil)
	self:RefreshWeaponVisibility(client)

	net.Start("ixAssassinCloak")
		net.WriteEntity(client)
		net.WriteBool(state or false)
	net.Broadcast()

	if (!bSilent) then
		client:NotifyLocalized(state and "assassinCloakOn" or "assassinCloakOff")
	end
end

--- Hides or restores the world model of the weapon the assassin is holding, so a
-- cloaked player is not given away by a floating gun. Only weapons this plugin hid
-- are ever un-hidden again, so it cannot undo another system's SetNoDraw.
function PLUGIN:HideWeapon(client, weapon)
	if (!IsValid(weapon) or weapon:GetNoDraw()) then
		return
	end

	client.ixAssassinHidden = client.ixAssassinHidden or {}
	client.ixAssassinHidden[weapon] = true
	weapon:SetNoDraw(true)
end

function PLUGIN:RefreshWeaponVisibility(client)
	if (client:GetNetVar("assassinCloak", false)) then
		self:HideWeapon(client, client:GetActiveWeapon())
		return
	end

	for weapon in pairs(client.ixAssassinHidden or {}) do
		if (IsValid(weapon)) then
			weapon:SetNoDraw(false)
		end
	end

	client.ixAssassinHidden = nil
end

function PLUGIN:PlayerSwitchWeapon(client, oldWeapon, newWeapon)
	if (!client:GetNetVar("assassinCloak", false)) then
		return
	end

	if (IsValid(oldWeapon) and (client.ixAssassinHidden or {})[oldWeapon]) then
		oldWeapon:SetNoDraw(false)
		client.ixAssassinHidden[oldWeapon] = nil
	end

	self:HideWeapon(client, newWeapon)
end

--- Reveals a cloaked assassin and blocks re-cloaking for the configured window.
function PLUGIN:RevealAssassin(client)
	if (!IsValid(client) or !client:IsAssassin()) then
		return
	end

	local duration = ix.config.Get("assassinCloakReveal", 0)

	if (duration > 0) then
		client.ixAssassinRevealUntil = CurTime() + duration
	end

	if (client:GetNetVar("assassinCloak", false)) then
		self:SetCloaked(client, false, true)
		client:NotifyLocalized("assassinCloakRevealed")
	end
end

function PLUGIN:EntityFireBullets(entity, bulletInfo)
	if (entity:IsPlayer()) then
		self:RevealAssassin(entity)
	end
end

-- Weapons that press primary fire without attacking anything.
local ignoredAttackWeapons = {
	weapon_physgun = true,
	gmod_tool = true,
	gmod_camera = true,
	ix_hands = true
}

-- Melee swings never reach EntityFireBullets, and EntityTraceAttack is unreliable
-- here because !damagesystem returns false from it on a miss, which stops the hook
-- chain before this plugin runs. KeyPress always fires.
function PLUGIN:KeyPress(client, key)
	if (key != IN_ATTACK or !client:IsAssassin()) then
		return
	end

	local weapon = client:GetActiveWeapon()

	if (IsValid(weapon) and !ignoredAttackWeapons[weapon:GetClass()]) then
		self:RevealAssassin(client)
	end
end

function PLUGIN:DoPlayerDeath(client)
	self:SetCloaked(client, false, true)
	client:SetLocalVar("assassinPulse", nil)
end

function PLUGIN:PlayerDisconnected(client)
	client.ixAssassinArmor = nil
	client.ixAssassinHidden = nil
end

--- Cloak upkeep.
-- Deliberately a timer calling ConsumeStamina rather than the AdjustStaminaOffset
-- hook: limbs_penalties already returns a value from that hook whenever stamina is
-- regenerating, and hook.Run keeps only the first non-nil result, so a drain placed
-- there would be dropped depending on plugin iteration order.
timer.Create("ixAssassinCloakDrain", STAMINA_INTERVAL, 0, function()
	local drain = ix.config.Get("assassinCloakDrain", 0)

	if (drain <= 0) then
		return
	end

	for _, client in ipairs(player.GetAll()) do
		if (client:GetNetVar("assassinCloak", false) and client:GetCharacter() and client:Alive()) then
			client:ConsumeStamina(drain)
		end
	end
end)

function PLUGIN:PlayerStaminaLost(client)
	if (client:GetNetVar("assassinCloak", false)) then
		self:SetCloaked(client, false, true)
		client:NotifyLocalized("assassinCloakNoStamina")
	end
end

--[[
	Ability toggles. Both are console commands so they can be bound, and both
	re-validate server-side; the chat commands share the same implementation.
]]
local function CanToggle(client)
	if (!PLUGIN:CanUseAbilities(client)) then
		return false
	end

	if ((client.ixAssassinNextToggle or 0) > CurTime()) then
		return false
	end

	client.ixAssassinNextToggle = CurTime() + 0.4

	return true
end

function PLUGIN:ToggleCloak(client)
	if (!CanToggle(client)) then
		return
	end

	local cloaked = client:GetNetVar("assassinCloak", false)

	if (!cloaked) then
		if ((client.ixAssassinRevealUntil or 0) > CurTime()) then
			client:NotifyLocalized("assassinCloakRevealed")
			return
		end

		if (client:GetNetVar("brth", false)) then
			client:NotifyLocalized("assassinCloakNoStamina")
			return
		end
	end

	self:SetCloaked(client, !cloaked)
end

function PLUGIN:TogglePulse(client)
	if (!CanToggle(client)) then
		return
	end

	local enabled = !client:GetLocalVar("assassinPulse", false)

	client:SetLocalVar("assassinPulse", enabled or nil)
	client:NotifyLocalized(enabled and "assassinPulseOn" or "assassinPulseOff")
end

concommand.Add("ix_assassin_cloak", function(client)
	PLUGIN:ToggleCloak(client)
end)

concommand.Add("ix_assassin_pulse", function(client)
	PLUGIN:TogglePulse(client)
end)
