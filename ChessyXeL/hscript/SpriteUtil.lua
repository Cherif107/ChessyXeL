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
    HScript.call('drawPolygon', spriteTag, vertices, fillColor, lineStyle, drawStyle)
end

function SpriteUtil.set(sprite, variable, value)
    HScript.execute('game.modchartSprites.get("'..sprite..'").'..variable..' = '..HScript.parseValue(value)..';\n')
end
function SpriteUtil.override(sprite, Function, FunctionDeclaration, Arguments)
    HScript.addLibrary('Reflect')
    HScript.execute(
        'var spr = game.modchartSprites.get("'..sprite..'");\n'..
        'var superFunc = spr.'..Function..';\n'..
        'var newFunc = '..FunctionDeclaration..';\n'..
        'spr.'..Function..' = '..'function('..(#Arguments > 0 and '?'..table.concat(Arguments, ', ?') or '')..'){'..
            'return newFunc(superFunc'..(#Arguments > 0 and ', '..table.concat(Arguments, ', ') or '')..');\n'..
        '};'
    )
end


return SpriteUtil