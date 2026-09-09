local PLUGIN = PLUGIN

PLUGIN.name = "Damage System"
PLUGIN.author = "SchwarzKruppzo"
PLUGIN.description = ""

PLUGIN.RANGE_CLOSE = 1
PLUGIN.RANGE_MEDIUM = 2
PLUGIN.RANGE_LONG = 3
PLUGIN.RANGE_FAR = 4

ix.config.Add("armDisarmChance", 0, "Chance (%) that a hit on a fully damaged arm makes the victim drop the weapon they are holding. Scales down with less arm damage; an agility roll can still save the weapon. 0 disables it.", nil, {
	data = {min = 0, max = 100, decimals = 1},
	category = "limb"
})

ix.char.RegisterVar("shock", {
	field = "shock",
	fieldType = ix.type.number,
	default = 0,
	isLocal = true,
	bNoDisplay = true
})

ix.char.RegisterVar("blood", {
	field = "blood",
	fieldType = ix.type.number,
	default = -1,
	isLocal = true,
	bNoDisplay = true
})

ix.char.RegisterVar("dmgData", {
	field = "dmgData",
	fieldType = ix.type.string,
	default = {
		isBleeding = 0,
		isPain = false,
		bleedBone = 0,
		bleedDmg = 0
	},
	isLocal = true,
	bNoDisplay = true
})

do
	local PLAYER = FindMetaTable("Player")
	local CHAR = ix.meta.character

	function PLAYER:IsUnconscious()
		return self:GetLocalVar("knocked", false)
	end

	function CHAR:IsBleeding()
		return self:GetDmgData().isBleeding or false
	end

	function CHAR:IsFeelPain()
		return self:GetDmgData().isPain or false
	end

	function CHAR:GetBleedingBone()
		return self:GetDmgData().bleedBone or 0
	end
end

PLUGIN.hitBones = {
	[HITGROUP_HEAD] = {
		"ValveBiped.Bip01_Head1",
		"ValveBiped.Bip01_Neck1",
	},
	[HITGROUP_CHEST] = {
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	},
	[HITGROUP_STOMACH] = {
		"ValveBiped.Bip01_Spine1",
		"ValveBiped.Bip01_Spine",
	},
	[HITGROUP_LEFTARM] = {
		"ValveBiped.Bip01_L_UpperArm",
		"ValveBiped.Bip01_L_Forearm",
		"ValveBiped.Bip01_L_Hand",
	},
	[HITGROUP_RIGHTARM] = {
		"ValveBiped.Bip01_R_UpperArm",
		"ValveBiped.Bip01_R_Forearm",
		"ValveBiped.Bip01_R_Hand",
	},
	[HITGROUP_LEFTLEG] = {
		"ValveBiped.Bip01_L_Thigh",
		"ValveBiped.Bip01_L_Calf",
	},
	[HITGROUP_RIGHTLEG] = {
		"ValveBiped.Bip01_R_Thigh",
		"ValveBiped.Bip01_R_Calf",
	},
	[HITGROUP_GENERIC] = {
		"ValveBiped.Bip01_Spine4",
		"ValveBiped.Bip01_Spine2",
	},
}

do
	local clrRed = Color(255, 100, 100, 255)

	-- The message can arrive after the player left, and the anonymity plugin
	-- that supplies GetAnonID may be disabled.
	local function Describe(client)
		if (!IsValid(client)) then
			return "???"
		end

		local anonID = isfunction(client.GetAnonID) and client:GetAnonID() or nil

		return anonID and string.format("%s (%s)", client:Name(), anonID) or client:Name()
	end

	ix.chat.Register("dmgMsg", {
		OnCanHear = function(self, speaker, listener)
			return true
		end,
		CanSay = function(self, speaker)
			return !IsValid(speaker)
		end,
		OnChatAdd = function(self, speaker, text, bAnonymous, data)
			if data.t == 1 then
				chat.AddText(clrRed, string.format("Вас добивает игрок %s!", Describe(data.attacker)))
			elseif data.t == 2 then
				chat.AddText(color_white, "После игровой смерти, Вы потеряли 30% своих вещей и жетонов.")
			elseif data.t == 3 then
				chat.AddText(color_white, "Вас прекратили добивать!")
			end
		end
	})

	ix.chat.Register("dmgAdminMsg", {
		OnCanHear = function(self, speaker, listener)
			if CAMI.PlayerHasAccess(listener, "Helix - Admin Chat", nil) then
				return true
			end

			return false
		end,
		CanSay = function(self, speaker)
			return !IsValid(speaker)
		end,
		OnChatAdd = function(self, speaker, text, bAnonymous, data)
			if !CAMI.PlayerHasAccess(LocalPlayer(), "Helix - Admin Chat", nil) then
				return
			end

			if data.t == 1 then
				chat.AddText(clrRed, string.format("Игрок %s пытается добить игрока %s!", Describe(data.attacker), Describe(data.crit)))
			elseif data.t == 2 then
				chat.AddText(clrRed, string.format("%s был добит игроком %s!", Describe(data.crit), Describe(data.attacker)))
			end
		end
	})
end

function PLUGIN:CanTransferItem(itemTable, curInv, inventory)
	if !itemTable.Dropped then
		if curInv.vars and curInv.vars.isDrop and inventory:GetID() == curInv:GetID() then
			return false
		end
		
		if inventory.vars and inventory.vars.isDrop then
			return false
		end
	else
		return true
	end
end

function PLUGIN:OnItemTransferred(itemTable, curInv, inventory)
	if curInv.vars and curInv.vars.isDrop and table.IsEmpty(curInv:GetItems()) then
		itemTable.Dropped = nil

		local container = curInv.vars.entity

		if IsValid(container) then
			container:Remove()
		end
	end
end

function PLUGIN:PlayerTraceAttack(client, dmgInfo, dir, trace)
	if dmgInfo:GetDamage() <= 0 then
		return true
	end

	if CLIENT then
		return true
	end
end

ix.util.Include("meta/sh_damage.lua")
ix.util.Include("cl_hooks.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sv_plugin.lua")
ix.util.Include("sv_hooks.lua")

