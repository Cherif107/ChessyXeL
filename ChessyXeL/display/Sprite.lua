local Object = require 'ChessyXeL.display.object.Object'
local ObjectField = require 'ChessyXeL.display.object.Field'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Color = require 'ChessyXeL.util.Color'

---@class display.Sprite:display.object.Object A Class that makes sprites and returns them as Objects
local Sprite = Object.extend 'Sprite'

Sprite.INITIALIZE_FUNCTION = function (tag, image, x, y)
    return Object.waitingList.add(function()
        makeLuaSprite(tag, image, x, y)
    end)
end
Sprite.animated = FieldStatus.PUBLIC(function(I, F) return I.numFrames > 1 end, 'never', false, false)
Sprite.animation = FieldStatus.PUBLIC(function(I, F)
    if I.animation == '?' then
        I.animation = ObjectField(ObjectField.parseIndex(I.name, F))
        I.animation.rawAdd('add', I.addAnimation)
        I.animation.rawAdd('addByPrefix', I.addAnimationByPrefix)
        I.animation.rawAdd('addByIndices', I.addAnimationByIndices)
        I.animation.rawAdd('play', I.playAnim)
    end
    return I.animation
end, 'default', '?')
Sprite.color = FieldStatus.PUBLIC(function(I, F) return Color(Object.waitingList.approve(I.color, 0)) end, function (V, I, F)
    I.set('color', Color.parseColor(V))
end, Color.WHITE, false)
Sprite.camera = FieldStatus.PUBLIC('default', function (V, I, F)
    I.camera = V
    return Object.waitingList.add(function ()
        setObjectCamera(I.name, V)
    end)
end, 'camGame', false)
Sprite.blend = FieldStatus.PUBLIC('default', function (V, I, F)
    I.blend = V
    return Object.waitingList.add(function ()
        setBlendMode(I.name, V)
    end)
end, 'NORMAL', false)
Sprite.frames = FieldStatus.PUBLIC('default', function (V, I, F)
    I.frames = V
    return Object.waitingList.add(function ()
        loadFrames(I.name, V)
    end)
end)

Sprite.add = Method.PUBLIC(function (sprite, onTop)
    Object.waitingList.add(function ()
        addLuaSprite(sprite.name, onTop)
    end)
    return sprite
end)
Sprite.loadGraphic = Method.PUBLIC(function (sprite, image)
    Object.waitingList.add(function ()
        loadGraphic(sprite.name, image)
    end)
    return sprite
end)
Sprite.makeGraphic = Method.PUBLIC(function (sprite, width, height, color)
    Object.waitingList.add(function ()
        makeGraphic(sprite.name, width, height, Color.normalize(color).hex)
    end)
    return sprite
end)
Sprite.screenCenter = Method.PUBLIC(function (sprite, axes)
    Object.waitingList.add(function ()
        screenCenter(sprite.name, axes)
    end)
    return sprite
end)
Sprite.setGraphicSize = Method.PUBLIC(function (sprite, width, height)
    Object.waitingList.add(function ()
        setGraphicSize(sprite.name, width, height)
    end)
    return sprite
end)
Sprite.updateHitbox = Method.PUBLIC(function (sprite)
    Object.waitingList.add(function ()
        updateHitbox(sprite.name)
    end)
    return sprite
end)

Sprite.addAnimation = Method.PUBLIC(function (sprite, name, frames, frameRate, loop)
    Object.waitingList.add(function ()
        addAnimation(sprite.name, name, frames, frameRate, loop)
    end)
    return sprite
end)
Sprite.addAnimationByPrefix = Method.PUBLIC(function (sprite, name, prefix, frameRate, loop)
    Object.waitingList.add(function ()
        addAnimationByPrefix(sprite.name, name, prefix, frameRate, loop)
    end)
    return sprite
end)
Sprite.addAnimationByIndices = Method.PUBLIC(function (sprite, name, prefix, indices, frameRate)
    Object.waitingList.add(function ()
        addAnimationByIndices(sprite.name, name, prefix, indices, frameRate)
    end)
    return sprite
end)
Sprite.playAnim = Method.PUBLIC(function (sprite, name, forced, reversed, startFrame)
    Object.waitingList.add(function ()
        playAnim(sprite.name, name, forced, reversed, startFrame)
    end)
    return sprite
end)

-- Sprite.getMidpoint()

Sprite.new = function (x, y, a)
    local sprite = Sprite.create()
    if a ~= 'DO NOT INITIALIZE' then
        Sprite.INITIALIZE_FUNCTION(sprite.name, '', x, y)
    end
    return sprite
end

return Sprite