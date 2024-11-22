local RuntimeVal = require 'ChessyXeL.chx.runtime.values.RuntimeVal'
local NullVal = require 'ChessyXeL.chx.runtime.values.NullVal'
local NumberVal = require 'ChessyXeL.chx.runtime.values.NumberVal'

local Stmt = require 'ChessyXeL.chx.ast.Stmt'
local NodeType = require 'ChessyXeL.chx.ast.NodeType'

local Enum = require 'ChessyXeL.Enum'
local Class = require 'ChessyXeL.Class'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Variable = require 'ChessyXeL.chx.ast.Variable'


---@class chx.runtime.environment : Class
local environment = Class 'environment'

environment.parent = FieldStatus.PUBLIC('default', 'default', nil)
environment.variables = FieldStatus.PUBLIC('default', 'default', nil)
environment.finals = FieldStatus.PUBLIC('default', 'default', nil)

environment.new = function (parentENV)
    local env = environment.create()
    env.parent = parentENV
    env.variables = {}
    env.finals = {}
    return env
end

environment.declareVar = Method.PUBLIC(function (env, name, value, final, type)
    -- if env.variables[name] then
    --     error('Variable `'..name..'` is Already declared')
    -- end

    if type ~= nil and value.type ~= type then
        error('Cannot assign '..value.type..' as '..type)
    end
    env.variables[name] = Variable(value, type)
    if final then
        env.finals[name] = true
    end
    return value
end)

environment.checkType = Method.PUBLIC(function (env, variable, assign)
    if variable.type ~= nil and variable.type ~= assign.type then
        error('Cannot assign '..variable.type..' as '..assign.type)
    end
end)

environment.resolve = Method.PUBLIC(function (env, name)
    if env.variables[name] then
        return env
    end
    if env.parent == nil then
        error ('Cannot resolve non existent variable `'..name..'`')
    end

    return env.parent.resolve(name)
end)

environment.assignVar = Method.PUBLIC(function (this, name, value)
    local env = this.resolve(name)

    if env.finals[name] then
        error('final variable `'..name..'` cannot be accessed for writing.')
    end

    env.checkType(env.variables[name], value)
    env.variables[name].value = value

    return value
end)

environment.lookUpVar = Method.PUBLIC(function (this, name)
    local env = this.resolve(name)
    return env.variables[name].value
end)


return environment