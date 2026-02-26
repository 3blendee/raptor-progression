-- Raptor Progression: Faction-Agnostic Labs (Slot 5)
-- Let players access all faction units regardless of starting faction

-- Lab groups: each entry is a set of equivalent labs across factions
local labGroups = {
    -- T1 Bot Labs
    { "armlab", "corlab", "leglab" },
    -- T1 Vehicle Plants
    { "armvp", "corvp", "legvp" },
    -- T1 Aircraft Plants
    { "armap", "corap", "legap" },
    -- T1 Shipyards
    { "armsy", "corsy", "legsy" },
    -- T1 Hovercraft Platforms
    { "armhp", "corhp", "leghp" },

    -- T2 Advanced Bot Labs
    { "armalab", "coralab", "legalab" },
    -- T2 Advanced Vehicle Plants
    { "armavp", "coravp", "legavp" },
    -- T2 Advanced Aircraft Plants
    { "armaap", "coraap", "legaap" },
    -- T2 Advanced Shipyards
    { "armasy", "corasy", "legasy" },
    -- T2 Advanced Hovercraft
    { "armahp", "corahp", "legahp" },

    -- T3 Experimental Labs (if they exist)
    { "armexplab", "corexplab", "legexplab" },
}

local function mergeLabs(labs)
    -- Collect all buildoptions from equivalent labs across factions
    local merged = {}
    local order = {}

    for _, labName in ipairs(labs) do
        local uDef = UnitDefs[labName]
        if uDef and uDef.buildoptions then
            for _, bo in ipairs(uDef.buildoptions) do
                if not merged[bo] then
                    merged[bo] = true
                    table.insert(order, bo)
                end
            end
        end
    end

    -- Apply merged buildoptions back to all labs in this group
    if #order > 0 then
        for _, labName in ipairs(labs) do
            local uDef = UnitDefs[labName]
            if uDef then
                uDef.buildoptions = {}
                for i, bo in ipairs(order) do
                    uDef.buildoptions[i] = bo
                end
            end
        end
    end
end

-- Merge all lab groups
for _, group in ipairs(labGroups) do
    mergeLabs(group)
end
