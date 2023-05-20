local File = require 'ChessyXeL.util.File'
local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Sprite = require 'ChessyXel.display.Sprite'
local Text = require 'ChessyXel.display.text.Text'
require 'ChessyXeL.util.StringUtil'

---@class util.Save
local Save = Class 'Save'

Save.serialize = Method.PUBLIC(function(selF, value)
    if type(value) == 'table' then
        if value.__type == 'Sprite' then
            return {'__chessyxel__serialized__sprite__', {
                x = value.x,
                y = value.y,
                scale = {x = value.scale.x, y = value.scale.y},
                angle = value.angle,
                imagePath = value.graphic.assetKey
            }}
        elseif value.__type == 'Text' then
            return {'__chessyxel__serialized__text__', {
                x = value.x,
                y = value.y,
                scale = {x = value.scale.x, y = value.scale.y},
                angle = value.angle,
                text = value.text,
                font = value.font,
                color = value.color.value,
                borderColor = value.borderColor.value,
                size = value.size
            }}
        end
    end
    return value
end, true)
Save.name = FieldStatus.PUBLIC('default', 'default', 'System')
Save.savePath = FieldStatus.PUBLIC('default', 'default', 'ChessyXeL/saves')
Save.data = FieldStatus.PUBLIC('default', 'default', {})
Save.flush = Method.PUBLIC(function(save)
    File.save(save.savePath..'/'..save.name..'.lua', 'local Save = '..string.fromTable(save.data)..'\n\nreturn Save')
end)
Save.new = function (saveName)
    local save = Save.create()
    save.name = saveName or 'System'

    if not File.exists(save.savePath..'/'..save.name..'.lua') then
        File.save(save.savePath..'/'..save.name..'.lua', 'local Save = {}\nreturn Save')
    end
    save.data = setmetatable(dofile(save.savePath..'/'..save.name..'.lua'), {
        __index = function(i, f)
            if rawget(i, f) == nil then
                save.data = dofile(save.savePath..'/'..save.name..'.lua')
                return save.data[i]
            end
            return rawget(i, f)
        end
    })
    return save
end

return Save