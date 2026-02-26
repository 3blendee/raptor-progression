-- Raptor Progression: Scavenger Economy (Slot 6)
-- Units and reclaim are the primary economy, not base-building converters
-- Advanced/epic converters still exist but are supplementary

do
    local unitDefs = UnitDefs or {}

    local function isRaptor(uDef)
        return uDef.customparams and uDef.customparams.subfolder == "other/raptors"
    end

    for name, uDef in pairs(unitDefs) do

        -- Skip raptors (handled separately for wreckage below)
        if isRaptor(uDef) then
            -- Boost raptor metalcost so wreckage is worth more when reclaimed
            if uDef.metalcost then
                uDef.metalcost = math.floor(uDef.metalcost * 1.5)
            end

            -- Make raptor corpses last longer before decaying
            if uDef.corpse then
                uDef.featuredefs = uDef.featuredefs or {}
                if uDef.featuredefs.dead then
                    uDef.featuredefs.dead.resurrectable = 0
                    -- Increase reclaim time to reward dedicated scavenging
                    uDef.featuredefs.dead.reclaimtime = (uDef.featuredefs.dead.reclaimtime or 100) * 0.7
                end
            end
            goto continue
        end

        -- Nerf metal makers / converters
        -- Detect by: immobile, makes metal, consumes energy, no weapons
        if not uDef.canmove and uDef.customparams then
            local isMaker = name:match("maker") or name:match("converter")
                         or name:match("moho") or name:match("claw")
            -- Also detect via high energy upkeep with metal make
            if not isMaker and uDef.energyupkeep and uDef.energyupkeep > 0
               and uDef.makesmetal and uDef.makesmetal > 0 then
                isMaker = true
            end
            -- Customparams-based detection for converters
            if not isMaker and uDef.customparams.unitgroup then
                local ug = uDef.customparams.unitgroup:lower()
                if ug:match("converter") or ug:match("maker") then
                    isMaker = true
                end
            end

            if isMaker then
                -- Converters cost 40% more energy to run
                if uDef.energyupkeep then
                    uDef.energyupkeep = math.floor(uDef.energyupkeep * 1.4)
                end
                -- Converters produce 30% less metal
                if uDef.makesmetal then
                    uDef.makesmetal = uDef.makesmetal * 0.7
                end
                -- Converters cost more to build
                if uDef.metalcost then
                    uDef.metalcost = math.floor(uDef.metalcost * 1.25)
                end
                goto continue
            end
        end

        -- Buff constructor reclaim speed (scavenging is rewarded)
        -- Only buff workertime for builders, not factories
        if uDef.canmove and uDef.workertime and uDef.workertime > 0 then
            -- 30% faster reclaim via higher workertime
            uDef.workertime = math.floor(uDef.workertime * 1.3)
        end

        -- Slight nerf to metal extractors (push toward reclaim economy)
        if not uDef.canmove and uDef.extractsmetal and uDef.extractsmetal > 0 then
            uDef.extractsmetal = uDef.extractsmetal * 0.85
        end

        ::continue::
    end

    -- Boost raptor wreckage metal values in FeatureDefs
    for name, fDef in pairs(FeatureDefs or {}) do
        if name:match("raptor_") then
            -- Wreckage contains 50% more metal
            if fDef.metal then
                fDef.metal = math.floor(fDef.metal * 1.5)
            end
            -- Wreckage takes slightly less time to reclaim (reward scavenging)
            if fDef.reclaimtime then
                fDef.reclaimtime = math.floor(fDef.reclaimtime * 0.7)
            end
        end
    end
end
