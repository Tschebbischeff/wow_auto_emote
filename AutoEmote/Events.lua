local addonName, AutoEmote = ...

local function getUnitKey(unit)
    if AutoEmoteSettings._.uniqueTargets then
        return UnitGUID(unit)
    else
        local unitName, unitServer = UnitFullName(unit)
        if unitServer ~= nil then
            return unitName .. "-" .. unitServer
        else
            return unitName
        end
    end
end

local function getUnitType(unit)
    print(UnitPlayerControlled(unit))
    print(UnitIsPlayer(unit))
    print(UnitIsOtherPlayersPet(unit))
    print(UnitIsMinion(unit))
    if UnitIsPlayer(unit) then return "player" end
    if UnitIsMinion(unit) then return "minion" end
    return "other"
end

local function executeModule(moduleName, unitKey, unitType)
    if issecretvalue(unitKey) then
        if AutoEmoteSettings[moduleName].alwaysExecuteWhenRestricted then
            DoEmote(AutoEmoteSettings[moduleName].emote)
        end
        return
    end
    if AutoEmoteSettings[moduleName].enabled and not AutoEmoteDB[moduleName].cache[unitKey] then
        DoEmote(AutoEmoteSettings[moduleName].emote)
        AutoEmoteDB[moduleName].cache[unitKey] = true
        AutoEmoteDB[moduleName].stats[unitType] = AutoEmoteDB[moduleName].stats[unitType] + 1
    end
end

AutoEmote.onEvent("THIS_ADDON_LOADED", function(frame)
    AutoEmote.Settings.initialize()
end)

AutoEmote.onEvent("PLAYER_TARGET_CHANGED", function(frame)
    if not AutoEmoteSettings._.enabled then return end
    if not UnitExists("target") then return end
    local unitKey = getUnitKey("target")
    local unitType = getUnitType("target")
    -- Execute modules
    executeModule("lickAll", unitKey, unitType)
end)