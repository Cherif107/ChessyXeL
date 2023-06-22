local Object = require "ChessyXeL.display.object.Object"
local FieldStatus = require "ChessyXeL.FieldStatus"
local Method = require "ChessyXeL.Method"
local SpriteUtil = require "ChessyXeL.hscript.SpriteUtil"

---@class display.animation.Animation : display.object.Object
local Animation = Object.extend 'Animation'

Animation.parent = FieldStatus.PUBLIC('default', function (V, I)
    I.parent = V
    I.name = V.name..'.animation'
end, nil)

Animation.callback = FieldStatus.PUBLIC('default', function (V, I)
    I.callback = V
    SpriteUtil.setAnimationCallback(I.parent.name, V)
end, nil)

Animation.add = Method.PUBLIC(function (animation, name, frames, frameRate, loop)
    return animation.parent.addAnimation(name, frames, frameRate, loop)
end)
Animation.addByPrefix = Method.PUBLIC(function (animation, name, prefix, frameRate, loop)
    return animation.parent.addAnimationByPrefix(name, prefix, frameRate, loop)
end)
Animation.addByIndices = Method.PUBLIC(function (animation, name, prefix, indices, frameRate)
    return animation.parent.addAnimationByIndices(name, prefix, indices, frameRate)
end)
Animation.play = Method.PUBLIC(function (animation, name, forced, reversed, startFrame)
    return animation.parent.playAnim(name, forced, reversed, startFrame)
end)

Animation.new = function (parent)
    local animation = Animation.create()
    animation.parent = parent
    return animation
end

return Animation