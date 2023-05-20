local Basic = require 'ChessyXeL.Basic'
local Object = require 'ChessyXeL.display.object.Object'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local File = require 'ChessyXeL.util.File'

local mathType = function (value)
    return (math.floor(value) == value and 'integer' or 'float')
end

---@class display.Shader : Basic
local Shader = Basic.extend 'Shader'

Shader.data = FieldStatus.PUBLIC(function (I, F)
    if I.data == nil then
        I.data = {}
        setmetatable(I.data, {
            __index = function (t, index)
                local bool, int, float, floatarray, intarray, boolarray = 
                    getShaderBool(I.shaderObject, index), getShaderInt(I.shaderObject, index), getShaderFloat(I.shaderObject, index), 
                    getShaderFloatArray(I.shaderObject, index), getShaderIntArray(I.shaderObject, index), getShaderBoolArray(I.shaderObject, index)

                return bool or int or float or floatarray or intarray or boolarray
            end,
            __newindex = function (t, index, value)
                Object.waitingList.add(function ()
                    local type = type(value)
                    if type == 'boolean' then
                        return setShaderBool(I.shaderObject, index, value)
                    elseif type == 'number' then
                        return (mathType(value) == 'integer' and setShaderInt or setShaderFloat)(I.shaderObject, index, value)
                    elseif type == 'string'  then
                        return setShaderSampler2D(I.shaderObject, index, value)
                    elseif type == 'table' then
                        type = type(value[1])
                        if type == 'boolean' then
                            return setShaderBoolArray(I.shaderObject, index, value)
                        elseif type == 'number' then
                            return (mathType(value) == 'integer' and setShaderIntArray or setShaderFloatArray)(I.shaderObject, index, value)
                        end
                    end    
                end)
            end
        })
    end
    return I.data
end, 'default', nil)

Shader.shaderPath = FieldStatus.PUBLIC('default', 'default', 'SHADER')
Shader.shaderVersion = FieldStatus.PUBLIC('default', 'default', nil)
Shader.shaderObject = FieldStatus.PUBLIC('default', 'default', nil)
Shader.copyToObject = Method.PUBLIC(function (shader, object)
    local newShader = Shader.new(shader.shaderPath, shader.shaderVersion)
    newShader.shaderObject = object.name 
    return newShader 
end)
Shader.fromString = Method.PUBLIC(function (Self, stringCode, glslVersion)
    local shaderTag = '__chessyxel__tempo__shader'..Basic.basicCount
    File.save('mods/shaders/'..shaderTag..'.frag', stringCode)
    local shader = Self.new(shaderTag, glslVersion)
    Object.waitingList.add(function ()
        deleteFile('shaders/'..shaderTag..'.frag')
    end)
    return shader
end, true)
Shader.new = function (filePath, glslVersion)
    local shader = Shader.create()
    shader.shaderPath = filePath
    shader.shaderVersion = glslVersion
    Object.waitingList.add(function ()
        initLuaShader(filePath, glslVersion)
    end)
    return shader
end

return Shader