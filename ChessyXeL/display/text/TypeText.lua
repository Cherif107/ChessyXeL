local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Text = require 'ChessyXeL.display.text.Text'
local Timer = require 'ChessyXeL.util.Timer'

---@class display.text.TypeText : display.text.Text
local TypeText = Text.extend 'TypeText'

TypeText.typeText = FieldStatus.PUBLIC('default', 'default', '')
TypeText._text = FieldStatus.PUBLIC(function (I)
    return I.typeText:sub(1, I.textPosition)
end, 'never', '')
TypeText.textPosition = FieldStatus.PUBLIC('default', 'default', 0)
TypeText.timer = FieldStatus.PUBLIC('default', 'default', nil)

TypeText.onType = FieldStatus.PUBLIC('default', 'default', nil)
TypeText.onComplete = FieldStatus.PUBLIC('default', 'default', nil)
TypeText.start = Method.PUBLIC(function (typetext, timer)
    typetext.textPosition = 0
    typetext.timer.start(timer / #typetext.typeText, function (tmr)
        typetext.textPosition = typetext.textPosition + 1
        typetext.text = typetext._text
        if typetext.onType then
            typetext.onType(typetext.typeText:sub(typetext.textPosition, typetext.textPosition))
        end
        if typetext.textPosition < #typetext.typeText then
            -- tmr.reset(timer / #typetext.typeText)
        else
            if typetext.onComplete then
                typetext.onComplete(typetext)
            end
        end
    end, #typetext.typeText)
    return true
end)

TypeText.new = function (x, y, width, text, size, color, font)
    local tp = TypeText.create(x, y, width, '', size, color, font)
    tp.typeText = text
    tp.timer = Timer()
    return tp
end

return TypeText