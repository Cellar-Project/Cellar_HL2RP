ix.config.Add("daily_reward", 3, "How much money does a player get when finish a daily task?", nil, {
    data = {min = 1, max = 20},
    category = "daily_system"
})
ix.config.Add("daily_amount", 1, "How many daily tasks can a player do a day?", nil, {
    data = {min = 1, max = 3},
    category = "daily_system"
})

if (SERVER) then
    ix.log.AddType("daily_complete", function(client)
        return Format("%s has completed his daily task.", client:Name())
    end, FLAG_NORMAL)
end