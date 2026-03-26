local addonName, AutoEmote = ...

AutoEmote.onEvent("THIS_ADDON_LOADED", function(frame)
    AutoEmote.Settings.initialize()
end)

AutoEmote.onEvent("PLAYER_TARGET_CHANGED", function(frame)
    if not AutoEmoteSettings._.enabled then return end
    if UnitExists("target") and not UnitIsDead("target") and not InCombatLockdown() then
        local unitName = nil
        local unitServer = nil
        unitName, unitServer = UnitFullName("target")
        -- unitName = unitName .. ""
        -- print(type(unitName))
        -- if not unitName then return end
        local key = nil
        if unitServer ~= nil then key = unitName .. "-" .. unitServer else key = unitName end

        local unitType = "other"
        if UnitIsPlayer("target") then unitType = "player" end
        if (UnitPlayerControlled("target") and not UnitIsPlayer("target")) or UnitIsOtherPlayersPet("target") then unitType = "pet" end
        if UnitIsMinion("target") then unitType = "minion" end

        if AutoEmoteSettings.lickAll.enabled and not AutoEmoteDB.lickAll.cache[key] then
            DoEmote("LICK")
            AutoEmoteDB.lickAll.cache[key] = true
            AutoEmoteDB.lickAll.stats[unitType] = AutoEmoteDB.lickAll.stats[unitType] + 1
        end
    end
end)