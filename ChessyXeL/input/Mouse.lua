local ClassObject = require 'ChessyXeL.display.object.ClassObject'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Point = require 'ChessyXel.math.Point'
local Game

---@class input.Mouse : display.object.ClassObject
local Mouse = ClassObject.extend 'Mouse'

Mouse.getScreenPosition = Method.PUBLIC(function (mouse, camera, point)
    Game = Game or require 'ChessyXeL.Game'
    camera = camera or Game.FlxG.camera
    point = point or Point.get()

    point.set((mouse._globalScreenX - camera.x + 0.5 * camera.width * (camera.zoom - camera.initialZoom)) / camera.zoom,
              (mouse._globalScreenY - camera.y + 0.5 * camera.height * (camera.zoom - camera.initialZoom)) / camera.zoom)
    return point
end)
Mouse.overlaps = Method.PUBLIC(function (mouse, object, camera)
    Game = Game or require 'ChessyXeL.Game'
    camera = camera or Game.FlxG.camera
    if object.__type == 'Group' then
        object.forEach(function(member)
            if mouse.overlaps(member, camera) then
                return true
            end
        end)
    end
    return object.overlapsPoint(Point(mouse.x, mouse.y), true, camera)
end)

Mouse.new = function()
    local mouse = Mouse.create('flixel.FlxG', 'mouse')
    return mouse
end

return Mouse