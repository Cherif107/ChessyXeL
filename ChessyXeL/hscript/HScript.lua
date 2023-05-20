require "ChessyXeL.util.StringUtil"
local Signal = require 'ChessyXeL.Signal'
local Sprite, Text, Object

---@class hscript.HScript
local HScript = {
    functions = {},
    loadedVariables = {},
    shouldInitialize = true,

    getImports = function(code)
        local imports = {}
        for imp in code:gmatch("import%s+([%w%._]+);") do
            imports[#imports + 1] = imp
        end
        return imports
    end,
    isArray = function(table)
        if type(table) ~= "table" then
            return false
        end
        local count = 0
        for _, _ in pairs(table) do
            count = count + 1
        end
        return count == #table
    end,
    executeUnsafe = function (code)
        return runHaxeCode(code)
    end,
    addLibrary = function(library)
        local splittedLibrary = library:split(".")
        local importedLibrary = table.remove(splittedLibrary, #splittedLibrary)

        addHaxeLibrary(importedLibrary, table.concat(splittedLibrary, "."))
        return importedLibrary, true
    end,
    signals = Signal(),
    doRun = false
}
HScript.run = function (fun)
    if HScript.doRun then
        return fun()
    else
        return HScript.signals.add(fun)
    end
end

local o = onCreatePost
function onCreatePost()
    if o then o() end
    HScript.signals.dispatch()
    HScript.doRun = true
end

HScript.variables = setmetatable({}, {
    __index = function (t, k)
        return HScript.get(k)
    end,
    __newindex = function (t, k, v)
        return HScript.set(k, v)
    end,
})

HScript.initialize = function ()
    if HScript.shouldInitialize then
        for _, library in pairs({"String", "Int", "Float", "Bool", "Array", 'Std', 'Reflect', 'Type', 'haxe.ds.StringMap', 'haxe.ds.ObjectMap', 'haxe.ds.IntMap', 'flixel.text.FlxText', 'ModchartText', 'ModchartSprite', 'llua.Lua_helper', 'FunkinLua'}) do
            HScript.addLibrary(library)
        end
        local codeToRun = [==[
            __hscript__pushed__variables__ = [];
            __hscript__push__index__ = 0;
            __hscript__initialized_variables = new StringMap();
            __chessyxel__hscript__object__numerator = 0;
    
            function pushVariable(name:String, value:Dynamic = null){
                __hscript__push__index__ = __hscript__pushed__variables__.length;
                __hscript__pushed__variables__.push([name, value]);
            }
            function getCurPushed(){
                return __hscript__pushed__variables__[__hscript__push__index__][1];
            }
            function getPushed(name){
                for (i in 0...__hscript__pushed__variables__.length){
                    var variable = __hscript__pushed__variables__[i];
                    if (variable[0] == name){
                        return variable[1];
                    }
                }
            }
            function setOnPushed(name, field, value){
                var splitted = field.split('.');
                if (splitted.length > 1){
                    var object = getPushed(name);
                    var toSet = splitted.pop();
                    for (f in splitted){
                        object = Reflect.field(object, f);
                    }
                    Reflect.setProperty(object, toSet, parseLua(value));
                }else{
                    Reflect.setProperty(getPushed(name), field, parseLua(value));
                }
            }
            function removePushed(name){
                for (i in 0...__hscript__pushed__variables__.length){
                    if (__hscript__pushed__variables__[i][0] == name){
                        var value = __hscript__pushed__variables__[i][1];
                        __hscript__pushed__variables__.splice(i, 1);
                        __hscript__push__index__ -= 1;
                        return value;
                    }
                }
            }
        
            ValueType = Type.resolveEnum('ValueType');
        
            function addCallback(name:String = 'test', F:Dynamic){
                for (lua in game.luaArray){
                    Lua_helper.add_callback(lua.lua, name, F);
                }
                return true;
            }
        
            function isMap(v){
                if (Std.isOfType(v, StringMap) || Std.isOfType(v, IntMap)){
                    return true;
                }
            }
            
            function parseLua(value:Dynamic = null){
                if (Type.typeof(value) == ValueType.TObject){
                    var map = null;
                    for (f in Reflect.fields(value)){
                        var val = Reflect.field(value, f);
                        if (map == null){
                            if (Std.isOfType(f, String)){
                                map = new StringMap();
                            }else{
                                map = new IntMap();
                            }
                        }
                        map[f] = parseLua(val);
                    }
                    return map;
                }
                if (Std.isOfType(value, Array)){
                    for (i in 0...value.length){
                        value[i] = parseLua(value[i]);
                    }
                    var token = value[0];
                    switch(token){
                        case '__chessyxel__hscript__sprite__conversion__':
                            return game.modchartSprites.get(value[1]);
                        case '__chessyxel__hscript__text__conversion__':
                            return game.modchartTexts.get(value[1]);
                        case '__chessyxel__hscript__object__conversion__':
                            return game.variables.get(value[1]);
                        case '__chessyxel__hscript__textformat__convertion__':
                            var textFormat = new FlxTextFormat(value[1], value[2], value[3], value[4]);
                            if (value[5] != null){
                                textFormat.format.size = value[5];
                            }
                            return textFormat;
                        case '__chessyxel__hscript__textformatmarkerpair__conversion__':
                            return new FlxTextFormatMarkerPair(parseLua(value[1]), value[2]);
                        case '__chessyxel__hscript__point__conversion__':
                            return new FlxPoint(value[1], value[2]);
                        case '__chessyxel__hscript__matrix__conversion__':
                            return new Matrix(value[1], value[2], value[3], value[4], value[5], value[6]);
                        case '__chessyxel__function__convertion__':
                            return Reflect.makeVarArgs(function(arguments){
                                arguments.insert(0, value[1]);
                                return game.callOnLuas('__chessyxel__callbacks__hscript__callontable__', arguments);
                            });
                    }
                }
                return value;
            }
            function toLua(value:Dynamic = null){
                if (isMap(value)){
                    var OM = {};
                    for (K in value.keys()){
                        Reflect.setField(OM, K, toLua(value.get(K)));
                    }
                    return OM;
                }
                var type = Type.getClass(value);
                if (type == FlxSprite || type == ModchartSprite){
                    __chessyxel__hscript__object__numerator += 1;
                    var tag = 'CHESSYXEL_HSCRIPT_OBJECT_'+__chessyxel__hscript__object__numerator; 
                    game.variables.set(tag, value);
                    return toLua(["__chessyxel__hscript__sprite__conversion__toLua", tag]);
                }
                if (type == FlxText || type == ModchartText){
                    __chessyxel__hscript__object__numerator += 1;
                    var tag = 'CHESSYXEL_HSCRIPT_OBJECT_'+__chessyxel__hscript__object__numerator; 
                    game.variables.set(tag, value);
                    return toLua(["__chessyxel__hscript__text__conversion__toLua", tag]);
                }
                if (Std.isOfType(value, String) || Std.isOfType(value, Array) || Std.isOfType(value, Int) || Std.isOfType(value, Float) || Std.isOfType(value, Bool) || value == null || Reflect.isFunction(value)){
                    return value;
                }
                if (value != null){
                    __chessyxel__hscript__object__numerator += 1;
                    var tag = 'CHESSYXEL_HSCRIPT_OBJECT_'+__chessyxel__hscript__object__numerator; 
                    game.variables.set(tag, value);
                    return toLua(["__chessyxel__hscript__object__conversion__toLua", tag]);
                }
                return null;
            }
        
            function getOnHscript(name:String){
                if (__hscript__initialized_variables.exists(name) && __hscript__initialized_variables[name] != null){
                    return __hscript__initialized_variables[name];
                }
                var splitted = name.split('.');
                if (splitted.length > 1){
                    var object = FunkinLua.hscript.variables.get(splitted.shift());
                    for (f in splitted){
                        object = Reflect.getProperty(object, f);
                    }
                    var p = toLua(object);
                    if (Reflect.isFunction(object)){
                        __hscript__initialized_variables[name] = p;
                    }
                    return p;
                }else{
                    var p = toLua(FunkinLua.hscript.variables.get(name));
                    if (Reflect.isFunction(p)){
                        __hscript__initialized_variables[name] = p;
                    }
                    return p;
                }
                return null;
            }
            function setOnHscript(name:String, value:Dynamic = null){
                var splitted = name.split('.');
                if (splitted.length > 1){
                    var object = FunkinLua.hscript.variables.get(splitted.shift());
                    var toSet = splitted.pop();
                    for (f in splitted){
                        object = Reflect.getProperty(object, f);
                    }
                    Reflect.setProperty(object, toSet, parseLua(value));
                }else{
                    FunkinLua.hscript.variables.set(name, parseLua(value));
                }
            }
        
            function addHScriptFunction(functionName, luaName){
                setOnHscript(functionName, Reflect.makeVarArgs(function(arguments){
                    arguments.insert(0, luaName);
                    return game.callOnLuas('__chessyxel__callbacks__hscript__callontable__', [luaName]);
                }));
            }
            addCallback('setOnHscript', setOnHscript);
            addCallback('getOnHscript', function(name:String){
                var p = getOnHscript(name);
                if (Reflect.isFunction(p)){
                    return ['__chessyxel__hscript__function__conversion__toLua', name];
                }
                return p;
            });
            addCallback('callOnHscript', function(name:String, ?arguments = []){
                if (getOnHscript(name) != null){
                    return toLua(Reflect.callMethod(null, getOnHscript(name), parseLua(arguments)));
                }
            });
        ]==]
        HScript.shouldInitialize = false
        HScript.executeUnsafe(codeToRun)
    end
end

HScript.fromLua = function (value)
    if type(value) == 'table' then
        if value.__type == 'Color' then
            return value.value
        elseif value.__type == 'Sprite' or value.__type == 'SkewedSprite' then
            return {'__chessyxel__hscript__sprite__conversion__', value.name}
        elseif value.__type == 'Text' then
            return {'__chessyxel__hscript__text__conversion__', value.name}
        elseif value.__type == 'Object' then
            return {'__chessyxel__hscript__object__conversion__', value.name}
        elseif value.__type == 'TextFormat' then
            HScript.addLibrary("flixel.text.FlxTextFormat")
            return {'__chessyxel__hscript__textformat__convertion__', HScript.fromLua(value.fontColor), value.bold, value.italic, HScript.fromLua(value.borderColor), value.size}
        elseif value.__type == 'TextFormatMarkerPair' then
            HScript.addLibrary("flixel.text.FlxTextFormatMarkerPair")
            return {'__chessyxel__hscript__textformatmarkerpair__conversion__', HScript.fromLua(value.format), HScript.fromLua(value.marker)}
        elseif value.__type == 'Point' then
            HScript.addLibrary('flixel.math.FlxPoint')
            return {'__chessyxel__hscript__point__conversion__', value.x, value.y}
        elseif value.__type == 'Matrix3' then
            HScript.addLibrary('openfl.geom.Matrix')
            return {'__chessyxel__hscript__matrix__conversion__', value.a, value.b, value.c, value.d, value.tx, value.ty}
        else
            for i = 1, #value do
                value[i] = HScript.fromLua(value[i])
            end
        end
    elseif type(value) == 'function' then
        table.insert(HScript.functions, value)
        return {'__chessyxel__function__convertion__', #HScript.functions}
    end
    return value
end
HScript.toLua = function (value)
    if Sprite == nil then
        Sprite = require 'ChessyXeL.display.Sprite'
        Text = require 'ChessyXeL.display.text.Text'
        Object = require 'ChessyXeL.display.object.Object'
    end
    if type(value) == 'table' then
        if value[1] == '__chessyxel__hscript__sprite__conversion__toLua' then
            return Sprite.fromTag(value[2])
        elseif value[1] == '__chessyxel__hscript__text__conversion__toLua' then
            return Text.fromTag(value[2])
        elseif value[1] == '__chessyxel__hscript__object__conversion__toLua' then
            local p = Object()
            p.name = value[2]
            return p
        elseif value[1] == '__chessyxel__hscript__function__conversion__toLua' then
            return function(...)
                HScript.call(value[2], ...)
            end
        end
        for i = 1, #value do
            value[i] = HScript.toLua(value[i])
        end
    end
    return value
end
HScript.call = function (Function, ...)
    HScript.initialize()
    local args = {...}
    for i = 1, #args do
        args[i] = HScript.fromLua(args[i])
    end
    return HScript.run(function() HScript.toLua(callOnHscript(Function, args)) end)
end
HScript.set = function (variable, value)
    HScript.initialize()
    if type(value) == "function" then
        return HScript.setFunction(variable, value)
    end
    return HScript.run(function() setOnHscript(variable, HScript.fromLua(value)) end)
end
HScript.get = function (variable)
    HScript.initialize()
    return HScript.run(function() HScript.toLua(getOnHscript(variable)) end)
end
HScript.pushVariable = function (name, value)
    HScript.call('pushVariable', name, HScript.fromLua(value))
end
HScript.getCurPushed = function ()
    return HScript.call('getCurPushed')
end
HScript.getPushed = function (name)
    return HScript.call('getPushed', name)
end
HScript.setOnPushed = function (name, field, value)
    HScript.call('setOnPushed', name, field, HScript.fromLua(value))
end
HScript.removePushed = function (name)
    return HScript.call('removePushed', name)
end
HScript.setFunction = function (FunctionName, Function)
    HScript.functions[FunctionName] = Function
    HScript.call('addHScriptFunction', FunctionName, FunctionName)
end

HScript.execute = function (code)
    code = code:gsub("public var", "") -- replacing public var with an empty string will make it global
    local imports = HScript.getImports(code) -- get code imports
    code = code:gsub("import%s+.-\n", "") -- delete all imports
    for i = 1, #imports do
        HScript.addLibrary(imports[i])
    end

    HScript.initialize()
    return HScript.executeUnsafe(code)
end

function __chessyxel__callbacks__hscript__callontable__(Function, ...)
    if HScript.functions[Function] then
        return HScript.fromLua(HScript.functions[Function]() or nil)
    end
    return nil
end

return HScript