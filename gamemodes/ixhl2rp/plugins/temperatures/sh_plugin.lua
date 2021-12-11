local PLUGIN = PLUGIN

PLUGIN.name = "Temperatures"
PLUGIN.author = "maxxoft"
PLUGIN.description = "Temperatures system based on areas plugin."


ix.config.Add("temptick", 5, "Tickrate for temperature calculations.", nil, {
	data = {min = 1, max = 20},
	category = "temperature"
})

ix.command.Add("SetTemperature", {
	OnRun = function(self, client, areaType, temperature, name)
		PLUGIN:SetTemperature(areaType, temperature, name)
	end,
	privilege = "Edit Area Temperature",
	superAdminOnly = true
})

function PLUGIN:SetupAreaProperties()
	ix.area.AddType("temperature_controlled")
	ix.area.AddType("temperature_natural")
	ix.area.AddType("temperature_indoors")
	ix.area.AddType("temperature_indoors_loyal")
	ix.area.AddType("temperature_underground")
	ix.area.AddType("temperature_nexus")

	ix.area.AddProperty("temperature", ix.type.number, 20)
end

function PLUGIN:SetTemperature(areaType, temperature, name)
	if not temperature then return end
	if not areaType or name then return end

	if isstring(name) then
		if not ix.area.stored[name] then return end
		ix.area.stored[name].properties.temperature = temperature
		return
	end

	for _, area in pairs(ix.area.stored) do
		if area.type == areaType then
			area.properties.temperature = temperature
		end
	end
end

function PLUGIN:OnPlayerAreaChanged(client, oldID, newID)
	local area = ix.area.stored[newID]
	local temp = area.properties.temperature

	-- do temperature calculations depending on clothing (try adding a function to use
	-- it in Think too maybe), move it to sv
end

function PLUGIN:Think()
	local tickrate = ix.config.Get("temptick", 1)

	-- perform temp thinking, move it to sv
end

