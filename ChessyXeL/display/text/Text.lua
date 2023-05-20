local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Sprite = require 'ChessyXeL.display.Sprite'
local Object = require 'ChessyXeL.display.object.Object'
local Color = require 'ChessyXeL.util.Color'
local TextUtil = require 'ChessyXeL.hscript.TextUtil'

---@class display.text.Text : display.Sprite a Class that makes Texts
local Text = Sprite.extend 'Text'

Text.INITIALIZE_FUNCTION = function (tag, x, y, width, text)
    return Object.waitingList.add(function()
        makeLuaText(tag, text, width, x, y)
    end)
end
Text.fromTag = Method.PUBLIC(function(Self, tag)
    local txt = Text()
    txt.name = tag
    return txt
end,  true)
Text.override('add', function (super, txt, onTop)
    Object.waitingList.add(function ()
        addLuaText(txt.name, onTop)
    end)
    return txt
end)
Text.override('revive', function (super, txt)
    Object.waitingList.add(function ()
        addLuaText(txt.name)
    end)
    return txt
end)
Text.override('destroy', function (super, txt)
    Object.waitingList.add(function ()
        removeLuaText(txt.name)
    end)
    return txt
end)
Text.override('kill', function (super, txt)
    Object.waitingList.add(function ()
        removeLuaText(txt.name, false)
    end)
    return txt
end)
Text.applyMarkup = Method.PUBLIC(function (text, input, rules)
    Object.waitingList.add(function ()
        TextUtil.applyMarkup(text.name, input, rules)
    end)
    return text
end)

Text.borderColor = FieldStatus.PUBLIC(function(I, F) return Color(getProperty(I.name..'.borderColor')) end, function (V, I, F)
    I.set('borderColor', Color.parseColor(V))
end, Color.BLACK, false)
Text.font = FieldStatus.PUBLIC('default', function (V, text, F)
    text.font = V
    Object.waitingList.add(function ()
        setTextFont(text.name, V)
    end)
end, 'vcr.ttf')
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