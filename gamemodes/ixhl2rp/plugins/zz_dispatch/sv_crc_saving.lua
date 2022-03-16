local PLUGIN = PLUGIN

local stored = dispatch.crc_table or {}
dispatch.crc_table = stored or {}

local function GenerateCRC(entity)
	local pos = entity:GetPos()

	return util.CRC(pos[1]..pos[2]..pos[3])
end

function dispatch.SetupCRC(entity, callback)
	if entity.SaveCRC then
		return
	end
	
	local class = entity:GetClass()

	entity.SaveCRC = GenerateCRC(entity)

	stored[class] = stored[class] or {}
	stored[class][entity] = entity.SaveCRC

	if callback then
		entity:SetNetVar("cam", callback())
	end

	local data = PLUGIN:GetData()

	if data[class] and data[class][entity.SaveCRC] then
		entity:SetNetVar("cam", data[class][entity.SaveCRC])
	end
end

function PLUGIN:SaveData()
	local data = {}

	for class, v in pairs(stored) do
		data[class] = data[class] or {}

		for entity, crc in pairs(v) do
			if !IsValid(entity) then continue end

			data[class][crc] = entity:GetNetVar("cam")
		end
	end

	self:SetData(data)
end