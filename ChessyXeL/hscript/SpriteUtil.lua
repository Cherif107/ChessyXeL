local HScript = require 'ChessyXeL.hscript.HScript'
local Point = require 'ChessyXeL.math.Point'

---@class hscript.SpriteUtil
local SpriteUtil = {
    loaded = false
}

function SpriteUtil.load()
    if not SpriteUtil.loaded then
        HScript.execute [[
            import flixel.util.FlxGradient;
            import flixel.util.FlxSpriteUtil;
            import openfl.geom.Matrix;
            import openfl.display.Sprite;
            import openfl.display.Graphics;

            function drawGradient(tag:String, width:Int, height:Int, colors:Array<Any>, ?chunkSize:Int, ?rotation:Int, ?interpolate:Bool){
                game.modchartSprites.get(tag).pixels = FlxGradient.createGradientBitmapData(width, height, colors, chunkSize, rotation, interpolate);
                return null;
            }
            function drawPolygon(tag:String, vertices:Array<Dynamic>, ?fillColor:Any, ?lineStyle, ?drawStyle){
                FlxSpriteUtil.drawPolygon(game.modchartSprites.get(tag), vertices, fillColor, lineStyle, drawStyle);
                return null;
            }
            function drawPolygonWithTexture(tag:String, vertices:Array<Dynamic>, ?texture:String, ?lineStyle, ?drawStyle){
                var sprite = new Sprite();
                var matrix = new Matrix();

                sprite.graphics.beginBitmapFill(Paths.image(texture).bitmap);
                sprite.graphics.drawTriangles(vertices);
                sprite.graphics.endFill();

                game.modchartSprites.get(tag).pixels.draw(sprite);
                return null;
            }
            function drawCurve(tag:String, startX:Float, startY:Float, endX:Float, endY:Float, controlX:Float, controlY:Float, ?fillColor:Any, ?lineStyle, ?drawStyle){
                FlxSpriteUtil.drawCurve(game.modchartSprites.get(tag), startX, startY, endX, endY, controlX, controlY, fillColor, lineStyle, drawStyle);
                return null;
            }
            function alphaMask(tag:String, tag2:String){
                FlxSpriteUtil.alphaMaskFlxSprite(game.modchartSprites.get(tag), game.modchartSprites.get(tag2), game.modchartSprites.get(tag));
                return null;
            }
            function callFromSprite(tag:String, func:String, arguments:Array<Dynamic>){
                return parseLua(Reflect.callMethod(game.getLuaObject(tag), func, arguments));
            }
        ]]
        SpriteUtil.loaded = true
    end
end

function SpriteUtil.drawGradient(spriteTag, width, height, colors, chunkSize, rotation, interpolate)
    SpriteUtil.load()
    HScript.call('drawGradient', spriteTag, width, height, colors, chunkSize, rotation, interpolate)
end
function SpriteUtil.drawPolygon(spriteTag, vertices, fillColor, lineStyle, drawStyle)
    SpriteUtil.load()
    HScript.call('drawPolygon', spriteTag, vertices, bit.tobit(fillColor), lineStyle, drawStyle)
end
function SpriteUtil.drawPolygonWithTexture(spriteTag, vertices, texture, lineStyle, drawStyle)
    SpriteUtil.load()
    HScript.call('drawPolygonWithTexture', spriteTag, vertices, texture, lineStyle, drawStyle)
end
function SpriteUtil.drawCurve(spriteTag, startX, startY, endX, endY, controlX, controlY, fillColor, lineStyle, drawStyle)
    SpriteUtil.load()
    HScript.call('drawCurve', spriteTag, startX, startY, endX, endY, controlX, controlY, fillColor, lineStyle, drawStyle)
end
function SpriteUtil.alphaMask(spriteTag, spriteTag2)
    SpriteUtil.load()
    HScript.call('alphaMask', spriteTag, spriteTag2)
end
function SpriteUtil.callFromSprite(spriteTag, func, ...)
    SpriteUtil.load()
    HScript.call('callFromSprite', spriteTag, func, {...})
end

return SpriteUtil