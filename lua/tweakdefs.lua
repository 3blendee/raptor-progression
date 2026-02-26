-- Raptor Progression: Core Raptor Tier Scaling (Slot 0)
-- T1->T2->T3->T4 power curve with fast 30-40 min pacing

do
    local unitDefs = UnitDefs or {}

    -- Raptor tier classification by unit name patterns
    local function getRaptorTier(name)
        -- T4: apex / behemoth / leviathan
        if name:match("_t4_") or name:match("apex") or name:match("behemoth") or name:match("leviathan") then
            return 4
        end
        -- T3: assault / overseer / advanced variants
        if name:match("_t3_") or name:match("assault") or name:match("overseer")
           or name:match("advanced") or name:match("stalker") or name:match("demolisher") then
            return 3
        end
        -- T2: warrior / hunter / mid-tier
        if name:match("_t2_") or name:match("warrior") or name:match("hunter") or name:match("raider")
           or name:match("guardian") or name:match("spiker") then
            return 2
        end
        -- T1: everything else (basic swarmers, scouts, larvae)
        return 1
    end

    -- Tier health multipliers
    local TIER_HP = {
        [1] = 0.75,   -- T1: easier early game
        [2] = 1.0,    -- T2: standard pressure
        [3] = 1.3,    -- T3: demands T2+ player armies
        [4] = 1.6,    -- T4: requires T3 player response
    }

    for name, uDef in pairs(unitDefs) do
        if uDef.customparams and uDef.customparams.subfolder == "other/raptors" then
            -- Skip queen (handled in tweakdefs1)
            if name:match("^raptor_queen") then
                goto continue
            end

            local tier = getRaptorTier(name)
            local hpMult = TIER_HP[tier] or 1.0

            -- Scale health and recalculate metalcost proportionally
            if uDef.health then
                local oldHealth = uDef.health
                uDef.health = math.floor(uDef.health * hpMult)
                if uDef.metalcost and oldHealth > 0 then
                    uDef.metalcost = math.floor(uDef.health * 0.75 / hpMult)
                end
            end

            -- Prevent raptors from chasing critters/objects
            uDef.nochasecategory = "OBJECT"

            -- Raptor turrets: halve range, double health (stay near center burrows)
            if uDef.speed == nil or uDef.speed == 0 then
                if not uDef.canmove then
                    uDef.health = math.floor((uDef.health or 500) * 2.0)
                    if uDef.weapondefs then
                        for wname, wDef in pairs(uDef.weapondefs) do
                            if wDef.range then
                                wDef.range = math.floor(wDef.range * 0.5)
                            end
                        end
                    end
                end
            end

            -- Bomber damage reduction (ground army focus)
            if uDef.canfly and uDef.weapondefs then
                for wname, wDef in pairs(uDef.weapondefs) do
                    if wDef.damage then
                        for dtype, dval in pairs(wDef.damage) do
                            wDef.damage[dtype] = math.floor(dval * 0.7)
                        end
                    end
                end
            end

            -- Air fighters: convert to spike projectiles (NuttyB pattern)
            if uDef.canfly and uDef.weapondefs then
                for wname, wDef in pairs(uDef.weapondefs) do
                    if wDef.weapontype == "MissileLauncher" or wDef.weapontype == "AircraftBomb" then
                        wDef.weapontype = "Cannon"
                        wDef.turret = true
                        wDef.ballistic = false
                        wDef.gravityaffected = false
                    end
                end
            end

            -- Strip unnecessary visual effects
            uDef.sfxtypes = {}

            ::continue::
        end
    end
end
