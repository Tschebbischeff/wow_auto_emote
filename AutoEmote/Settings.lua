local addonName, AutoEmote = ...
AutoEmote.Settings = {}

local layoutOpts = {
    padding = 8,
    margin = 8,
    scrollBarWidth = 18
}
local AutoEmoteSettingsVersion = 1
local AutoEmoteDBVersion = 1

local function checkInitializeSettings(t, settingName, defaultValue)
    AutoEmoteSettings._ = AutoEmoteSettings._ or {}
    if AutoEmoteSettings._.version == nil or AutoEmoteSettings._.version ~= AutoEmoteSettingsVersion then
        table.wipe(AutoEmoteSettings)
        AutoEmoteSettings._ = {}
    end
    AutoEmoteSettings._.version = AutoEmoteSettingsVersion
    if settingName == nil then return end
    if t[settingName] == nil then
        t[settingName] = defaultValue
    end
end

local function checkInitializeDatabase(t, settingName, defaultValue)
    AutoEmoteDB._ = AutoEmoteDB._ or {}
    if AutoEmoteDB._.version == nil or AutoEmoteDB._.version ~= AutoEmoteDBVersion then
        table.wipe(AutoEmoteDB)
        AutoEmoteDB._ = {}
    end
    AutoEmoteDB._.version = AutoEmoteDBVersion
    if settingName == nil then return end
    if t[settingName] == nil then
        t[settingName] = defaultValue
    end
end

local function createEmptyStats()
    return {
        other = 0,
        player = 0,
        minion = 0
    }
end

local function setTooltip(element, text)
    element:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(text, nil, nil, nil, nil, true)
        GameTooltip:Show()
    end)
    element:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

local function setSize(element, sizeX, sizeY)
    element:SetScript("OnShow", function(self)
        if sizeX < 0 then sizeX = self:GetParent():GetWidth() * (-sizeX) end
        if sizeY < 0 then sizeY = self:GetParent():GetHeight() * (-sizeY) end
        self:SetSize(sizeX, sizeY)
    end)
end

local function addTitle(frame, position, text)
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", position, "BOTTOMLEFT", 0, -layoutOpts.margin)
    title:SetText(text)

    local line = frame:CreateTexture(nil, "ARTWORK")
    setSize(line, -1.0, 2)
    line:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -layoutOpts.margin)
    line:SetColorTexture(1, 1, 1, 0.2) -- Subtle grey line

    return line
end

local function addText(frame, position, text)
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", position, "BOTTOMLEFT", 0, -layoutOpts.margin)
    title:SetText(text)

    return title
end

local function addTextDynamic(frame, position, getTextFunc)
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", position, "BOTTOMLEFT", 0, -layoutOpts.margin)
    title:SetText("")
    title:SetScript("OnShow", function(self)
        self:SetText(getTextFunc(self))
    end)

    return title
end

local function addCheckbox(frame, position, labelText, tooltipText, settingNamespace, settingName, defaultValue)
    checkInitializeSettings(AutoEmoteSettings[settingNamespace], settingName, defaultValue)

    local checkbox = CreateFrame("CheckButton", nil, frame, "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", position, "BOTTOMLEFT", 0, -layoutOpts.margin)
    checkbox:SetChecked(AutoEmoteSettings[settingNamespace][settingName])

    local label = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("LEFT", checkbox, "RIGHT", layoutOpts.margin, 0)
    label:SetText(labelText)

    setTooltip(checkbox, tooltipText)
    setTooltip(label, tooltipText)

    checkbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        AutoEmoteSettings[settingNamespace][settingName] = isChecked
        AutoEmote.Logging.debug("AutoEmoteSettings." .. settingNamespace .. "." .. settingName .. ":", isChecked)
    end)

    return checkbox
end

local function addButton(frame, position, labelText, tooltipText, onClick)
    local button = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
    button:SetSize(160, 26)
    button:SetPoint("TOPLEFT", position, "BOTTOMLEFT", 0, -layoutOpts.margin)
    button:SetText(labelText)

    setTooltip(button, tooltipText)

    button:SetScript("OnClick", onClick)

    return button
end

local function addHeader(frame, nextPosition)
    local mainTitle = frame:CreateFontString(nil, "ARTWORK", "Fancy22Font")
    mainTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    mainTitle:SetText(addonName .. " Settings")

    return mainTitle
end

local function addGeneralSettings(frame, nextPosition)
    checkInitializeSettings(AutoEmoteSettings._, "logLevel", 0)

    nextPosition = addTitle(frame, nextPosition, "General")
    nextPosition = addCheckbox(frame, nextPosition, "Enable", "Enable/ Disable the add-on completely.", "_", "enabled", true)
    nextPosition = addCheckbox(frame, nextPosition, "Unique Creatures", "Execute emote once for each unique target instead of once for each unique name of a target.", "_", "uniqueTargets", false)

    return nextPosition
end

local function addModuleSettings(frame, nextPosition, moduleName, emoteIdentifier)
    checkInitializeSettings(AutoEmoteSettings, moduleName, {})
    checkInitializeSettings(AutoEmoteSettings[moduleName], "enabled", true)
    checkInitializeSettings(AutoEmoteSettings[moduleName], "emote", emoteIdentifier)

    checkInitializeDatabase(AutoEmoteDB, moduleName, {})
    checkInitializeDatabase(AutoEmoteDB[moduleName], "cache", {})
    checkInitializeDatabase(AutoEmoteDB[moduleName], "stats", createEmptyStats())

    nextPosition = addTitle(frame, nextPosition, "Module '" .. moduleName .. "'")
    nextPosition = addTextDynamic(frame, nextPosition, function(self)
        return "Players: " .. AutoEmoteDB[moduleName].stats.player .. ", Pets & Minions: " .. AutoEmoteDB[moduleName].stats.minion .. ", Other: " .. AutoEmoteDB[moduleName].stats.other
    end)
    nextPosition = addCheckbox(frame, nextPosition, "Enable", "Enable/ Disable the '" .. moduleName .. "' module.", moduleName, "enabled", true)
    nextPosition = addCheckbox(frame, nextPosition, "Always execute in restricted context", "Always execute the module when no statistics can be inferred about the target due to WoW API restrictions (e.g. on enemies in instances)", moduleName, "alwaysExecuteWhenRestricted", false)
    nextPosition = addButton(frame, nextPosition, "Reset Data", "Clear the history of targets this module emoted at.", function()
        table.wipe(AutoEmoteDB[moduleName].cache)
        AutoEmoteDB[moduleName].stats = createEmptyStats()
        AutoEmote.Logging.debug("History for module '" .. moduleName .. "' has been cleared!")
    end)

    return nextPosition
end

function AutoEmote.Settings.initialize()
    checkInitializeSettings(AutoEmoteSettings)
    checkInitializeDatabase(AutoEmoteDB)
    -- local mainFrame = CreateFrame("Frame")
    -- mainFrame:SetSize(SettingsPanel.Container:GetWidth() - layoutOpts.padding, SettingsPanel.Container:GetHeight() - layoutOpts.padding)

    local mainFrame = CreateFrame("ScrollFrame", nil, nil, "UIPanelScrollFrameTemplate")
    mainFrame:SetSize(SettingsPanel.Container:GetWidth() - layoutOpts.padding, SettingsPanel.Container:GetHeight() - layoutOpts.padding)
    -- mainFrame:SetPoint("TOPLEFT", mainFrame, "BOTTOMRIGHT", 0, 0)
    -- mainFrame:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", 0, 0)

    local scrollChild = CreateFrame("Frame")
    mainFrame:SetScrollChild(scrollChild)
    scrollChild:SetWidth(SettingsPanel.Container:GetWidth() - layoutOpts.padding - layoutOpts.scrollBarWidth)
    scrollChild:SetHeight(SettingsPanel.Container:GetHeight() - layoutOpts.padding)

    local innerBox = scrollChild:CreateTexture(nil, "ARTWORK")
    setSize(innerBox, -1.0, -1.0)
    innerBox:SetPoint("TOPLEFT", 0, 0)
    innerBox:SetColorTexture(1, 1, 1, 0.0)

    local nextPosition = innerBox

    nextPosition = addHeader(scrollChild, nextPosition)
    nextPosition = addGeneralSettings(scrollChild, nextPosition)
    nextPosition = addModuleSettings(scrollChild, nextPosition, "lickAll", "LICK")

    Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(mainFrame, addonName))
end