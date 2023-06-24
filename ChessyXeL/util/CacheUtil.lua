local Object = require 'ChessyXeL.display.object.Object'
require 'ChessyXeL.util.StringUtil'
---@class util.CacheUtil
local CacheUtil = {}
CacheUtil = {
    forEach = function (directory, func)
        for index, file in pairs(directoryFileList(directory)) do
            if not file:find('%.') then
                CacheUtil.forEach(directory..'/'..file, func)
            else
                func(directory..'/'..file)
            end
        end
    end,
    sound = function (soundPath)
        return Object.waitingList.add(function ()
            return precacheSound(soundPath)
        end)
    end,
    image = function (imagePath)
        return Object.waitingList.add(function ()
            return precacheImage(imagePath)
        end)
    end,
    soundFolder = function (directory)
        Object.waitingList.add(function()
            CacheUtil.forEach(directory, function(sound)
                if sound:find('.ogg') then
                    CacheUtil.sound(sound:gsub('.ogg', ''):gsub('mods/sounds/', ''):gsub('assets/sounds/', ''):gsub('assets/shared/sounds/', ''))
                end
            end)
        end)
        return true
    end,
    imageFolder = function (directory)
        Object.waitingList.add(function()
            CacheUtil.forEach(directory, function(image)
                if image:find('.png') then
                    CacheUtil.image(image:gsub('.png', ''):gsub('mods/images/', ''):gsub('assets/images/', ''):gsub('assets/shared/images/', ''))
                    -- debugPrint(image:gsub('.png', ''):gsub('mods/images/', ''):gsub('assets/images/', ''):gsub('assets/shared/images/', ''))
                end
            end)
        end)
        return true
    end,
    folder = function (directory)
        Object.waitingList.add(function()
            CacheUtil.forEach(directory, function(image)
                if image:find('.png') then
                    CacheUtil.image(image:gsub('.png', ''))
                else
                    CacheUtil.sound(image:gsub('.ogg', ''))
                end
            end)
        end)
        return true
    end,
    cache = function (toCache)
        local caching = toCache:split(':')
        if caching[1] == 'folder' then
            if #caching > 2 then
                return CacheUtil[caching[2]:lower()..'Folder'](caching[3])
            end
            return CacheUtil.folder(caching[2])
        else
            return CacheUtil[caching[1]](caching[2])
        end
    end
}

return CacheUtil