local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Tween = require 'ChessyXeL.tweens.Tween'
local Color = require 'ChessyXeL.util.Color'
---@class tweens.misc.MultiMultiColorTween : tweens.Tween 
local MultiColorTween = Tween.extend 'MultiColorTween'
MultiColorTween.color = FieldStatus.PUBLIC('default', 'default')
MultiColorTween.sprite = FieldStatus.PUBLIC('default', 'default')
MultiColorTween.colors = FieldStatus.NORMAL('default', 'default')

MultiColorTween.override('destroy', function (super, tween)
    super(tween)
    tween.sprite = nil
end)
MultiColorTween.tween = Method.PUBLIC(function (tween, Duration, colors, Sprite)
    tween.colors = colors
    tween.color = colors[1]
    tween.duration = Duration
    tween.sprite = Sprite
    tween.start()
    return tween
end)
MultiColorTween.override('update', function (super, tween, elapsed)
    super(tween, elapsed);
    tween.color = Color.multiInterpolate(tween.colors, tween.scale);

    if (tween.sprite ~= nil) then
        tween.sprite.color = tween.color
        tween.sprite.alpha = tween.color.alphaFloat
    end
end)
MultiColorTween.override('isTweenOf', function (super, tween, object, field)
    return tween.sprite == object and (field == nil or field == "color")
end)

return MultiColorTween