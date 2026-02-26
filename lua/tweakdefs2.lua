-- Raptor Progression: Player Economy & Army Progression (Slot 2)
-- T1 spam early -> natural tech-up mid-game -> T3 endgame investment

do
    local unitDefs = UnitDefs or {}

    -- Detect tech level from customparams
    local function getTechLevel(uDef)
        if uDef.customparams and uDef.customparams.techlevel then
            return tonumber(uDef.customparams.techlevel)
        end
        return nil
    end

    local function isRaptor(uDef)
        return uDef.customparams and uDef.customparams.subfolder == "other/raptors"
    end

    -- Tier scaling for player units
    local TIER_COST = {
        [1] = 0.80,   -- T1: cheap for early spam
        [2] = 1.0,    -- T2: standard
        [3] = 1.10,   -- T3: investment cost
    }

    local TIER_HP = {
        [1] = 1.1,    -- T1: slightly tanky
        [2] = 1.05,   -- T2: modest buff
        [3] = 1.15,   -- T3: durable payoff
    }

    -- Commander unit names
    local commanders = {}
    for _, prefix in ipairs({"armcom", "corcom", "legcom"}) do
        commanders[prefix] = true
        for lvl = 1, 10 do
            commanders[prefix .. "lvl" .. lvl] = true
        end
    end

    for name, uDef in pairs(unitDefs) do
        -- Skip raptor units
        if isRaptor(uDef) then
            goto continue
        end

        -- Commander shield: early survival tool
        if commanders[name] then
            if not uDef.weapondefs then
                uDef.weapondefs = {}
            end
            uDef.weapondefs.progshield = {
                name = "ProgressionShield",
                weapontype = "Shield",
                shieldpower = 500,
                shieldpowerregen = 15,
                shieldpowerregenenergy = 5,
                shieldradius = 100,
                shieldrepulser = 0,
                smartshield = 1,
                visibleshield = 1,
                visibleshieldrepulse = 0,
                shieldstartingpower = 500,
                shieldintercepttype = 1,
            }
            -- Add shield to weapons list if not present
            if not uDef.weapons then
                uDef.weapons = {}
            end
            local hasShield = false
            for _, w in ipairs(uDef.weapons) do
                if w.def == "progshield" then
                    hasShield = true
                    break
                end
            end
            if not hasShield then
                table.insert(uDef.weapons, { def = "progshield" })
            end
            goto continue
        end

        -- Factory build speed by tech level
        -- T1 factories pump units fast on their own
        -- T2/T3 factories need nano turret assistance
        if uDef.buildoptions and #uDef.buildoptions > 0
           and (not uDef.canmove or (uDef.speed and uDef.speed == 0)) then
            local factoryTL = getTechLevel(uDef) or 1
            if uDef.workertime then
                if factoryTL <= 1 then
                    -- T1 factories: 80% faster build speed
                    uDef.workertime = math.floor(uDef.workertime * 1.8)
                elseif factoryTL == 2 then
                    -- T2 factories: 20% faster, still want nano help
                    uDef.workertime = math.floor(uDef.workertime * 1.2)
                else
                    -- T3 factories: 10% faster, really need nanos
                    uDef.workertime = math.floor(uDef.workertime * 1.1)
                end
            end
            goto continue
        end

        -- Only modify mobile player units
        if not uDef.canmove or (uDef.speed and uDef.speed == 0) then
            goto continue
        end

        -- Flying builders: remove self-destruct explosion (QoL)
        if uDef.canfly and uDef.workertime and uDef.workertime > 0 then
            if uDef.weapondefs then
                for wname, wDef in pairs(uDef.weapondefs) do
                    if wname:match("selfd") or wname:match("self_d") then
                        if wDef.damage then
                            for dtype, _ in pairs(wDef.damage) do
                                wDef.damage[dtype] = 0
                            end
                        end
                    end
                end
            end
        end

        -- Apply tier-based scaling to mobile combat units
        local tl = getTechLevel(uDef)
        if tl and TIER_COST[tl] then
            if uDef.metalcost then
                uDef.metalcost = math.floor(uDef.metalcost * TIER_COST[tl])
            end
            if uDef.energycost then
                uDef.energycost = math.floor(uDef.energycost * TIER_COST[tl])
            end
            if uDef.health then
                uDef.health = math.floor(uDef.health * (TIER_HP[tl] or 1.0))
            end
        end

        ::continue::
    end

    -- Commander corpses: indestructible (so players don't lose reclaim incentive)
    for name, fDef in pairs(FeatureDefs or {}) do
        if name:match("armcom") or name:match("corcom") or name:match("legcom") then
            fDef.damage = 9999999
            fDef.reclaimable = 0
        end
    end
end
