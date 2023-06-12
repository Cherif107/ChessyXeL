local Basic = require 'ChessyXeL.Basic'
local Object = require 'ChessyXeL.display.object.Object'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local File = require 'ChessyXeL.util.File'

local mathType = function (value)
    return (math.floor(value) == value and 'integer' or 'float')
end

---@class display.Shader : display.object.Object
local Shader = Object.extend 'Shader'

Shader.data = FieldStatus.PUBLIC(function (I, F)
    if I.data == nil then
        I.data = {}
        setmetatable(I.data, {
            __index = function (t, index)
                local values = {
                    getShaderBool(I.shaderObject, index),
                    getShaderInt(I.shaderObject, index),
                    getShaderFloat(I.shaderObject, index),
                    getShaderBoolArray(I.shaderObject, index),
                    getShaderIntArray(I.shaderObject, index),
                    getShaderFloatArray(I.shaderObject, index)
                }

                for i = 1, 3 do
                    if type(values[i]) ~= 'string' then
                        local array = values[i + 3]
                        if #array > 1 then
                            return array
                        end
                        return values[i]
                    end
                end
            end,
            __newindex = function (t, index, value)
                Object.waitingList.add(function ()
                    local typeOf = type(value)
                    if typeOf == 'boolean' then
                        return setShaderBool(I.shaderObject, index, value)
                    elseif typeOf == 'number' then
                        if mathType(value) == 'integer' then
                            setShaderInt(I.shaderObject, index, value)
                            if getShaderInt(I.shaderObject, index) ~= value then
                                setShaderFloat(I.shaderObject, index, value)
                            end
                            return
                        end
                        return setShaderFloat(I.shaderObject, index, value)
                    elseif typeOf == 'string'  then
                        return setShaderSampler2D(I.shaderObject, index, value)
                    elseif typeOf == 'table' then
                        typeOf = type(value[1])
                        if typeOf == 'boolean' then
                            return setShaderBoolArray(I.shaderObject, index, value)
                        elseif typeOf == 'number' then
                            local leType = 'number'
                            for i = 1, #value do
                                if leType == 'float' then break end
                                leType = mathType(value[i])
                            end
                            if leType == 'integer' then
                                setShaderIntArray(I.shaderObject, index, value)
                                if getShaderIntArray(I.shaderObject, index) ~= value then
                                    setShaderFloatArray(I.shaderObject, index, value)
                                end
                                return
                            end
                            return setShaderFloatArray(I.shaderObject, index, value)
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
    local newShader = Shader.new(shader.shaderPath, shader.shaderVersion, 'DO NOT INITIALIZE')
    newShader.shaderObject = object.name
    newShader.name = object.name..'.shader'
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
Shader.new = function (filePath, glslVersion, doInit)
    local shader = Shader.create()
    if filePath ~= nil then
        shader.shaderPath = filePath
        shader.shaderVersion = glslVersion
        Object.waitingList.add(function ()
            if doInit ~= 'DO NOT INITIALIZE' then
                initLuaShader(filePath, glslVersion)
            end
        end)
    end
    return shader
end

return Shader