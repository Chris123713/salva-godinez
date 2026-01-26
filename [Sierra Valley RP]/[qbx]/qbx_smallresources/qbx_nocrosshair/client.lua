-- Disable weapon crosshairs/reticles
-- HUD Component 14 = Weapon Wheel Reticle/Crosshair

CreateThread(function()
    while true do
        if cache.weapon then
            HideHudComponentThisFrame(14) -- Hides the crosshair/reticle
        end
        Wait(0)
    end
end)
