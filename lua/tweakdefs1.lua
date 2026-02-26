-- Raptor Progression: Queen Final Boss (Slot 1)
-- Satisfying endgame boss — appears around 25-30 min mark

for name, uDef in pairs(UnitDefs) do
    if name:match('^raptor_queen_.*') or name == "raptor_queen" then
        -- Double queen health for a challenging but beatable fight
        uDef.health = math.floor((uDef.health or 50000) * 2.0)

        -- Disable repair and healing — must be killed through raw damage
        uDef.repairable = false
        uDef.canbehealed = false

        -- Negligible regen (cosmetic only)
        uDef.autoheal = 2
        uDef.idleautoheal = 2

        -- No quick respawn — extremely long buildtime
        uDef.buildtime = 9999999

        -- Make queen worth significant reclaim
        uDef.metalcost = math.floor((uDef.metalcost or 5000) * 1.5)
    end
end
