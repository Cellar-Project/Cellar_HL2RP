ITEM.base = "base_equipment"
ITEM.name = "Gasmask"
ITEM.description = "A mask designed to prevent you from breathing in harmful substances."
ITEM.model = "models/gibs/hgibs.mdl"
ITEM.category = "categoryGasmask"
ITEM.slot = EQUIP_MASK
ITEM.width = 1
ITEM.height = 1
ITEM.business = false
ITEM.CanBreakDown = false

function ITEM:CanTransferEquipment(oldinv, newinv, slot)
	if !self.CPMask then return true end
	if slot != self.slot then return false end
	local client = newinv:GetOwner()
	local canEquip = string.find(client:GetModel(), "cca_") or string.find(client:GetModel(), "guard")
	canEquip = tobool(canEquip)
	return canEquip
end