local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Shader = require 'ChessyXeL.display.Shader'
local Basic = require 'ChessyXeL.Basic'
local Object = require 'ChessyXeL.display.object.Object'
local File = require 'ChessyXeL.util.File'
require 'ChessyXeL.util.StringUtil'

local vecSlice = function (props, index, each)
    if #index > 1 then
        local result = {}
        for i = 1, #index do
            result[i] = each(index:sub(i, i), unpack(props))
        end
        return result
    end
    return each(index, unpack(props))
end

local function vec2(x, y)
    return setmetatable({x, y}, {
        __index = function (t, index)
            return vecSlice({t[1], t[2]}, index, function (index, x, y)
                return index:gsub('x', x):gsub('y', y)
            end)
        end
    })
end
local function vec3(r, g, b)
    return setmetatable({r, g, b}, {
        __index = function (t, index)
            return vecSlice({t[1], t[2], t[3]}, index, function (index, r, g, b)
                return index:gsub('x', r):gsub('y', g):gsub('z', b)
                     :gsub('r', r):gsub('g', g):gsub('b', b)
            end)
        end
    })
end
local function vec4(r, g, b, a)
    return setmetatable({r, g, b, a}, {
        __index = function (t, index)
            return vecSlice({t[1], t[2], t[3], t[4]}, index, function (index, r, g, b, a)
                return index:gsub('x', r):gsub('y', g):gsub('z', b):gsub('w', a)
                     :gsub('r', r):gsub('g', g):gsub('b', b):gsub('a', a)
            end)
        end
    })
end

---@class display.InteractiveShader : display.Shader
local InteractiveShader = Shader.extend 'InteractiveShader'

InteractiveShader.override('copyToObject', function (super, shader, object)
    local newShader = InteractiveShader.new(shader.shaderPath)
    newShader.shaderObject = object.name
    newShader.name = object.name..'.shader'
    return newShader
end)
InteractiveShader.openfl_TextureCoordv = FieldStatus.PUBLIC(function (I)
    local coord = I.data.interactive_openfl_TextureCoordv
    return vec2(coord[1], coord[2])
end, function (V, I)
    Object.waitingList.add(function ()
        I.data.interactive_openfl_TextureCoordv = V
    end)
end)
InteractiveShader.gl_FragColor = FieldStatus.PUBLIC(function (I)
    local color =  I.data.interactive_gl_FragColor
    return vec4(color[1], color[2], color[3], color[4])
end, function (V, I)
    Object.waitingList.add(function ()
        I.data.interactive_gl_FragColor = V
    end)
end)

InteractiveShader.new = function (initPath)
    local shaderCode = [[
        #pragma header

        uniform vec2 interactive_openfl_TextureCoordv;
        uniform vec4 interactive_gl_FragColor;

        void main(void){
            gl_FragColor = flixel_texture2D(bitmap, interactive_openfl_TextureCoordv);
        }
    ]]

    local shader
    if not initPath then
        local shaderTag = '__chessyxel__tempo__shader'..Basic.basicCount
        File.save('mods/shaders/'..shaderTag..'.frag', shaderCode)
        shader = InteractiveShader.create(shaderTag)
        Object.waitingList.add(function ()
            deleteFile('shaders/'..shaderTag..'.frag')
        end)
    else
        shader = InteractiveShader.create(initPath)
    end

    return shader
end

return InteractiveShader