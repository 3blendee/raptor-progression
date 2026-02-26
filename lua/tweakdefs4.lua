-- Raptor Progression: Mini-Boss Checkpoints (Slot 4)
-- Mid-game bosses signal "time to tech up"

-- Deep copy utility for cloning unit definitions
local function deepCopy(orig)
    if type(orig) ~= "table" then return orig end
    local copy = {}
    for k, v in pairs(orig) do
        copy[k] = deepCopy(v)
    end
    return setmetatable(copy, getmetatable(orig))
end

-- Find the base matriarch unit to clone from
local baseMatriarch = nil
local baseMatriarchName = nil
for name, uDef in pairs(UnitDefs) do
    if name:match("raptor_matriarch") or name:match("raptor_guardian") then
        baseMatriarch = uDef
        baseMatriarchName = name
        break
    end
end

-- Fallback: use any mid-tier raptor as base
if not baseMatriarch then
    for name, uDef in pairs(UnitDefs) do
        if name:match("^raptor_") and not name:match("queen")
           and uDef.health and uDef.health > 2000 then
            baseMatriarch = uDef
            baseMatriarchName = name
            break
        end
    end
end

if baseMatriarch then
    local baseHP = baseMatriarch.health or 5000

    -- Player count awareness for scaling
    local totalSpawnScale = 1.0

    -- Mini-boss tier 1: Matron (~10 min, anger ~300)
    -- Signals need for T2 player tech
    local matron = deepCopy(baseMatriarch)
    matron.health = math.floor(baseHP * 3.0 * totalSpawnScale)
    matron.metalcost = 2000  -- good reclaim reward
    matron.energycost = 20000
    matron.speed = (baseMatriarch.speed or 60) * 0.9
    matron.customparams = matron.customparams or {}
    matron.customparams.raptorcustomsquad = "matron"
    matron.customparams.raptorsquadbehavior = "BERSERKER"
    -- Basic weapon type — straightforward damage
    if matron.weapondefs then
        for wname, wDef in pairs(matron.weapondefs) do
            if wDef.damage then
                for dtype, dval in pairs(wDef.damage) do
                    wDef.damage[dtype] = math.floor(dval * 2.0)
                end
            end
        end
    end
    UnitDefs["raptor_miniboss_matron"] = matron

    -- Mini-boss tier 2: Queenling (~20 min, anger ~500)
    -- Signals need for T3 player tech
    local queenling = deepCopy(baseMatriarch)
    queenling.health = math.floor(baseHP * 5.0 * totalSpawnScale)
    queenling.metalcost = 4000
    queenling.energycost = 40000
    queenling.speed = (baseMatriarch.speed or 60) * 0.8
    queenling.customparams = queenling.customparams or {}
    queenling.customparams.raptorcustomsquad = "queenling"
    queenling.customparams.raptorsquadbehavior = "BERSERKER"
    -- Acid weapon type — area damage
    if queenling.weapondefs then
        for wname, wDef in pairs(queenling.weapondefs) do
            if wDef.damage then
                for dtype, dval in pairs(wDef.damage) do
                    wDef.damage[dtype] = math.floor(dval * 3.0)
                end
            end
            wDef.areaofeffect = (wDef.areaofeffect or 0) + 64
        end
    end
    UnitDefs["raptor_miniboss_queenling"] = queenling

    -- Mini-boss tier 3: Elite (~25 min, anger ~700)
    -- T3 army test before queen appears
    local elite = deepCopy(baseMatriarch)
    elite.health = math.floor(baseHP * 7.0 * totalSpawnScale)
    elite.metalcost = 6000
    elite.energycost = 60000
    elite.speed = (baseMatriarch.speed or 60) * 0.7
    elite.customparams = elite.customparams or {}
    elite.customparams.raptorcustomsquad = "elite"
    elite.customparams.raptorsquadbehavior = "BERSERKER"
    -- EMP weapon type — stun effect
    if elite.weapondefs then
        for wname, wDef in pairs(elite.weapondefs) do
            if wDef.damage then
                for dtype, dval in pairs(wDef.damage) do
                    wDef.damage[dtype] = math.floor(dval * 4.0)
                end
            end
            -- Add paralysis damage for EMP effect
            wDef.paralyzer = true
            wDef.paralyzetime = 3
        end
    end
    UnitDefs["raptor_miniboss_elite"] = elite
end

-- UnitDef_Post callback for any post-processing overrides
if UnitDef_Post then
    for name, uDef in pairs(UnitDefs) do
        if name:match("raptor_miniboss_") then
            -- Ensure mini-bosses are properly categorized
            uDef.customparams = uDef.customparams or {}
            uDef.customparams.subfolder = "other/raptors"
        end
    end
end
