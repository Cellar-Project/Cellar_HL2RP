PLUGIN.name = "NPCs Loot System"
PLUGIN.author = "Vintage Thief & Schwarz Kruppzo"
PLUGIN.description = "Making killing NPCs less pointless."

local TYPE_MPF = 1
local TYPE_ZOMBIES = 2
local TYPE_REBELS = 3

local loot = {
    [TYPE_MPF] = {"bandage", "handheld_radio", "health_kit", "pistol", "zip_tie", "smg1", "pistolammo", "357ammo", "shotgunammo"},
    [TYPE_ZOMBIES] = {"water", "ration", "crowbar", "pistolammo", "357ammo", "shotgunammo", "suitcase", "rmedic_uniform", "resistance_uniform"},
    [TYPE_REBELS] = {"chinese_takeout", "ration", "health_vial", "pistol", "smg1", "crowbar", "357ammo", "shotgunammo", "resistance_uniform", "rmedic_uniform"},
}

function PLUGIN:LootGeneration(type)
    if not loot[type] then
        return false
    end
    return table.Random(loot[type])
end

function PLUGIN:SpawnLoot()
end

if SERVER then
    local npcs = {
        ["npc_combine_s"] = TYPE_MPF,
        ["npc_combinegunship"] = TYPE_MPF,
		["CombineElite"] = TYPE_MPF,
		["CombinePrison"] = TYPE_MPF,
		["PrisonShotgunner"] = TYPE_MPF,
        ["npc_combinedropship"] = TYPE_MPF,
        ["npc_helicopter"] = TYPE_MPF,
        ["npc_metropolice"] = TYPE_MPF,
        ["npc_strider"] = TYPE_MPF,
        ["npc_fastzombie"] = TYPE_ZOMBIES,
        ["npc_barnacle"] = TYPE_ZOMBIES,
        ["npc_headcrab"] = TYPE_ZOMBIES,
        ["npc_headcrab_black"] = TYPE_ZOMBIES,
        ["npc_headcrab_fast"] = TYPE_ZOMBIES,
        ["npc_poisonzombie"] = TYPE_ZOMBIES,
        ["npc_zombie"] = TYPE_ZOMBIES,
        ["npc_zombie_torso"] = TYPE_ZOMBIES,
        ["npc_rebels"] = TYPE_REBELS,
        ["npc_citizen"] = TYPE_REBELS,
    }

    function PLUGIN:OnNPCKilled(NPC)

        local isHasLootType = npcs[NPC:GetClass()]
		local spos = NPC:GetPos()

        if !isHasLootType then
            return
        end

        local itemClass = self:LootGeneration(isHasLootType)

        if !itemClass then
            return
        end

        local pos = NPC:GetPos()

		ix.item.Spawn(itemClass, spos, nil, nil, nil)
    end
end