local Object = require "ChessyXeL.display.object.Object"
local ObjectField = require "ChessyXeL.display.object.Field"
local FieldStatus = require "ChessyXeL.FieldStatus"
local Method = require "ChessyXeL.Method"
local Color = require "ChessyXeL.util.Color"
local HScript = require "ChessyXeL.hscript.HScript"
local SpriteUtil = require "ChessyXeL.hscript.SpriteUtil"
local Point = require "ChessyXeL.math.Point"
local ColorTransform = require "ChessyXeL.geom.ColorTransform"
local Animation = require "ChessyXeL.display.animation.Animation"
local Log = require 'ChessyXeL.debug.Log'
local Game

---@class display.Sprite:display.object.Object A Class that makes sprites and returns them as Objects
local Sprite = Object.extend "Sprite"

Sprite.INITIALIZE_FUNCTION = function(tag, image, x, y)
    return Object.waitingList.add(
        function()
            makeLuaSprite(tag, image, x, y)
        end
    )
end
Sprite.animated =
    FieldStatus.PUBLIC(
    function(I, F)
        return I.numFrames > 1
    end,
    "never",
    false,
    false
)
Sprite.animation =
    FieldStatus.PUBLIC(
    "default",
    "default",
    nil
)
Sprite.color =
    FieldStatus.PUBLIC(
    function(I, F)
        if not I.color then
            return nil
        end
        Object.waitingList.add(function()
            I.color.value = Color.parseColor(getProperty(I.name .. ".color"))
        end)
        return I.color
    end,
    function(V, I, F)
        I.set("color", Color.parseColor(V))
        if not I.color then
            I.color = V
        end
        return true
    end,
    nil,
    false
)
Sprite.colorTransform =
    FieldStatus.PUBLIC('default',
    function(transform, I, F)
        if I.colorTransform == nil then I.colorTransform = transform return end
        I.color = Color.fromRGBFloat(transform.redMultiplier, transform.greenMultiplier, transform.blueMultiplier).to24Bit()

        I.set('colorTransform.alphaMultiplier', transform.alphaMultiplier)
        I.set('colorTransform.redMultiplier', transform.redMultiplier)
        I.set('colorTransform.greenMultiplier', transform.greenMultiplier)
        I.set('colorTransform.blueMultiplier', transform.blueMultiplier)

        I.set('colorTransform.alphaOffset', transform.alphaOffset)
        I.set('colorTransform.redOffset', transform.redOffset)
        I.set('colorTransform.greenOffset', transform.greenOffset)
        I.set('colorTransform.blueOffset', transform.blueOffset)

        Object.waitingList.approve(function() I.useColorTransform = (I.alpha ~= 1 or I.color.value ~= 0xffffff or I.hasRGBOffsets()) end)
        I.dirty = true
    end,
    nil,
    false
)
Sprite.camera =
    FieldStatus.PUBLIC(
    "default",
    function(V, I, F)
        I.camera = V
        return Object.waitingList.add(
            function()
                if I.alive then
                    setObjectCamera(I.name, V)
                end
            end
        )
    end,
    "camGame",
    false
)
Sprite.order =
    FieldStatus.PUBLIC(
    function(I)
        if getObjectOrder then
            return getObjectOrder(I.name)
        end
        return I.order
    end,
    function(V, I, F)
        I.order = V
        return Object.waitingList.add(
            function()
                if I.alive then
                    setObjectOrder(I.name, V)
                end
            end
        )
    end,
    0,
    false
)
Sprite.blend =
    FieldStatus.PUBLIC(
    "default",
    function(V, I, F)
        I.blend = V
        return Object.waitingList.add(
            function()
                setBlendMode(I.name, V)
            end
        )
    end,
    "NORMAL",
    false
)
Sprite.shader =
    FieldStatus.PUBLIC(
    "default",
    function(shader, I, F)
        I.shader = shader.copyToObject(I)
        if I.shader == nil then debugPrint('hi') end
        Object.waitingList.add(
            function()
                setSpriteShader(I.name, I.shader.shaderPath)
            end
        )
        return I
    end
)
Sprite.frames =
    FieldStatus.PUBLIC(
    "default",
    function(V, I, F)
        I.frames = V
        return Object.waitingList.add(
            function()
                loadFrames(I.name, V)
            end
        )
    end
)

Sprite.revive =
    Method.PUBLIC(
    function(sprite)
        if Log.logger.enabled and Log.logObjects then
            Log.logger.log('Sprite of ID '..sprite.name..' was Revived')
        end
        Object.waitingList.add(
            function()
                addLuaSprite(sprite.name)
            end
        )
        return sprite
    end
)
Sprite.add =
    Method.PUBLIC(
    function(sprite, onTop)
        if Log.logger.enabled and Log.logObjects then
            Log.logger.log('Sprite of ID '..sprite.name..' was Added')
        end
        Object.waitingList.add(
            function()
                addLuaSprite(sprite.name, onTop)
            end
        )
        return sprite
    end
)
Sprite.override(
    "destroy",
    function(super, sprite)
        super()
        if Log.logger.enabled and Log.logObjects then
            Log.logger.log('Sprite of ID '..sprite.name..' was Destroyed')
        end
        if sprite.__type ~= "Text" then
            Object.waitingList.add(
                function()
                    removeLuaSprite(sprite.name)
                end
            )
        end
        return sprite
    end
)
Sprite.kill =
    Method.PUBLIC(
    function(sprite)
        if Log.logger.enabled and Log.logObjects then
            Log.logger.log('Sprite of ID '..sprite.name..' was Killed')
        end
        Object.waitingList.add(
            function()
                removeLuaSprite(sprite.name, false)
            end
        )
        return sprite
    end
)
Sprite.loadGraphic =
    Method.PUBLIC(
    function(sprite, image)
        Object.waitingList.add(
            function()
                loadGraphic(sprite.name, image)
            end
        )
        return sprite
    end
)
Sprite.loadFrames =
    Method.PUBLIC(
    function(sprite, image)
        Object.waitingList.add(
            function()
                loadFrames(sprite.name, image)
            end
        )
        return sprite
    end
)
Sprite.makeGraphic =
    Method.PUBLIC(
    function(sprite, width, height, color)
        Object.waitingList.add(
            function()
                makeGraphic(sprite.name, width, height, Color.normalize(color).hex)
            end
        )
        return sprite
    end
)
Sprite.screenCenter =
    Method.PUBLIC(
    function(sprite, axes)
        Object.waitingList.add(
            function()
                screenCenter(sprite.name, axes)
            end
        )
        return sprite
    end
)
Sprite.setGraphicSize =
    Method.PUBLIC(
    function(sprite, width, height)
        Object.waitingList.add(
            function()
                setGraphicSize(sprite.name, width, height)
            end
        )
        return sprite
    end
)
Sprite.updateHitbox =
    Method.PUBLIC(
    function(sprite)
        Object.waitingList.add(
            function()
                updateHitbox(sprite.name)
            end
        )
        return sprite
    end
)

Sprite.getScreenPosition =
    Method.PUBLIC(
    function(sprite, result, camera)
        Game = Game or require "ChessyXeL.Game"
        camera = camera or Game.FlxG.camera
        result = result or Point.get()

        result.set(sprite.x, sprite.y)
        if (sprite.pixelPerfectPosition) then
            result.floor()
        end

        return result.subtract(
            (camera.scroll.x or 0) * sprite.scrollFactor.x,
            (camera.scroll.y or 0) * sprite.scrollFactor.y
        )
    end
)
Sprite.overlapsPoint =
    Method.PUBLIC(
    function(sprite, point, inscreenSpace, camera)
        Game = Game or require "ChessyXeL.Game"
        if not inscreenSpace then
            return (point.x >= sprite.x) and (point.x < sprite.x + sprite.width) and (point.y >= sprite.y) and
                (point.y < sprite.y + sprite.height)
        end
        camera = camera or Game.FlxG.camera

        local xPos = point.x - (camera.scroll.x or 0)
        local yPos = point.y - (camera.scroll.y or 0)
        sprite.getScreenPosition(point, camera)
        point.putWeak()
        return (xPos >= point.x) and (xPos < point.x + sprite.width) and (yPos >= point.y) and
            (yPos < point.y + sprite.height)
    end
)

Sprite.overlaps = Method.PUBLIC(function (sprite, object)
    return objectsOverlap(sprite.name, object.name)
end)

Sprite.addAnimation =
    Method.PUBLIC(
    function(sprite, name, frames, frameRate, loop)
        Object.waitingList.add(
            function()
                addAnimation(sprite.name, name, frames, frameRate, loop)
            end
        )
        return sprite
    end
)
Sprite.addAnimationByPrefix =
    Method.PUBLIC(
    function(sprite, name, prefix, frameRate, loop)
        Object.waitingList.add(
            function()
                addAnimationByPrefix(sprite.name, name, prefix, frameRate, loop)
            end
        )
        return sprite
    end
)
Sprite.addAnimationByIndices =
    Method.PUBLIC(
    function(sprite, name, prefix, indices, frameRate)
        Object.waitingList.add(
            function()
                addAnimationByIndices(sprite.name, name, prefix, indices, frameRate)
            end
        )
        return sprite
    end
)
Sprite.playAnim =
    Method.PUBLIC(
    function(sprite, name, forced, reversed, startFrame)
        Object.waitingList.add(
            function()
                playAnim(sprite.name, name, forced, reversed, startFrame)
            end
        )
        return sprite
    end
)

Sprite.alphaMask =
    Method.PUBLIC(
    function(sprite, sprite2)
        SpriteUtil.alphaMask(sprite.name, sprite2.name)
        return sprite
    end
)
Sprite.alphaMaskPosition =
    Method.PUBLIC(
    function(sprite, sprite2, x, y, output)
        SpriteUtil.alphaMaskPosition(sprite.name, sprite2.name, x, y, output.name)
        return sprite
    end
)
Sprite.drawGradient =
    Method.PUBLIC(
    function(sprite, width, height, colors, chunkSize, rotation, interpolate)
        for i = 1, #colors do
            colors[i] = Color.parseColor(colors[i])
        end
        Object.waitingList.add(
            function()
                SpriteUtil.drawGradient(sprite.name, width, height, colors, chunkSize, rotation, interpolate)
            end
        )
        return sprite
    end
)
Sprite.drawPolygon =
    Method.PUBLIC(
    function(sprite, vertices, fillColor, lineStyle, drawStyle)
        Object.waitingList.add(
            function()
                SpriteUtil.drawPolygon(sprite.name, vertices, fillColor, lineStyle, drawStyle)
            end
        )
        return sprite
    end
)
Sprite.drawCircle =
    Method.PUBLIC(
    function(sprite, X, Y, Radius, fillColor, lineStyle, drawStyle)
        Object.waitingList.add(
            function()
                SpriteUtil.drawCircle(sprite.name, X, Y, Radius, fillColor, lineStyle, drawStyle)
            end
        )
        return sprite
    end
)
Sprite.drawPolygonWithTexture =
    Method.PUBLIC(
    function(sprite, vertices, texture, lineStyle, drawStyle)
        Object.waitingList.add(
            function()
                SpriteUtil.drawPolygonWithTexture(sprite.name, vertices, texture, lineStyle, drawStyle)
            end
        )
        return sprite
    end
)
Sprite.drawCurve =
    Method.PUBLIC(
    function(sprite, startX, startY, endX, endY, controlX, controlY, fillColor, lineStyle, drawStyle)
        Object.waitingList.add(
            function()
                SpriteUtil.drawCurve(
                    sprite.name,
                    startX,
                    startY,
                    endX,
                    endY,
                    controlX,
                    controlY,
                    fillColor,
                    lineStyle,
                    drawStyle
                )
            end
        )
        return sprite
    end
)

Sprite.call = Method.PUBLIC(function (spr, functionName, ...)
    local a = {...}
    Object.waitingList.add(function ()
        SpriteUtil.callFromSprite(spr.name, functionName, unpack(a))
    end)
end)

-- Sprite.getMidpoint()

Sprite.fromTag =
    Method.PUBLIC(
    function(Self, tag)
        local sprite = Self(nil, nil, 'DO NOT INITIALIZE')
        sprite.name = tag
        return sprite
    end,
    true
)
Sprite.makeFromTag =
    Method.PUBLIC(
    function(Self, tag, x, y)
        local sprite = Self(x, y, "DO NOT INITIALIZE")
        sprite.name = tag
        Sprite.INITIALIZE_FUNCTION(sprite.name, "", x, y)
        return sprite
    end,
    true
)
Sprite.new = function(x, y, a)
    local sprite = Sprite.create()
    if a ~= "DO NOT INITIALIZE" then
        Sprite.INITIALIZE_FUNCTION(sprite.name, "", x, y)
    end

    sprite.color = Color(Color.WHITE)
    sprite.color.parent = sprite
    
    sprite.colorTransform = ColorTransform()
    sprite.colorTransform.parent = sprite
    sprite.animation = Animation(sprite)

    return sprite
end

return Sprite
