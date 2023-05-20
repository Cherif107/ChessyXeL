local Basic = require 'ChessyXeL.Basic'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local ObjectField = require 'ChessyXeL.display.object.Field'
require 'ChessyXeL.util.StringUtil'

---@class display.object.Object:Basic an Object Class for Psych Engine objects and such
local Object = Basic.extend 'Object'

rawset(Object, 'additionalInstanceMetatable', {
    __index = function (instance, field)
        local f = (instance.__isClassObject and ObjectField.parseIndex(instance.__additionalClassField or '', field) or ObjectField.parseIndex(instance.name, field))
        local v = (instance.__isClassObject and getPropertyFromClass(instance.name, f) or getProperty(f))
        if v == f then
            local t = instance.regularFields[field]
            if t == nil then
                instance.regularFields[field] = ObjectField(f, nil, nil, instance.__isClassObject, instance.name)
                t = instance.regularFields[field]
            end
            if type(t.get) == 'function' then
                return t.get(ObjectField.parseIndex(instance.name, field))
            end
            return t
        else
            return v
        end
    end,
    __newindex = function (instance, field, value)
        local f = (instance.__isClassObject and ObjectField.parseIndex(instance.__additionalClassField or '', field) or ObjectField.parseIndex(instance.name, field))
        local v
        if getProperty == nil then
            v = f
        else
            v = (instance.__isClassObject and getPropertyFromClass(instance.name, f) or getProperty(f))
        end
        if v == f and instance.regularFields[field] and type(instance.regularFields[field].set) == 'function' then
            return Object.waitingList.add(function()
                instance.regularFields[field].set(ObjectField.parseIndex(instance.name, field), value)
            end)
        else
            return Object.waitingList.add(function()
                return (instance.__isClassObject and setPropertyFromClass(instance.name, f, value) or setProperty(f, value))
            end)
        end
    end
})

Object.GlobalObjectTag = FieldStatus.PUBLIC('default', 'default', Object.GlobalObjectTag or string.random(10), true)
Object.name = FieldStatus.PUBLIC('default', 'default', 'boyfriend', false)
Object.__isClassObject = FieldStatus.PUBLIC('default', 'default', false, false)
Object.__additionalClassField = FieldStatus.PUBLIC('default', 'default', nil, false)
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
    if o then o() end
    Object.waitingList.executeAll()
end

return Object