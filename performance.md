# Problem Statement
The user wants to find the most obvious server performance killers in the `ixhl2rp/plugins` directory that undoubtedly harm performance on high player counts.
# Proposed Changes
I have scanned the directory and found three massive server performance killers:
1. `durability/sv_plugin.lua`: Calls `player.GetAll()` inside `PLUGIN:Tick()`, creating massive garbage collection overhead.
2. `forcefield/entities/entities/ix_dissolver.lua`: Calls `ents.FindInBox` and multiple `ents.FindInSphere` per tick on the server for each `ix_dissolver` entity.
3. `radio/sv_hooks.lua`: Calls `ents.FindByClass` inside `PlayerCanHearRadioTransmit`, which iterates over all players per message broadcast, causing severe CPU spikes.
I will formulate my answer detailing these three issues and why they impact performance.


1. player.GetAll() inside a Tick hook
Location: ixhl2rp/plugins/durability/sv_plugin.lua
```lua
function PLUGIN:Tick()
    local curTime = CurTime()

    for _, v in ipairs(player.GetAll()) do
        if (curTime >= (v.ixNextTickDurability or 0) and v:Alive() and v:GetCharacter()) then
```
Why it's a killer: 
The Tick hook runs every single server tick (usually 33 or 66 times a second). player.GetAll() in Garry's Mod does not return a cached table; it creates a brand new sequential table upon every call. Creating 33 to 66 tables per second causes an insane amount of memory allocation and rapid Garbage Collection (GC) spikes, which translates to direct server stutters. 
Fix: Use ix.util.GetHumans() or a standard Think timer that iterates through players less aggressively (e.g. 1-2 times a second), or use player.GetHumans() if it's cached, or hook into PlayerTick.

2. Spamming ents.FindInSphere and ents.FindInBox inside an uncontrolled Think loop
Location: ixhl2rp/plugins/forcefield/entities/entities/ix_dissolver.lua
```lua
function ENT:Think()
    -- ...
    if self:GetToggle() then
        local entities = ents.FindInBox(self:GetPos() - Vector(0, 0, 55), self:GetDummy():GetPos() + self:GetUp() * 150 + Vector(5, 5, 0))
    -- ...
    if self:GetToggle() then
        local data = {}
        for k, v in pairs(ents.FindInSphere(self:GetPos() + self:GetRight() * -(self:GetPos():Distance(self:GetDummy():GetPos()) / 2), 200)) do
            table.insert(data, v:GetClass())
        end

        if table.HasValue(data, "player") then
            for k, v in pairs(ents.FindInSphere(self:GetPos() + self:GetRight() * -(self:GetPos():Distance(self:GetDummy():GetPos()) / 2), 200)) do
    -- ...
```
Why it's a killer:
This entity runs ENT:Think() on every single server tick. It does not use self:NextThink() to delay executions. That means for each forcefield on the map, the server is doing 1 FindInBox and up to 2 FindInSphere calls every tick. If you have 10 forcefields on the map running at 33 tickrate, you are forcing the server to calculate ~900 spatial queries per second. Spatial queries are heavy on the CPU because they loop over entities internally and compute distance math.
Fix: Add self:NextThink( CurTime() + 0.25 ) (or more) and return true at the end of ENT:Think() so it only checks physics 4 times a second instead of 33-66 times.

3. Calling ents.FindByClass() repeatedly per Radio Message 
Location: ixhl2rp/plugins/radio/sv_hooks.lua
```lua
function PLUGIN:PlayerCanHearRadioTransmit(player, info)
    -- ...
    local range = math.pow(ix.config.Get("chatRange", 280), 2)
    local radios = ents.FindByClass("ix_stationary_radio")
    local channelID = info.data.channelID

    for k, radio in pairs(radios) do
```
Why it's a killer:
PLUGIN:PlayerCanHearRadioTransmit is checked for every potential listener whenever a message is sent over the radio. If 1 person speaks on the radio and there are 100 players on the server, this hook gets executed 100 times simultaneously. Inside the hook, ents.FindByClass("ix_stationary_radio") forces the engine to iterate over every single entity on the server to filter by class and build a table. Doing this 100 times in the same tick will absolutely annihilate server performance whenever multiple people are talking on the radio.
Fix: Cache stationary radios globally using OnEntityCreated and EntityRemoved hooks so you never have to search for them, or find them once before iterating through the receivers inside ix.radio:SayRadio().