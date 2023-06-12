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
            import flixel.math.FlxPoint;
            import openfl.display.Bitmap;
            import openfl.display.BitmapData;
            import openfl.geom.Rectangle;
            import openfl.geom.Point;
            import Math;

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
            
                var bitmapData = Paths.image(texture).bitmap;
                var textureWidth = bitmapData.width;
                var textureHeight = bitmapData.height;
            
                // Define the texture coordinates based on the polygon's bounding box
                var minX = 0/1;
                var minY = minX;
                var maxX = -0/1;
                var maxY = maxX;
            
                for (p in vertices) {
                    minX = Math.min(minX, p.x);
                    minY = Math.min(minY, p.y);
                    maxX = Math.max(maxX, p.x);
                    maxY = Math.max(maxY, p.y);
                }
            
                var texCoords = [];
                for (p in vertices) {
                    var u = (p.x - minX) / (maxX - minX);
                    var v = (p.y - minY) / (maxY - minY);
                    texCoords.push(new FlxPoint(u * textureWidth, v * textureHeight));
                }
            
                // Find the centroid of the polygon
                var centroidX = 0.0;
                var centroidY = 0.0;
                var numVertices = vertices.length;
            
                for (p in vertices) {
                    centroidX += p.x;
                    centroidY += p.y;
                }
            
                centroidX /= numVertices;
                centroidY /= numVertices;
            
                // Translate the polygon to the centroid
                for (p in vertices) {
                    p.x -= centroidX;
                    p.y -= centroidY;
                }
            
                // Create a new set of texture coordinates based on the centroid translation
                var translatedTexCoords = [];
                for (p in texCoords) {
                    translatedTexCoords.push(new FlxPoint(p.x - centroidX, p.y - centroidY));
                }
            
                // Calculate the matrix transformation using the translated texture coordinates
                matrix.a = (translatedTexCoords[1].x - translatedTexCoords[0].x) / textureWidth;
                matrix.b = (translatedTexCoords[1].y - translatedTexCoords[0].y) / textureWidth;
                matrix.c = (translatedTexCoords[numVertices - 1].x - translatedTexCoords[0].x) / textureHeight;
                matrix.d = (translatedTexCoords[numVertices - 1].y - translatedTexCoords[0].y) / textureHeight;
                matrix.tx = translatedTexCoords[0].x;
                matrix.ty = translatedTexCoords[0].y;
                
            
                sprite.graphics.beginBitmapFill(bitmapData, matrix, true);
                var p = vertices.shift();
                sprite.graphics.moveTo(p.x, p.y);
                for (p in vertices) {
                    sprite.graphics.lineTo(p.x, p.y);
                }
                sprite.graphics.endFill();
                vertices.unshift(p);
            
                var bounds = sprite.getBounds(sprite);
                var offsetX = bounds.x;
                var offsetY = bounds.y;
            
                var bitmap = new Bitmap();
                bitmap.bitmapData = new BitmapData(bounds.width, bounds.height, true, 0x00000000);
                bitmap.bitmapData.draw(sprite, new Matrix(1, 0, 0, 1, -offsetX, -offsetY));
            
                game.modchartSprites.get(tag).pixels.draw(bitmap);
                return null;
            }
            function drawCurve(tag:String, startX:Float, startY:Float, endX:Float, endY:Float, controlX:Float, controlY:Float, ?fillColor:Any, ?lineStyle, ?drawStyle){
                FlxSpriteUtil.drawCurve(game.modchartSprites.get(tag), startX, startY, endX, endY, controlX, controlY, fillColor, lineStyle, drawStyle);
                return null;
            }
            function drawCircle(tag:String, ?X:Float, ?Y:Float, ?Radius:Float, ?fillColor:Any, ?lineStyle, ?drawStyle){
                FlxSpriteUtil.drawCircle(game.modchartSprites.get(tag), X, Y, Radius, fillColor, lineStyle, drawStyle);
                return null;
            }
            function alphaMask(tag:String, tag2:String){
                FlxSpriteUtil.alphaMaskFlxSprite(game.modchartSprites.get(tag), game.modchartSprites.get(tag2), game.modchartSprites.get(tag));
                return null;
            }
            function alphaMaskPosition(tag:String, tag2:String, ?x:Float = 0, ?y:Float = 0, ?output:String){
                var spr1 = game.modchartSprites.get(tag);
                var spr2 = game.modchartSprites.get(tag2);
                var opt;
                if (output == null){
                    opt = spr1;
                }else{
                    opt = game.modchartSprites.get(output);
                }
                spr1.drawFrame();

                var data = spr1.pixels.clone();
                data.copyChannel(spr2.pixels, new Rectangle(0, 0, spr1.width, spr1.height), new Point(x, y), 8, 8);
                opt.pixels = data;

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
function SpriteUtil.drawCircle(spriteTag, X, Y, Radius, fillColor, lineStyle, drawStyle)
    SpriteUtil.load()
    HScript.call('drawCircle', spriteTag, X, Y, Radius, bit.tobit(fillColor), lineStyle, drawStyle)
end
function SpriteUtil.alphaMask(spriteTag, spriteTag2)
    SpriteUtil.load()
    HScript.call('alphaMask', spriteTag, spriteTag2)
end
function SpriteUtil.alphaMaskPosition(spriteTag, spriteTag2, x, y, output)
    SpriteUtil.load()
    HScript.call('alphaMaskPosition', spriteTag, spriteTag2, x, y, output)
end
function SpriteUtil.callFromSprite(spriteTag, func, ...)
    SpriteUtil.load()
    HScript.call('callFromSprite', spriteTag, func, {...})
end

return SpriteUtil