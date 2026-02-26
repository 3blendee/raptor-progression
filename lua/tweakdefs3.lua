-- Raptor Progression: Defense Nerfs (Slot 3)
-- Static defenses supplement armies but can't carry alone

local function isRaptor(name, uDef)
    if uDef.customparams and uDef.customparams.subfolder == "other/raptors" then
        return true
    end
    if name:match("^raptor_") then
        return true
    end
    return false
end

local function isStaticDefense(uDef)
    -- Must be immobile
    if uDef.canmove then return false end
    if uDef.speed and uDef.speed > 0 then return false end
    -- Must have weapons (not just a wall or eco building)
    if uDef.weapondefs then
        for _, wDef in pairs(uDef.weapondefs) do
            if wDef.damage then
                return true
            end
        end
    end
    return false
end

local function isWall(name, uDef)
    if name:match("wall") or name:match("dragon_teeth") or name:match("dtooth")
       or name:match("fortification") then
        return true
    end
    -- Immobile, no weapons, low cost = likely wall/obstacle
    if not uDef.canmove and not uDef.weapondefs and uDef.metalcost and uDef.metalcost < 50 then
        return true
    end
    return false
end

local function isAntiAir(uDef)
    if uDef.weapondefs then
        for _, wDef in pairs(uDef.weapondefs) do
            if wDef.canattackground == false or wDef.onlyTargetCategory then
                local cat = wDef.onlyTargetCategory or ""
                if cat:match("VTOL") or cat:match("AIR") then
                    return true
                end
            end
        end
    end
    return false
end

for name, uDef in pairs(UnitDefs) do
    -- Skip raptor units
    if isRaptor(name, uDef) then
        goto continue
    end

    -- Walls: health buff to make base layout matter
    if isWall(name, uDef) then
        uDef.health = math.floor((uDef.health or 200) * 1.5)
        goto continue
    end

    -- Static defense towers
    if isStaticDefense(uDef) then
        -- Health buff (survive longer when engaged)
        uDef.health = math.floor((uDef.health or 500) * 1.2)

        if uDef.weapondefs then
            for wname, wDef in pairs(uDef.weapondefs) do
                -- Range nerf (shorter reach = must have army coverage)
                if wDef.range then
                    wDef.range = math.floor(wDef.range * 0.75)
                end

                -- Damage nerf (less DPS than mobile armies)
                if wDef.damage then
                    for dtype, dval in pairs(wDef.damage) do
                        wDef.damage[dtype] = math.floor(dval * 0.85)
                    end
                end

                -- Anti-air: faster reload (air waves are dangerous, AA helps)
                if isAntiAir(uDef) then
                    if wDef.reloadtime then
                        wDef.reloadtime = wDef.reloadtime * 0.85
                    end
                end
            end
        end
    end

    ::continue::
end
