local addonName, AutoEmote = ...
AutoEmote.Events = AutoEmote.Events or {}

-- Create main addon frame in addon namespace
AutoEmote.mainFrame = CreateFrame("Frame")

-- Make other files able to register separate functions per event
local function executeEventCallbacks(frame, event, ...)
    if AutoEmote.Events[event] ~= nil then
        for _, callback in ipairs(AutoEmote.Events[event]) do
            callback(frame, ...)
        end
    end
end
AutoEmote.mainFrame:SetScript("OnEvent", executeEventCallbacks)
function AutoEmote.onEvent(event, func)
    if event ~= "ADDON_LOADED" then
        if AutoEmote.Events[event] == nil then
            if event ~= "THIS_ADDON_LOADED" then
                AutoEmote.mainFrame:RegisterEvent(event)
            end
            AutoEmote.Events[event] = {}
        end
        table.insert(AutoEmote.Events[event], func)
    end
end
AutoEmote.mainFrame:RegisterEvent("ADDON_LOADED")
AutoEmote.Events["ADDON_LOADED"] = {function(frame, loadedAddonName)
    if loadedAddonName == addonName then
        -- Initialize Saved Variables tables
        AutoEmoteDB = AutoEmoteDB or {}
        AutoEmoteSettings = AutoEmoteSettings or {}
        -- Execute a proxy callback that other files can register only for THIS addon being loaded
        executeEventCallbacks(frame, "THIS_ADDON_LOADED")
        frame:UnregisterEvent("ADDON_LOADED")
    end
end}