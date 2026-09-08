local PLUGIN = PLUGIN

if (SERVER) then
    hook.Add("InitPostEntity", "ixSimfphysSettings", function()
        local settings = {
            sv_simfphys_gib_lifetime = "0",
            sv_simfphys_fuel = "0",
            sv_simfphys_teampassenger = "0",
            sv_simfphys_traction_snow = "1",
            sv_simfphys_damagemultiplicator = "100"
        }
        timer.Simple(0, function()
            local missing = {}

            for name, value in pairs(settings) do
                if (GetConVar(name)) then
                    RunConsoleCommand(name, value)
                else
                    missing[#missing + 1] = name
                end
            end

            if (#missing > 0) then
                table.sort(missing)
                ErrorNoHalt("[ix simfphys] Settings unavailable after startup; skipped: " .. table.concat(missing, ", ") .. "\n")
            end
        end)
    end)
end
