local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Class = require 'ChessyXeL.Class'
local Color = require 'ChessyXeL.util.Color'
---@class text.TextFormat : Class
local TextFormat = Class 'TextFormat'

TextFormat.borderColor = FieldStatus.PUBLIC('default', function (V, I)
    I.borderColor = Color.normalize(V)
end, Color.TRANSPARENT)
TextFormat.fontColor = FieldStatus.PUBLIC('default',function (V, I)
    I.fontColor = Color.normalize(V)
end, Color.WHITE)
TextFormat.size = FieldStatus.PUBLIC('default', 'default')
TextFormat.bold = FieldStatus.PUBLIC('default', 'default', false)
TextFormat.italic = FieldStatus.PUBLIC('default', 'default', false)
TextFormat.new = function (fontColor, bold, italic, bordercolor, L)
    local format = TextFormat.create()
    format.borderColor = bordercolor or Color.TRANSPARENT
    format.fontColor = fontColor or Color.WHITE
    format.italic = italic
    format.bold = bold
    return format
end

return TextFormat