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

            function drawGradient(tag:String, width:Int, height:Int, colors:Array<Any>, ?chunkSize:Int, ?rotation:Int, ?interpolate:Bool){
                game.modchartSprites.get(tag).pixels = FlxGradient.createGradientBitmapData(width, height, colors, chunkSize, rotation, interpolate);
            }
            function drawPolygon(tag:String, vertices:Array<Dynamic>, ?fillColor:Any, ?lineStyle, ?drawStyle){
                FlxSpriteUtil.drawPolygon(game.modchartSprites.get(tag), vertices, fillColor, lineStyle, drawStyle);
            }
            function drawCurve(tag:String, startX:Float, startY:Float, endX:Float, endY:Float, controlX:Float, controlY:Float, ?fillColor:Any, ?lineStyle, ?drawStyle){
                FlxSpriteUtil.drawCurve(game.modchartSprites.get(tag), startX, startY, endX, endY, controlX, controlY, fillColor, lineStyle, drawStyle);
            }
            function alphaMask(tag:String, tag2:String){
                FlxSpriteUtil.alphaMaskFlxSprite(game.modchartSprites.get(tag), game.modchartSprites.get(tag2), game.modchartSprites.get(tag));
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
function SpriteUtil.drawCurve(spriteTag, startX, startY, endX, endY, controlX, controlY, fillColor, lineStyle, drawStyle)
    SpriteUtil.load()
    HScript.call('drawCurve', spriteTag, startX, startY, endX, endY, controlX, controlY, fillColor, lineStyle, drawStyle)
end
function SpriteUtil.alphaMask(spriteTag, spriteTag2)
    SpriteUtil.load()
    HScript.call('alphaMask', spriteTag, spriteTag2)
end


return SpriteUtil