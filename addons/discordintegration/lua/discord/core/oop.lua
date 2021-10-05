Discord.OOP = {}
Discord.OOP.Classes = {}

function Discord.OOP:Register(class, tbl, inherit)
    tbl.class = class
    tbl.inherit = inherit
    self.Classes[class] = tbl
end

function Discord.OOP:New(class, ...)
    if not self.Classes[class] then return nil end

    local steps = {}
    local a = table.Copy(self.Classes[class])
    while(a) do
        table.insert(steps, a)

        if a.inherit then
            a = table.Copy(self.Classes[a.inherit])
        else
            a = nil
        end
    end
    steps = table.Reverse(steps)

    for _, class in ipairs(steps) do
        if class.Constructor then class:Constructor(...) end
    end

    steps = table.Reverse(steps)
    for _, class in ipairs(steps) do
        if _ == 1 then continue end

        steps[_ - 1].inherit = nil
        table.Merge(class, steps[_ - 1])
    end

    return steps[#steps]
end