local addonName, AutoEmote = ...
AutoEmote.Logging = {}

local logLevels = {
    verbose = 0,
    debug = 1,
    info = 2,
    warning = 3,
    error = 4
}

function AutoEmote.Logging.verbose(...)
    if AutoEmoteSettings._.logLevel <= logLevels.verbose then
        print("|cff00ff00[AutoEmote/V]:|r", ...)
    end
end

function AutoEmote.Logging.debug(...)
    if AutoEmoteSettings._.logLevel <= logLevels.debug then
        print("|cff00ff00[AutoEmote/D]|r", ...)
    end
end

function AutoEmote.Logging.info(...)
    if AutoEmoteSettings._.logLevel <= logLevels.info then
        print("|cff00ff00[AutoEmote/I]|r", ...)
    end
end

function AutoEmote.Logging.warning(...)
    if AutoEmoteSettings._.logLevel <= logLevels.warning then
        print("|cff00ff00[AutoEmote/W]|r", ...)
    end
end

function AutoEmote.Logging.error(...)
    if AutoEmoteSettings._.logLevel <= logLevels.error then
        print("|cff00ff00[AutoEmote/E]|r", ...)
    end
end