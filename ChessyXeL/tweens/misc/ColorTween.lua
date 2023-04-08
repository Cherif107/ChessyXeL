local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Tween = require 'ChessyXeL.tweens.Tween'
local Color = require 'ChessyXeL.util.Color'
---@class tweens.misc.ColorTween : tweens.Tween 
local ColorTween = Tween.extend 'ColorTween'
ColorTween.color = FieldStatus.PUBLIC('default', 'default')
ColorTween.sprite = FieldStatus.PUBLIC('default', 'default')
ColorTween.startColor = FieldStatus.NORMAL('default', 'default')
ColorTween.endColor = FieldStatus.NORMAL('default', 'default')

ColorTween.override('destroy', function (super, tween)
    super(tween)
    tween.sprite = nil
end)
ColorTween.tween = Method.PUBLIC(function (tween, Duration, fromColor, toColor, Sprite)
    tween.startColor = fromColor
    tween.endColor = toColor
    tween.color = fromColor
    tween.duration = Duration
    tween.sprite = Sprite
    tween.start()
    return tween
end)
ColorTween.override('update', function (super, tween, elapsed)
    super(tween, elapsed);
    tween.color = Color.interpolate(tween.startColor, tween.endColor, tween.scale);

    if (tween.sprite ~= nil) then
        tween.sprite.color = tween.color
        tween.sprite.alpha = tween.color.alphaFloat
    end
end)
ColorTween.override('isTweenOf', function (super, tween, object, field)
    return tween.sprite == object and (field == nil or field == "color")
end)

return ColorTween