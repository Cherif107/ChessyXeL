-- testing stuff in here

local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Object = require 'ChessyXeL.display.object.Object'
local Sprite, Text, Sound

require "ChessyXeL.util.StringUtil"

---@class hscript.HScriptX : Class
local HScriptX = Class 'HScriptX'

local isArray = function(table)
    if type(table) ~= "table" then
        return false
    end
    local count = 0
    for _, _ in pairs(table) do
        count = count + 1
    end
    return count == #table
end

HScriptX.functions = FieldStatus.PUBLIC('default', 'default', {}, true)
HScriptX.import = Method.PUBLIC(function (hscript, class)
    local splittedLibrary = class:split(".")
    local importedLibrary = table.remove(splittedLibrary, #splittedLibrary)

    Object.waitingList.add(function()
        addHaxeLibrary(importedLibrary, table.concat(splittedLibrary, "."))
    end)
    return importedLibrary, true
end, true)

---@deprecated
HScriptX.addLibrary = HScriptX.import

HScriptX.getImports = Method.PUBLIC(function (hscript, code)
    local imports = {}
    for imp in code:gmatch("import%s+([%w%._]+);") do
        imports[#imports + 1] = imp
    end
    return imports
end, true)

HScriptX.shouldInitialize = FieldStatus.PUBLIC('default', 'default', true, true)
HScriptX.initialize = Method.PUBLIC(function (hscript, force)
    if hscript.shouldInitialize or force then
        for _, library in pairs({"String", 'haxe.Rest', "Int", "Float", "Bool", "Array", 'Std', 'Reflect', 'Type', "flixel.text.FlxTextFormat", "flixel.text.FlxTextFormatMarkerPair", 'haxe.ds.StringMap', 'haxe.ds.ObjectMap', 'haxe.ds.IntMap', 'flixel.text.FlxText', 'ModchartText', 'ModchartSprite', 'llua.Lua_helper'}) do
            hscript.import(library)
        end

        local code = [==[
            var __chessyxel__pushed__objects = new StringMap();
            var __chessyxel__object__numerator = 0;
            var __chessyxel__global__tag = "]==].. Object.GlobalObjectTag ..[==[";

            function __chessyxel__convert__object(object){
                var name:String = object[0];
                var type:String = object[1];
                var arguments = object[2];
                
                switch(type){
                    case 'Sprite':
                        return game.modchartSprites.get(name);
                    case 'Text':
                        return game.modchartTexts.get(name);
                    case 'Sound':
                        return game.modchartSounds.get(name);
                    case 'Object':
                        return game.variables.get(name);
                    case 'TextFormat':
                        var format = new FlxTextFormat(arguments[0], arguments[1], arguments[2], arguments[3]);
                        if (arguments[5] != null){
                            format.format.size = arguments[5];
                        }

                        return format;
                    case 'TextFormatMarkerPair':
                        return new FlxTextFormatMarkerPair(__chessyxel__convert__object(arguments[0]), arguments[1]);
                    case 'Array':
                        var newArr = [];
                        for (i in 0...arguments[0].length){
                            newArr[i] = __chessyxel__convert__object(arguments[0][i]);
                        }
                        return newArr;
                    case 'Table':
                        var map = new StringMap();

                        var fieldValues = arguments[0];
                        for (fieldValue in fieldValues)
                            map.set(fieldValue[0], __chessyxel__convert__object(fieldValue[1]));
                        
                        return map;
                    case 'Function':
                        return Reflect.makeVarArgs(function(args){
                            args.insert(0, name);
                            return game.callOnLuas('__chessyxel__call_from_hscript', args);
                        });
                }

                return arguments[0];
            }

            function __chessyxel__convert_lua(object){
                if (object != null){
                    __chessyxel__object__numerator += 1;
                    var objectTag = 'CHX_HSCRIPT_OBJ_' + __chessyxel__global__tag + '_' + __chessyxel__object__numerator;
                    if (object.ID != null && object.x != null && object.y != null){
                        game.variables.set(objectTag, object);
                    
                        if (object.numFrames != null){
                            if (object.text != null)
                                return ['Text', objectTag];
                            return ['Sprite', objectTag];
                        }
                        if (object.volume != null)
                            return ['Sound', objectTag];
                    
                        return ['Object', objectTag];
                    }
                
                    if (object.keys != null && object.keyValueIterator != null){
                        var result = [];
                        for (k in object.keys()){
                            result.push([k, __chessyxel__convert_lua(object[k])]);
                        }
                        return ['Map', result];
                    }
                    if (object.insert != null && object.length != null && object.contains != null){
                        var result = [];
                        for (i in 0...object.length) {
                            result[i] = __chessyxel__convert_lua(object[i]);
                        }
                    
                        return ['Array', result];
                    }

                    if (Type.typeof(object) == Type.resolveEnum('ValueType').TObject) {
                        return ['Object', objectTag];
                    }

                    return ['?', object];
                }
                return ['null', null];
            }
            
            function __chessyxel_set_hscript(name, object){
                parentLua.hscript.variables.set(name, __chessyxel__convert__object(object));
            }
            function __chessyxel_call_hscript(name, arguments){
                return __chessyxel__convert_lua(parentLua.hscript.executeFunction(name, __chessyxel__convert__object(arguments)));
            }

            createCallback('__chessyxel_set_hscript', __chessyxel_set_hscript);
            createCallback('__chessyxel_call_hscript', __chessyxel_call_hscript);
        ]==]

        hscript.shouldInitialize = false
        hscript.unsafeExecute(code)
    end
end, true)

HScriptX.unsafeExecute = Method.PUBLIC(function (hscript, code)
    return Object.waitingList.add(function() runHaxeCode(code) end)
end, true)

HScriptX.execute = Method.PUBLIC(function (hscript, code)
    local imports = hscript.getImports(code) -- get code imports
    code = code:gsub("import%s+.-\n", "") -- delete all imports
    for i = 1, #imports do
        hscript.import(imports[i])
    end

    hscript.initialize()
    return hscript.unsafeExecute(code)
end, true)

HScriptX.convertToHaxe = Method.PUBLIC(function (hscript, object)
    if type(object) == 'table' then
        if object.__type == 'Color' then
            return object.value
        elseif object.__type == 'TextFormat' then
            return {object.name, 'TextFormat', {hscript.convertToHaxe(object.fontColor), object.bold, object.italic, hscript.convertToHaxe(object.borderColor)}}
        elseif object.__type == 'TextFormatMarkerPair' then
            return {object.name, 'TextFormatMarkerPair', {hscript.convertToHaxe(object.format), object.marker}}
        end

        if object.name and object.__type then
            return {object.name, object.__type, {}}
        end
        if not object.__type and not object.is then
            local converted = {}
            for index, value in pairs(object) do
                converted[index] = hscript.convertToHaxe(value)
            end
            if isArray(object) then
                return {'none', 'Array', {converted}}
            else
                local fieldValues = {}
                for field, value in pairs(converted) do
                    if type(field) == 'string' or type(field) == 'number' then
                        fieldValues[#fieldValues + 1] = {field, value}
                    end
                end
                return {'none', 'Table', {fieldValues}}
            end
        end
    end
    if type(object) == 'function' then
        hscript.functions[#hscript.functions + 1] = object
        return {#hscript.functions, 'Function', {}}
    end
    return {'none', type(object), {object}}
end, true)
HScriptX.convertToLua = Method.PUBLIC(function (hscript, object)
    if Sprite == nil then
        Sprite = require 'ChessyXeL.display.Sprite'
        Text = require 'ChessyXeL.display.text.Text'
        Sound = require 'ChessyXeL.media.Sound'
    end
    if object[1] == 'Sprite' then
        return Sprite.fromTag(object[2])
    elseif object[1] == 'Text' then
        return Text.fromTag(object[2])
    elseif object[1] == 'Sound' then
        -- not implemented
    elseif object[1] == 'Object' then
        local obj = Object()
        obj.name = object[2]
        return obj
    elseif object[1] == 'Array' then
        local result = {}
        for field, value in pairs(object[2]) do
            result[field] = hscript.convertToLua(value)
        end
        return result
    elseif object[1] == 'Map' then
        local result = {}
        for _, fieldValue in pairs(object[2]) do
            result[fieldValue[1]] = hscript.convertToLua(fieldValue[2])
        end
        return result
    end

    return object[2]
end, true)

HScriptX.setFunction = Method.PUBLIC(function (hscript, name, Function)
    HScriptX.initialize()
    hscript.functions[name] = Function
    Object.waitingList.add(function ()
        __chessyxel_set_hscript(name, {name, 'Function', {}})
    end)
end, true)
HScriptX.set = Method.PUBLIC(function (hscript, name, value)
    HScriptX.initialize()
    Object.waitingList.add(function ()
        __chessyxel_set_hscript(name, HScriptX.convertToHaxe(value))
    end)
end, true)
HScriptX.call = Method.PUBLIC(function (hscript, name, ...)
    HScriptX.initialize()

    local arguments = hscript.convertToHaxe({...})
    return Object.waitingList.add(function ()
        return hscript.convertToLua(__chessyxel_call_hscript(name, arguments))
    end)
end, true)

function __chessyxel__call_from_hscript(Function, ...)
    if HScriptX.functions[Function] then
        return HScriptX.convertToHaxe(HScriptX.functions[Function](...) or nil)
    end
end

return HScriptX