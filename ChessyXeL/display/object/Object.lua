local Basic = require 'ChessyXeL.Basic'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local ObjectField = require 'ChessyXeL.display.object.Field'
require 'ChessyXeL.util.StringUtil'

---@class display.object.Object:Basic an Object Class for Psych Engine objects and such
local Object = Basic.extend 'Object'

rawset(Object, 'additionalInstanceMetatable', {
    __index = function (instance, field)
        local f = ObjectField.parseIndex(instance.name, field)
        local v = getProperty(f)
        if v == f then
            local t = instance.regularFields[field]
            if t == nil then
                instance.regularFields[field] = ObjectField(ObjectField.parseIndex(instance.name, field))
                t = instance.regularFields[field]
            end
            if t.get then
                return t.get(ObjectField.parseIndex(instance.name, field))
            end
            return t
        else
            return v
        end
    end,
    __newindex = function (instance, field, value)
        local f = ObjectField.parseIndex(instance.name, field)
        local v
        if getProperty == nil then
            v = f
        else
            v = getProperty(f)
        end
        if v == f and instance.regularFields[field] and instance.regularFields[field].set then
            return Object.waitingList.add(function()
                instance.regularFields[field].set(ObjectField.parseIndex(instance.name, field), value)
            end)
        else
            return Object.waitingList.add(function()
                setProperty(f, value)
            end)
        end
    end
})

Object.GlobalObjectTag = FieldStatus.PUBLIC('default', 'default', Object.GlobalObjectTag or string.random(10), true)
Object.name = FieldStatus.PUBLIC('default', 'default', 'boyfriend', false)
Object.waitingList = FieldStatus.PUBLIC('default', 'never', {
    add = function (setfunc)
        if setProperty == nil then
            Object.waitingList.list[#Object.waitingList.list + 1] = setfunc
        else
            return setfunc()
        end
    end,
    executeAll = function ()
        for i = 1, #Object.waitingList.list do
            Object.waitingList.list[i]()
        end
    end,
    list = {},
    approve = function (a, b)
        return (setProperty == nil and b or a)
    end
}, true)

Object.new = function ()
    local object = Object.create()
    object.name = 'CHX_OBJ_'..Object.GlobalObjectTag..'_'..object.ID
    rawset(object, 'rawset', function (f, v)
        rawset(object, f, v)
    end)
    object.rawset('set', function (property, value)
        rawget(Object, 'additionalInstanceMetatable').__newindex(object, property, value)
    end)

    return object
end

local o = onCreate
function onCreate()
    Object.waitingList.executeAll()
end

return Object