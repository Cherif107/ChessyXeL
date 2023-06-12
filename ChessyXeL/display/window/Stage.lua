local HScript = require 'ChessyXeL.hscript.HScript'
local Object = require 'ChessyXeL.display.object.Object'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'

---@class display.window.Stage : display.object.Object
local Stage = Object.extend 'Stage'

Object.waitingList.add(function ()
    HScript.execute [[
        import flixel.FlxCamera;
        import openfl.display.Bitmap;
        function __chessyxel__addCameraToStage(parent, cam){
            var window = getVar(parent);
            var camera = new FlxCamera(0, 0, window.width, window.height, 1);

            FlxG.cameras.add(camera);
            camera.bgColor = 0x00ffffff;
            window.stage.addChild(camera.canvas);
            setVar(cam, camera);
            return null;
        }

        function __chessyxel__addToStage(camera, sprite){
            var cam = getVar(camera);
            sprite.cameras = [cam];
            return null;
        }
        function __chessyxel__removeFromStage(sprite){
            sprite.cameras = [game.camGame];
            return null;
        }
    ]]
end)

Stage.camera = FieldStatus.PUBLIC('default', 'default', nil)
Stage.parent = FieldStatus.PUBLIC('default', 'default', nil)
Stage.add = Method.PUBLIC(function (stage, sprite)
    HScript.call('__chessyxel__addToStage', stage.camera.name, sprite)
    return sprite
end)
Stage.remove = Method.PUBLIC(function (stage, sprite)
    HScript.call('__chessyxel__removeFromStage', sprite)
    return sprite
end)

Stage.new = function (parent)
    local stage = Stage.create()
    stage.parent = parent
    stage.name = parent.name..'.stage'
    Object.waitingList.add(function ()
        stage.camera = Object()
        HScript.call('__chessyxel__addCameraToStage', parent.name, stage.camera.name)
    end)
    return stage
end

return Stage