ITEM.name = "Сигарета"
ITEM.model = Model("models/phycitnew.mdl")
ITEM.description = "Обычная сигаретка с легким запахом табака и пыли."

ITEM.functions.Eat = {
    OnRun = function(itemTable)
        
        
        local client = itemTable.player
        local hascigbox = false
        
        for _, uniqueID in pairs(client:GetCharacter():GetInventory()) do
            //print(ix.item.Get(uniqueID):GetName())
            if (client:GetCharacter():GetInventory():HasItem("tool_matches")) then
                hascigbox = true
            end
        end

        if (hascigbox) then
            client:SetHealth(math.Clamp(client:Health() + 5, 0, client:GetMaxHealth()))
            client:EmitSound("ambient/fire/gascan_ignite1.wav", 50, 150, 0.25)
            
            return true
        else
            client:Notify("Вам нужны спички, чтобы поджечь сигарету!")
            return false
        end

		//client:RestoreStamina(100)
		
	end,
	OnCanRun = function(itemTable)
		//return !itemTable.player:IsCombine()
	end
}
