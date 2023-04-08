local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Tween = require 'ChessyXeL.tweens.Tween'
---@class tweens.misc.NumTween : tweens.Tween 
local NumTween = Tween.extend 'NumTween'

NumTween.value = FieldStatus.PUBLIC('default', 'default')

NumTween._tweenFunction = FieldStatus.NORMAL('default', 'default')
NumTween._start = FieldStatus.NORMAL('default', 'default')
NumTween._range = FieldStatus.NORMAL('default', 'default')

NumTween.override('destroy', function (super, tween)
    super(tween)
    tween._tweenFunction = nil
end)
NumTween.override('update', function (super, tween, elapsed)
    super(tween, elapsed)
    tween.value = tween._start + tween._range * tween.scale
    if tween._tweenFunction ~= nil then
        tween._tweenFunction(tween.value)
    end
end)

NumTween.tween = Method.PUBLIC(function (tween, fromValue, toValue, duration, tweenFunction)
    tween.value = fromValue
    tween.duration = duration
    tween._tweenFunction = tweenFunction
    tween._start = fromValue 
    tween._range = toValue - tween.value
    tween.start()
    return tween
end)

return NumTween