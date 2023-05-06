local Sprite = require 'ChessyXeL.display.Sprite'
local HScript = require 'ChessyXeL.hscript.HScript'
local Point = require 'ChessyXeL.math.Point'
local Axes = require 'ChessyXeL.util.Axes'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Signals = require 'ChessyXeL.Signals'
local SpriteUtil = require 'ChessyXeL.hscript.SpriteUtil'
local Object = require 'ChessyXeL.display.object.Object'
---@class Backdrop : display.Sprite
local Backdrop = Sprite.extend 'Backdrop'

Backdrop.repeatAxes = FieldStatus.PUBLIC('default', 'default', Axes.XY)
Backdrop.spacing = FieldStatus.PUBLIC('default', 'default', Point())

Backdrop._blitOffset = FieldStatus.NORMAL('default', 'default', Point())
Backdrop._prevDrawParams = FieldStatus.NORMAL('default', 'default', {
    graphicKey = nil,
    tilesX = -1,
    tilesY = -1,
    scaleX = 0.0,
    scaleY = 0.0,
    spacingX = 0.0,
    spacingY = 0.0,
    repeatAxes = Axes.XY,
    angle = 0.0
})
Backdrop.onDrop = Method.PUBLIC(function(Self)

end, true)

if not Signals.postDraw.has(Backdrop.onDrop) then
    require 'ChessyXeL.Stage'.set('onCreatePost', function ()
        Object.waitingList.add(function()
            HScript.addLibrary('flixel.math.FlxAngle')
            HScript.addLibrary('Math')
            HScript.execute [[
                function __chessyxel__backdrop__isOnScreen__(camera, sprite, repeatAxes){
                    if (repeatAxes == 'XY'){
                        return true;
                    }
                    if (repeatAxes == 'NONE'){
                        return sprite.isOnScreen(camera);
                    }
                    if (camera == null){
                        camera = FlxG.camera;
                    }

                    var bounds = sprite.getScreenBounds(sprite._rect, camera);
                    var view = camera.getViewRect();
                    if (repeatAxes != 'Y'){ bounds.x = view.x; }
                    if (repeatAxes != 'X'){ bounds.y = view.y; }
                    view.put();
                    
                    return camera.containsRect(bounds);
                }
                function __chessyxel__backdrop_drawSimple__(sprite, camera, repeatAxes){

                }
                function __chessyxel__backdrop_draw__(sprite, repeatAxes:String, drawBlit){
                    if (repeatAxes == 'NONE'){
                        sprite.draw();
                        return;
                    }
                    sprite.checkEmptyFrame();

                    if (sprite.alpha == 0 || sprite._frame.type == 2 || sprite.scale.x <= 0 || sprite.scale.y <= 0){
                        return;
                    }
                    if (sprite.dirty){
                        sprite.calcFrame(sprite.useFramePixels);
                    }
                    if (FlxG.renderBlit){
                        __chessyxel__backdrop__drawToLargestCamera__(sprite);
                    }
                    for (camera in sprite.cameras)
                    {
                        if (!camera.visible || !camera.exists || !__chessyxel__backdrop__isOnScreen__(camera, sprite, repeatAxes)){
                            continue;
                        }
            
                        if (sprite.isSimpleRender(camera)){
                            __chessyxel__backdrop_drawSimple__(sprite, camera);
                        }
                        else{
                            __chessyxel__backdrop_drawComplex__(sprite, camera);
                        }
                    }            
                }
            ]]
        end)
        Signals.preUpdate.add(Backdrop.onDrop)
    end)
end


Backdrop.new = function (graphic, repeatAxes, spacingX, spacingY)
    local backdrop = Backdrop.create().loadGraphic(graphic)
    backdrop.repeatAxes = repeatAxes or Axes.XY
    backdrop.spacing.set(spacingX, spacingY)

    HScript.execute()
    return backdrop
end

--TODO: molly chinese queen
--! how to say slay bestie in chinese
---@field gui - mi - sha
--!which means that your
--? bestie is very killability