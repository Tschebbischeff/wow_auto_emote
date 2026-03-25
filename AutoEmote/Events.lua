local addonName, AutoEmote = ...

AutoEmote.onEvent("THIS_ADDON_LOADED", function(frame)
    AutoEmote.Settings.initialize()
end)

AutoEmote.onEvent("PLAYER_TARGET_CHANGED", function(frame)
    if not AutoEmoteSettings._.enabled then return end
    if UnitExists("target") and not UnitIsDead("target") then
        local guid = UnitGUID("target")
        if AutoEmoteSettings.lickAll.enabled and not AutoEmoteDB.lickAll[guid] then
            DoEmote("LICK")
            AutoEmoteDB.lickAll[guid] = true
        end
    end
end)