local Basic = require 'ChessyXeL.Basic'
local Object = require 'ChessyXeL.display.object.Object'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local File = require 'ChessyXeL.util.File'
local HScript = require 'ChessyXeL.hscript.HScript'

local mathType = function (value)
    return (math.floor(value) == value and 'integer' or 'float')
end

--[[
    #pragma header

    uniform vec2 chessyxel_TextureCoordv; // coords of the animation
    uniform vec2 chessyxel_TextureSize; // animation frame size

    vec4 chessyxel_texture2D(sampler2D bitmap, vec2 coord, vec2 size){
        vec4 color = flixel_texture2D(bitmap, coord);

        vec2 finalCoord = size + chessyxel_TextureCoordv;
        if ((coord.x < chessyxel_TextureCoordv.x || coord.x < finalCoord.x) || (coord.y < chessyxel_TextureCoordv.y || coord.y < finalCoord.y)){
            return vec4(0.0, 0.0, 0.0, 0.0);
        }
        return color;
    }
]]

local chessyxel_Header = [[
    #pragma header

    bool inBounds(vec2 u, vec4 uvData) {return (u.x >= uvData.x && u.x <= uvData.z && u.y >= uvData.y && u.y <= uvData.w);}

    uniform vec2 chessyxel_TextureCoordv; // coords of the animation
    uniform vec2 chessyxel_TextureSize; // animation frame size
    uniform vec2 chessyxel_TextureBounds; // bounds of the animation

    vec4 chessyxel_texture2D(sampler2D bitmap, vec2 coord, vec2 size){
        vec4 color = flixel_texture2D(bitmap, coord);

        // openfl_TextureCoordv: the pixel coord of the whole image
        // chessyxel_TextureCoordv: the beginning pixel of the animation frame divided by the size of the animation frame
        // chessyxel_TextureSize: size of the animation frame

        if (inBounds(coord, vec4(chessyxel_TextureCoordv, size))){
            return color;
        }
        return vec4(0.0, 0.0, 0.0, 0.0);
    }
]]

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

    if object.animation.__type == 'Animation' then
        local oldC = object.animation.callback
        object.animation.callback = function (...)
            if oldC then oldC(...) end
            newShader.data.chessyxel_TextureCoordv = {object.frame.uv.x, object.frame.uv.y}
            newShader.data.chessyxel_TextureBounds = {object.frame.uv.width, object.frame.uv.height}
            newShader.data.chessyxel_TextureSize = {object.frame.frame.width, object.frame.frame.height}
        end
    end
    
    return newShader 
end)
Shader.fromString = Method.PUBLIC(function (Self, stringCode, glslVersion)
    local shaderTag = '__chessyxel__tempo__shader'..Basic.basicCount
    File.save('mods/shaders/'..shaderTag..'.frag', stringCode:gsub('#pragma header', chessyxel_Header..'\n'))
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