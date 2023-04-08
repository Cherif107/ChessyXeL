local Sprite = require 'ChessyXeL.display.Sprite'
local Object = require 'ChessyXeL.display.object.Object'
local Method = require 'ChessyXeL.Method'
-- local FieldStatus = require 'ChessyXeL.FieldStatus'
local Color = require 'ChessyXeL.util.Color'
---@class display.text.Text : display.Sprite a Class that makes Texts
local Text = Sprite.extend 'Text'

Text.INITIALIZE_FUNCTION = function (tag, x, y, width, text)
    return Object.waitingList.add(function()
        makeLuaText(tag, text, width, x, y)
    end)
end
Text.override('add', function (super, txt, onTop)
    Object.waitingList.add(function ()
        addLuaText(txt.name, onTop)
    end)
    return txt
end)

Text.new = function (x, y, fieldWidth, text, size, color, font)
    local this = Text.create(x, y, 'DO NOT INITIALIZE')
    Text.INITIALIZE_FUNCTION(this.name, x, y, fieldWidth, text)
    Object.waitingList.add(function ()
        this.size = size or 14
        this.color = color or 0xFFffffff
        if font then
            this.font = font or 'vcr.ttf'
        end
    end)
    return this
end

return Text