local Object = require "ChessyXeL.display.object.Object"
require "ChessyXeL.util.StringUtil"

---@class hscript.HScript
local HScript = {
    functions = {},
    shouldInit = true,
    loadedVariables = {},
    getFunctionArguments = function(func)
        local argumentss = {}
        for i = 1, debug.getinfo(func).nparams do
            table.insert(argumentss, debug.getlocal(func, i))
        end
        return argumentss
    end,
    getImports = function(code)
        local imports = {}
        for imp in code:gmatch("import%s+([%w%.]+);") do
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
    executeUnsafe = function(code)
        return runHaxeCode(code)
    end,
    addLibrary = function(library)
        local splittedLibrary = library:split(".")
        local importedLibrary = table.remove(splittedLibrary, #splittedLibrary)

        addHaxeLibrary(importedLibrary, table.concat(splittedLibrary, "."))
        return importedLibrary, true
    end
}
HScript.variables =
    setmetatable(
    {},
    {
        __index = function(t, k)
            HScript.addLibrary("FunkinLua")
            return HScript.getValue("FunkinLua.hscript.variables.get(" .. HScript.parseValue(k) .. ")")
        end,
        __newindex = function(t, k, v)
            HScript.shouldInit = true
            HScript.addLibrary("FunkinLua")
            if type(v) == "function" then
                HScript.setFunction(k, v)
            else
                HScript.executeUnsafe(
                    "FunkinLua.hscript.variables.set(" ..
                        HScript.parseValue(k) .. ", " .. HScript.parseValue(v) .. ");\n"
                )
            end
            HScript.loadedVariables[k] = nil
        end
    }
)

function HScript.parseValue(value)
    local type = type(value)
    if type == "string" then
        return '"' .. value .. '"'
    elseif type == "table" then
        if value.__type == "CHESSYXEL_HSCRIPT_NEW_CALL" then
            return "new " .. value.class .. "(" .. table.concat(value.arguments, ", ") .. ")"
        elseif value.__type == "Color" then
            return value.value
        elseif value.__type == "Matrix3" then
            HScript.addLibrary('openfl.geom.Matrix')
            return HScript.parseValue(HScript.newInstance('Matrix', value.a, value.b, value.c, value.d, value.tx, value.ty))
        elseif value.__type == "Sprite" or value.__type == 'SkewedSprite' or value.__type == 'Text' or value.__type == 'Object' then
            return 'game.getLuaObject("' .. value.name .. '")'
        elseif value.__type == "Point" then
            HScript.addLibrary("flixel.math.FlxPoint")
            return "new FlxPoint(" .. value.x .. ", " .. value.y .. ")"
        elseif value.__type == "TextFormat" then
            HScript.addLibrary("flixel.text.FlxTextFormat")
            HScript.push(
                "CHESSYXEL_TEXTFORMAT_VAR",
                HScript.newInstance("FlxTextFormat", value.fontColor, value.bold, value.italic, value.borderColor)
            )
            if value.size then
                HScript.getPushed("CHESSYXEL_TEXTFORMAT_VAR", "format.size", value.size)
            end
            return 'removePushed("CHESSYXEL_TEXTFORMAT_VAR")'
        elseif value.__type == "TextFormatMarkerPair" then
            HScript.addLibrary("flixel.text.FlxTextFormatMarkerPair")
            return "new FlxTextFormatMarkerPair(" ..
                HScript.parseValue(value.format) .. ", " .. HScript.parseValue(value.marker) .. ")"
        end
        return HScript.parseTable(value)
    elseif type == "nil" then
        return "null"
    else
        return tostring(value)
    end
end
function HScript.parseTable(table)
    local result = "[\n"
    if HScript.isArray(table) then
        for index = 1, #table do
            result = result .. HScript.parseValue(table[index]) .. ", \n"
        end
    else
        for key, value in pairs(table) do
            result = result .. HScript.parseValue(key) .. " => " .. HScript.parseValue(value) .. ", \n"
        end
    end
    return result .. "]"
end

function HScript.checkForMap(value)
    if type(value) == "table" then
        if value[1] == "DEFAULT_HSCRIPT_MAP_CONVERTED_TO_LUA_FROM_ARRAY" then
            local map = {}
            for i = 2, #value do
                map[value[i][1]] = value[i][2]
            end
            return map
        elseif value[1] == "CHESSYXEL_DEFAULT_HSCRIPT_TO_SPRITE_CONVERTION" then
            local Sprite = require "ChessyXeL.display.Sprite"
            local spr = Sprite.create()
            spr.name = value[2]
            return spr
        elseif value[1] == "CHESSYXEL_DEFAULT_HSCRIPT_TO_OBJECT_CONVERTION" then
            debugPrint('yeah!')
            local obj = Object()
            obj.name = value[2]
            return obj
        end
    end
    return value
end
function HScript.getValue(value)
    -- [[ normalize values and return them ]] --
    return HScript.checkForMap(
        HScript.executeUnsafe("var v = " .. value .. ";\n" .. [[
            return parseValue(v);
        ]])
    )
end

local function contains(ta, v)
    for a, b in next, ta, nil do
        if b == v then
            return true
        end
    end
end

function HScript.unpack(table, index)
    index = index or 1
    if table[index] ~= nil then
        return HScript.parseValue(table[index]) ..
            ((index ~= #table) and ", " .. HScript.unpack(table, index + 1) or "")
    end
    return ""
end
HScript.setFunction = function(functionName, func, optionalArguments)
    HScript.shouldInit = true
    optionalArguments = optionalArguments or {}
    local arguments = HScript.getFunctionArguments(func)
    local args = {}

    if optionalArguments == "all" then
        optionalArguments = arguments
    end
    for i = 1, #arguments do
        if contains(optionalArguments, arguments[i]) then
            args[i] = "?" .. arguments[i]
        else
            args[i] = arguments[i]
        end
    end

    HScript.functions[functionName] = {
        arguments = table.concat(arguments, ", "),
        args = table.concat(args, ", "),
        func = func
    }
    HScript.initialize()
end

local doFirstInit = true
HScript.initialize = function()
    local str = ''
    if doFirstInit then
        HScript.addLibrary("Std")
        HScript.addLibrary("Reflect")
        HScript.addLibrary("haxe.ds.StringMap")
        HScript.addLibrary("haxe.ds.IntMap")
        HScript.addLibrary("ModchartSprite")
        HScript.addLibrary("Type")
        for _, library in pairs({"String", "Int", "Float", "Bool", "Array"}) do
            HScript.addLibrary(library)
        end
        HScript.variables["CHESSYXEL_OBJECT_TAG"] = Object.GlobalObjectTag
        HScript.variables["CHESSYXEL_OBJECT_NUMERATOR"] = 0
        str =
            [[
            TEMPORARY_HSCRIPT_VARIABLE = null;
            HSCRIPT_TEMPORARY_VARIABLES = [];
            pushIndex = 0;
            function pushVariable(name, value){
                pushIndex = HSCRIPT_TEMPORARY_VARIABLES.length;
                HSCRIPT_TEMPORARY_VARIABLES.push([name, value]);
            }
            function getVariable(name){
                for (i in 0...HSCRIPT_TEMPORARY_VARIABLES.length){
                    var variable = HSCRIPT_TEMPORARY_VARIABLES[i];
                    if (variable[0] == name){
                        return variable[1];
                    }
                }
            }
            function getPushed(){
                return HSCRIPT_TEMPORARY_VARIABLES[pushIndex][0];
            }
            function removePushed(name){
                for (i in 0...HSCRIPT_TEMPORARY_VARIABLES.length){
                    if (HSCRIPT_TEMPORARY_VARIABLES[i][0] == name){
                        var value = HSCRIPT_TEMPORARY_VARIABLES[i][1];
                        HSCRIPT_TEMPORARY_VARIABLES.splice(i, 1);
                        return value;
                    }
                }
            }
            function isMap(v){
                if (Std.isOfType(v, StringMap) || Std.isOfType(v, IntMap))
                    return true;
            }
            function parseValue(v){
                if (Std.isOfType(v, Float) || Std.isOfType(v, Int) || Std.isOfType(v, String) || Std.isOfType(v, Bool))
                    return v;
                if (Std.isOfType(v, Array)){
                    var q = [];
                    for (i in 0...v.length)
                        q[i] = parseValue(v[i]);
                    return q;
                }
                if (isMap(v)){
                    var q = ["DEFAULT_HSCRIPT_MAP_CONVERTED_TO_LUA_FROM_ARRAY"];
                    for (k in v.keys())
                        q.push([k, v.get(k)]);
                    return q;
                }
                if (Std.isOfType(v, ModchartSprite)){
                    CHESSYXEL_OBJECT_NUMERATOR += 1;

                    var tag = "CHESSYXEL_HSCRIPT_SPRITE_" + CHESSYXEL_OBJECT_TAG + '_' + CHESSYXEL_OBJECT_NUMERATOR;
                    game.modchartSprites.set(tag, v);
                    return ["CHESSYXEL_DEFAULT_HSCRIPT_TO_SPRITE_CONVERTION", tag];
                }
                if (Std.isOfType(v, FlxSprite)){
                    CHESSYXEL_OBJECT_NUMERATOR += 1;

                    var tag = "CHESSYXEL_HSCRIPT_SPRITE_" + CHESSYXEL_OBJECT_TAG + '_' + CHESSYXEL_OBJECT_NUMERATOR;
                    setVar(tag, v);
                    return ["CHESSYXEL_DEFAULT_HSCRIPT_TO_SPRITE_CONVERTION", tag];
                }
                if (v != null){
                    CHESSYXEL_OBJECT_NUMERATOR += 1;

                    var tag = "CHESSYXEL_HSCRIPT_OBJECT_" + CHESSYXEL_OBJECT_TAG + '_' + CHESSYXEL_OBJECT_NUMERATOR;
                    setVar(tag, v);
                    return ["CHESSYXEL_DEFAULT_HSCRIPT_TO_OBJECT_CONVERTION", tag];
                }
                return null;
            }
            function debugPrint(?txt1, ?txt2, ?txt3, ?txt4, ?txt5, ?color){
                if (txt1 != null) txt1 += ', '; else txt1 = '';
                if (txt2 != null) txt2 += ', '; else txt2 = '';
                if (txt3 != null) txt3 += ', '; else txt3 = '';
                if (txt4 != null) txt4 += ', '; else txt4 = '';
                if (txt5 != null) txt5 += ', '; else txt5 = '';
                if (color == null) color = 0xFFffffff;
                game.addTextToDebug((txt1+txt2+txt3+txt4+txt5).substr(0, -2), color);
            }
            function getCallback(funcName, arguments){
                var argStuff = [funcName];
                for (v in arguments)
                    argStuff.push(v);

                game.callOnLuas("CALL_HSCRIPT_FROM_TABLE", argStuff);
                var v = TEMPORARY_HSCRIPT_VARIABLE;
                TEMPORARY_HSCRIPT_VARIABLE = null;
                return v;
            }
        ]]..'\n'
    end
    if HScript.shouldInit then
        for fName, functionStuff in next, HScript.functions, nil do
            if not HScript.functions[fName].inited then
                str =
                    str ..
                    "function " ..
                        fName ..
                            "(" ..
                                functionStuff.args ..
                                    '){ return getCallback("' .. fName .. '", [' .. functionStuff.arguments .. "]); }\n"
                HScript.functions[fName].inited = true
            end
        end
        for var, value in next, HScript.variables, nil do
            if HScript.loadedVariables[var] == nil then
                str = str .. var .. " = " .. HScript.parseValue(value) .. ";\n"
                HScript.loadedVariables[var] = nil
                HScript.loadedVariables[var] = value
            end
        end
        HScript.executeUnsafe(str)
        HScript.shouldInit = false
    end
    doFirstInit = false
end

HScript.setVariable = function(variable, value) --- for global variables ONLY
    HScript.variables[variable] = value
    HScript.initialize()
end
HScript.getVariable = function(variable) --- for global variables ONLY
    return HScript.variables[variable]
end
HScript.push = function(name, value)
    return HScript.call("pushVariable", name, value)
end
HScript.setOnPushed = function(name, field, value)
    return HScript.executeUnsafe('getVariable("' .. name .. '").' .. field .. " = " .. HScript.parseValue(value) .. ";\n")
end
HScript.getPushed = function(name, field, value)
    return HScript.executeUnsafe('return getPushed().' .. field .. " = " .. HScript.parseValue(value) .. ";\n")
end
HScript.getPushedByName = function(name)
    return HScript.call("getVariable", name)
end
HScript.removePushed = function(name)
    return HScript.call("removeVariable", name)
end
HScript.newInstance = function(class, ...)
    local a = {...}
    for i = 1, #a do
        a[i] = HScript.parseValue(a[i])
    end
    return {
        __type = "CHESSYXEL_HSCRIPT_NEW_CALL",
        class = class,
        arguments = a
    }
end
HScript.call = function(func, ...)
    return HScript.checkForMap(HScript.executeUnsafe(
        "if (" .. func .. " != null){\n return parseValue(" .. func .. "(" .. HScript.unpack({...}) .. "));\n}\n"
    ))
end

function HScript.execute(code)
    code = code:gsub("public var", "") -- replacing public var with an empty string will make it global
    local imports = HScript.getImports(code) -- get code imports
    code = code:gsub("import%s+.-\n", "") -- delete all imports

    for i = 1, #imports do
        HScript.addLibrary(imports[i])
    end

    HScript.initialize()
    return HScript.executeUnsafe(code)
end

function CALL_HSCRIPT_FROM_TABLE(func, ...)
    local v = HScript.functions[func].func(...)
    HScript.setVariable("TEMPORARY_HSCRIPT_VARIABLE", v or nil)
end
function CANCEL_HSCRIPT_TEMPO_SET()
    HScript.setVariable("TEMPORARY_HSCRIPT_VARIABLE", nil)
end

return HScript
