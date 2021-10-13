ITEM.name = "Упаковка сигарет"
ITEM.model = Model("models/closedboxshit.mdl")
ITEM.description = "Обычная картонная упаковка сигарет."
ITEM.cigCount = 20

ITEM.functions.Take = {
	OnRun = function(itemTable)
		local client = itemTable.player
        local character = client:GetCharacter()
        print(itemTable.name)
        print(itemTable.cigCount)

        if (itemTable.cigCount > 0) then
            if (!character:GetInventory():Add("uuciggie")) then
                ix.item.Spawn("uuciggie", client)
            end
            client:EmitSound("physics/cardboard/cardboard_box_impact_hard6.wav", 75, math.random(160, 180), 0.35)

            itemTable:SetData("cigcount", itemTable.cigCount - 1)
        end

        if (itemTable.GetData("cigcount", 0) <= 0) then
            //itemTable.name = "Пачка из под сигарет"
            client:Notify("Пачка пуста!")
            
        end
        
        return false
    end
    
}

ITEM.functions.View = {
	OnRun = function(itemTable)
		local client = itemTable.player
        
        client:Notify("Осталось "..(itemTable.GetData("cigcount", 0).." сигарет в пачке.")

        return false
    end
}

/*
function ITEM:PopulateTooltip(tooltip)
    local tip = tooltip:AddRow("cigs")
    print(self.cigCount)
    tip:SetBackgroundColor(Color(137, 137, 137))
    tip:SetText("Осталось "..self.cigCount.." сигарет в пачке.")
    tip:SetFont("DermaDefault")
    tip:SizeToContents()
end
*/
