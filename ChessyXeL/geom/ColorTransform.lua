local LogClass = require 'ChessyXeL.util.LogClass'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Color = require 'ChessyXeL.util.Color'

---@class geom.ColorTransform : util.LogClass 
local ColorTransform = LogClass.extend 'ColorTransform'

ColorTransform.alphaOffset = FieldStatus.PUBLIC('default', 'default', 0)
ColorTransform.redOffset = FieldStatus.PUBLIC('default', 'default', 0)
ColorTransform.greenOffset = FieldStatus.PUBLIC('default', 'default', 0)
ColorTransform.blueOffset = FieldStatus.PUBLIC('default', 'default', 0)

ColorTransform.alphaMultiplier = FieldStatus.PUBLIC('default', 'default', 1)
ColorTransform.redMultiplier = FieldStatus.PUBLIC('default', 'default', 1)
ColorTransform.greenMultiplier = FieldStatus.PUBLIC('default', 'default', 1)
ColorTransform.blueMultiplier = FieldStatus.PUBLIC('default', 'default', 1)
ColorTransform.parent = FieldStatus.PUBLIC('default', 'default', nil)

ColorTransform.override('onSetLog', function (super, Self, transform, field, value)
    if transform.parent then
        transform.parent.colorTransform = transform
    end
end) 

ColorTransform.color = FieldStatus.PUBLIC(function (transform)
    return Color.fromRGB(transform.redOffset, transform.greenOffset, transform.blueOffset, transform.alphaOffset)
end,
function (color, transform)
    color = Color.normalize(color)

    transform.alphaMultiplier = color.alpha
    transform.redOffset = color.red
    transform.greenOffset = color.green
    transform.blueOffset = color.blue

    transform.alphaMultiplier, transform.redMultiplier, transform.greenMultiplier, transform.blueMultiplier = 1, 0, 0, 0
    return color
end)

ColorTransform.hasRGBOffsets = Method.PUBLIC(function (transform)
    return (transform.redOffset ~= 0 or transform.blueOffset ~= 0 or transform.greenOffset ~= 0 or transform.alphaOffset ~= 0)
end)
ColorTransform.new = function (redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset)
    local transform = ColorTransform.create()
    transform.redMultiplier = redMultiplier or 1
    transform.greenMultiplier = greenMultiplier or 1
    transform.blueMultiplier = blueMultiplier or 1
    transform.alphaMultiplier = alphaMultiplier or 1
    transform.redOffset = redOffset or 0
    transform.greenOffset = greenOffset or 0
    transform.blueOffset = blueOffset or 0
    transform.alphaOffset = alphaOffset or 0
    return transform
end 

return ColorTransform