--!WARNING: very expensive

local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Matrix = require 'ChessyXeL.geom.Matrix3'
local Point = require 'ChessyXeL.math.Point'
local Sprite = require 'ChessyXeL.display.Sprite'
local HScript = require 'ChessyXeL.hscript.HScript'
local Signals = require 'ChessyXeL.Signals'
local Object = require 'ChessyXeL.display.object.Object'
local Stage = require 'ChessyXeL.Stage'

---@class display.addons.SkewedSprite : display.Sprite 
local SkewedSprite = Sprite.extend 'SkewedSprite'

SkewedSprite.skew = FieldStatus.PUBLIC('default', 'default', Point.get())
SkewedSprite.transformMatrix = FieldStatus.PUBLIC('default', 'default', Matrix())
SkewedSprite.exposedMatrix = FieldStatus.PUBLIC('default', 'default', false)
SkewedSprite._skewMatrix = FieldStatus.PUBLIC('default', 'default', Matrix())
SkewedSprite.useVertices = FieldStatus.PUBLIC('default', 'default', false)
SkewedSprite.vertices = FieldStatus.PUBLIC('default', 'default', {Point.get(), Point.get(), Point.get(), Point.get()})

SkewedSprite.skewedSprites = FieldStatus.PUBLIC('default', 'default', {}, true)
SkewedSprite.onSkew = Method.PUBLIC(function (Self)
    -- debugPrint('im lser you t')
    for i = 1, #Self.skewedSprites do
        local skewed = Self.skewedSprites[i]
        HScript.call('__chessyxel__skewed__draw__', skewed, skewed.skew, skewed._skewMatrix, skewed.exposedMatrix, skewed.transformMatrix, skewed.useVertices, skewed.vertices)
    end
    HScript.call('FlxG.cameras.render')
end, true)

if not Signals.postDraw.has(SkewedSprite.onSkew) then
    Stage.set('onCreatePost', function ()
        Object.waitingList.add(function()
            HScript.addLibrary('flixel.math.FlxAngle')
            HScript.addLibrary('Math')
            HScript.execute [[
                function __chessyxel__update__skewMatrix__(skewMatrix, skewPoint, useVertices, vertices){
                    skewMatrix.identity();

                    if (useVertices){
                        var dx1 = vertices[1].x - vertices[0].x;
                        var dy1 = vertices[1].y - vertices[0].y;
                        var dx2 = vertices[2].x - vertices[3].x;
                        var dy2 = vertices[2].y - vertices[3].y;
                        var hskew = (dx2 * dy1 - dx1 * dy2) / (dx2 * dx2 + dy2 * dy2);
                        var vskew = (dx1 * dx2 + dy1 * dy2) / (dx2 * dx2 + dy2 * dy2);

                        if (Math.isNaN(hskew)) hskew = 0;
                        if (Math.isNaN(vskew)) vskew = 0;

                        skewMatrix.b = hskew;
                        skewMatrix.c = vskew;
                    }else{
                        if (skewPoint.x != 0 || skewPoint.y != 0)
                        {
                            skewMatrix.b = Math.tan(skewPoint.y * FlxAngle.TO_RAD);
                            skewMatrix.c = Math.tan(skewPoint.x * FlxAngle.TO_RAD);
                        }
                    }
                }
                function __chessyxel__complex__draw__(camera, sprite, skewPoint, skewMatrix, exposedMatrix, transformMatrix, useVertices, vertices){
                    var _frame = sprite._frame;
                    var _matrix = sprite._matrix;

                    _frame.prepareMatrix(_matrix, 0, false, false);
                    _matrix.translate(-sprite.origin.x, -sprite.origin.y);
                    _matrix.scale(sprite.scale.x, sprite.scale.y);

                    if (exposedMatrix){
                        _matrix.concat(transformMatrix);
                    }else{
                        if (sprite.bakedRotationAngle <= 0){
                            sprite.updateTrig();

                            if (sprite.angle != 0){
                                _matrix.rotateWithTrig(sprite._cosAngle, sprite._sinAngle);
                            }
                            __chessyxel__update__skewMatrix__(skewMatrix, skewPoint, useVertices, vertices);
                            _matrix.concat(skewMatrix);
                        }
                    }
                    sprite.getScreenPosition(sprite._point, camera).subtractPoint(sprite.offset);
                    sprite._point.addPoint(sprite.origin);
                    if (sprite.isPixelPerfectRender(camera)){
                        sprite._point.floor();
                    }
                
                    _matrix.translate(sprite._point.x, sprite._point.y);
                    camera.drawPixels(_frame, sprite.framePixels, _matrix, sprite.colorTransform, sprite.blend, sprite.antialiasing);
                }
                function __chessyxel__simpleRenderer__check__(camera, sprite, skewPoint, matrixExposed){
                    if (FlxG.renderBlit)
                    {
                        return sprite.isSimpleRender(camera) && (skewPoint.x == 0) && (skewPoint.y == 0) && !matrixExposed;
                    }
                    else
                    {
                        return false;
                    }
                }
                function __chessyxel__skewed__draw__(sprite, skewPoint, skewMatrix, exposedMatrix, transformMatrix, useVertices, vertices){
                    sprite.checkEmptyFrame();
                    if (sprite.alpha == 0 || sprite._frame.type == 2){
                    	return;
                    }
        
                    sprite.visible = false;
                    if (sprite.dirty) {
                    	sprite.calcFrame(sprite.useFramePixels);
                    }
                    
                    for (camera in sprite.cameras)
                    {
                    	if (!camera.visible || !camera.exists || !sprite.isOnScreen(camera)){
                    		continue;
                    	}

                    	if (__chessyxel__simpleRenderer__check__(camera, sprite, skewPoint, exposedMatrix)){    
                    		sprite.drawSimple(camera);
                    	}else{
                    		__chessyxel__complex__draw__(camera, sprite, skewPoint, skewMatrix, exposedMatrix, transformMatrix, useVertices, vertices);
                    	}
                    }
                }
            ]]
        end)
        Signals.postDraw.add(SkewedSprite.onSkew)
    end)
end

SkewedSprite.new = function ()
    local sprite = SkewedSprite.create()
    SkewedSprite.skewedSprites[#SkewedSprite.skewedSprites + 1] = sprite
    return sprite
end


return SkewedSprite