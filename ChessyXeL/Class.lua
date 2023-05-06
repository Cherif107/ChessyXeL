local Enum = require 'ChessyXeL.Enum'
local Field = require "ChessyXeL.Field"
local Method = require "ChessyXeL.Method"
local FieldStatus = require "ChessyXeL.FieldStatus"

---@class Class A Module that returns a Table that behaves like Classes with features like Private / Public / Static Fields and Getters / Setters.
---[[ FIELDS:START ]]---
---@field public className string The name of the Class
---@field public classFields table<string, any> A Table that contains all the Fields the class has
---@field public classVariables table<string, Field> Unlike `classFields` this field has a set of Fields that contains getters / setters / and more information about the field, Also includes Instance Fields.
---@field public privateAccess boolean Enable when you want to access private fields
---@field public create function Returns an instance of the Class, Please do not override this function
---@field public new function Overridable, also returns an instance of the Class
---@field public extend function returns an Extended version of the class, more specifically copies the fields table
---@field public override function overrides an Already Existing function on the class
---[[ FIELDS:END ]]---
local Class
Class = {
    getInstanceMetatable = function (instanceClass)
        local metatable = {}
        --- [ INDEX ] ---
        metatable.__index = function (instance, field)
            --- Check if `field` is actually in `instance` instead of `instance.regularFields`
            if rawget(instance, field) ~= nil then -- added `~= nil` because of booleans
                return rawget(instance, field) -- returns the Field directly
            else
                --- Check if `instanceClass.classVariables[field]` is not nil
                if instanceClass.classVariables[field] ~= nil then
                    --- Check if `instanceClass.classVariables[field]` is not a static field and indeed is in `instance.regularFields`
                    if instanceClass.classVariables[field].static then
                        return error('Cannot access field `'..field..'` from a Class Instance.') -- Accessing static fields from Class Instances is not allowed
                    else
                        --- Checks if `field` is Private
                        if instanceClass.classVariables[field].private and not instance.privateAccess then
                            return error('Cannot access Private Field `'..field..'`.') -- Accessing Private fields is not allowed
                        else
                            if instanceClass.classVariables[field].isMethod then
                                return function (...)
                                    local OGPACCESS = instance.privateAccess
                                    instance.privateAccess = true
                                    local p = instanceClass.classVariables[field].value(instance, ...)
                                    instance.privateAccess = OGPACCESS
                                    return p
                                end
                            else
                                --- Check if `field`'s get method is not set to 'never'
                                if instanceClass.classVariables[field].get ~= 'never' then
                                    --- Check if `field`'s get method is not nil
                                    if instanceClass.classVariables[field].get ~= nil and not instanceClass.classVariables[field].bypassed then
                                        local OGPACCESS = instance.privateAccess
                                        instance.privateAccess = true
                                        instanceClass.classVariables[field].bypassed = true
                                        local m = instanceClass.classVariables[field].get(instance, field)
                                        instanceClass.classVariables[field].bypassed = false
                                        instance.privateAccess = OGPACCESS
                                        return m
                                    else
                                        --- Return the value in the Instance if the get method is nil 
                                        return instance.regularFields[field]
                                    end
                                else
                                    return error('Cannot access field `'..field..'` for reading.') -- Cannot get this field
                                end
                            end
                        end
                    end
                end
            end
            if rawget(instanceClass, 'additionalInstanceMetatable') and rawget(instanceClass, 'additionalInstanceMetatable').__index then
                return rawget(instanceClass, 'additionalInstanceMetatable').__index(instance, field, instanceClass)
            end
        end
        --- [ NEW INDEX ] ---
        metatable.__newindex = function (instance, field, value)
            --- Check if `field` is actually in `instance` instead of `instance.regularFields`
            if rawget(instance, field) ~= nil then
                return rawset(instance, field, value) -- sets the Field directly
            else
                --- Check if `instanceClass.classVariables[field]` is not nil
                if instanceClass.classVariables[field] ~= nil then
                    --- Check if `instanceClass.classVariables[field]` is not a static field and indeed is in `instance.regularFields`
                    if instanceClass.classVariables[field].static then
                        return error('Cannot access field `'..field..'` from a Class Instance.') -- Accessing static fields from Class Instances is not allowed
                    else
                        --- Checks if `field` is Private
                        if instanceClass.classVariables[field].private and not instance.privateAccess then
                            return error('Cannot access Private Field `'..field..'`.') -- Accessing Private fields is not allowed
                        else
                            --- Check if `field`'s set method is not set to 'never'
                            if instanceClass.classVariables[field].set ~= 'never' then
                                --- Check if `field`'s set method is not nil
                                if instanceClass.classVariables[field].set ~= nil and not instanceClass.classVariables[field].bypassed then
                                    local OGPACCESS = instance.privateAccess
                                    instance.privateAccess = true
                                    instanceClass.classVariables[field].bypassed = true
                                    local m = instanceClass.classVariables[field].set(value, instance, field)
                                    instanceClass.classVariables[field].bypassed = false
                                    instance.privateAccess = OGPACCESS
                                    return m
                                else
                                    --- sets the value in the Instance if the get method is nil 
                                    instance.regularFields[field] = value
                                    return
                                end
                            else
                                return error('Cannot access field `'..field..'` for writing.') -- Cannot get this field
                            end
                        end
                    end
                end
            end
            if rawget(instanceClass, 'additionalInstanceMetatable') and rawget(instanceClass, 'additionalInstanceMetatable').__newindex then
                return rawget(instanceClass, 'additionalInstanceMetatable').__newindex(instance, field, value)
            end
        end
        return metatable
    end,
    getClassMetatable = function ()
        local metatable = {__call = function(t, ...)
            return t.new(...)
        end}
        --- [ INDEX ] ---
        metatable.__index = function (class, field)
            --- Check if `field` is actually in `class` instead of `class.classFields`
            if rawget(class, field) ~= nil then
                return rawget(class, field) -- returns the Field directly
            else
                --- Check if `class.classVariables[field]` is not nil
                if class.classVariables[field] ~= nil then
                    --- Check if `class.classVariables[field]` is a static field and indeed is in `class.classFields`
                    if not class.classVariables[field].static then
                        return error('Static access to instance field `'..field..'` is not Allowed.') -- Accessing Instance fields from a Class is not allowed
                    else
                        --- Checks if `field` is Private
                        if class.classVariables[field].private and not class.privateAccess then
                            return error('Cannot access Private Field `'..field..'`.') -- Accessing Private fields is not allowed
                        else
                            if class.classVariables[field].isMethod then
                                return function (...)
                                    local OGPACCESS = class.privateAccess
                                    class.privateAccess = true
                                    local p = class.classVariables[field].value(class, ...)
                                    class.privateAccess = OGPACCESS
                                    return p
                                end
                            else
                                --- Check if `field`'s get method is not set to 'never'
                                if class.classVariables[field].get ~= 'never' then
                                    --- Check if `field`'s get method is not nil
                                    if class.classVariables[field].get ~= nil and not class.classVariables[field].bypassed then
                                        local OGPACCESS = class.privateAccess
                                        class.privateAccess = true
                                        class.classVariables[field].bypassed = true
                                        local m = class.classVariables[field].get(class, field)
                                        class.classVariables[field].bypassed = false
                                        class.privateAccess = OGPACCESS
                                        return m
                                    else
                                        --- Return the value in the Instance if the get method is nil 
                                        return class.classFields[field]
                                    end
                                else
                                    return error('Cannot access field `'..field..'` for reading.') -- Cannot get this field
                                end
                            end
                        end
                    end
                end
            end
        end
        --- [ NEW INDEX ] ---
        metatable.__newindex = function (class, field, value)
            if type(value) == 'table' then
                if getmetatable(value) and getmetatable(value).__type == 'EnumDataValue' then
                    local m = getmetatable(value).parent.parent
                    local f
                    if m == FieldStatus then
                        f = Field(value)
                    elseif m == Method then
                        f = Field(Enum.switch(value, {
                            [Method.PUBLIC] = function(Function, static, dynamic)
                                return FieldStatus.PUBLIC('default', (dynamic and 'default' or 'never'), Function, static)
                            end,
                            [Method.NORMAL] = function(Function, static, dynamic)
                                return FieldStatus.PUBLIC('default', (dynamic and 'default' or 'never'), Function, static)
                            end,
                            [Method.PRIVATE] = function(Function, static, dynamic)
                                return FieldStatus.PRIVATE('default', (dynamic and 'default' or 'never'), Function, static)
                            end
                        }))
                        f.isMethod = true
                    end
                    class.classVariables[field] = f
                    if f.static then
                        class.classFields[field] = f.value
                    end
                    return
                end
            end
            --- Check if `field` is actually in `class` instead of `class.classFields`
            if rawget(class, field) ~= nil then
                return rawset(class, field, value) -- sets the Field directly
            else
                --- Check if `class.classVariables[field]` is not nil
                if class.classVariables[field] ~= nil then
                    --- Check if `class.classVariables[field]` is a static field and indeed is in `class.classFields`
                    if not class.classVariables[field].static then
                        return error('Static access to instance field `'..field..'` is not Allowed.') -- Accessing Instance fields from a Class is not allowed
                    else
                        --- Checks if `field` is Private
                        if class.classVariables[field].private and not class.privateAccess then
                            return error('Cannot access Private Field `'..field..'`.') -- Accessing Private fields is not allowed
                        else
                            --- Check if `field`'s set method is not set to 'never'
                            if class.classVariables[field].set ~= 'never' then
                                --- Check if `field`'s set method is not nil
                                if class.classVariables[field].set ~= nil and not class.classVariables[field].bypassed then
                                    local OGPACCESS = class.privateAccess
                                    class.privateAccess = true
                                    class.classVariables[field].bypassed = true
                                    local m = class.classVariables[field].set(value, class, field)
                                    class.classVariables[field].bypassed = false
                                    class.privateAccess = OGPACCESS
                                    return m
                                else
                                    --- sets the value in the Class if the get method is nil 
                                    class.classFields[field] = value
                                end
                            else
                                return error('Cannot access field `'..field..'` for writing.') -- Cannot get this field
                            end
                        end
                    end
                end
            end
            if type(value) == 'function' then
                class[field] = FieldStatus.PUBLIC('default', 'default', value, true)
            end
        end
        return metatable
    end,
    new = function (className)
        local class
        class = {
            __type = 'Class',
            className = className or 'Class',
            classFields = {},
            classVariables = {},
            privateAccess = false,

            create = function (...)
                local instance = {
                    __type = class.className,
                    __isClassInstance = true,
                    regularFields = {},
                    privateAccess = false,
                }
                for field, F in pairs(class.classVariables) do
                    instance.regularFields[field] = F.value
                end
                return setmetatable(instance, class.instanceMeta)
            end,
            new = function (...)
                return class.create(...)
            end,
            extend = function (className)
                local newClass = Class(className)
                rawset(newClass, 'additionalInstanceMetatable', rawget(class, 'additionalInstanceMetatable'))
                newClass.create = function (...)
                    local p = setmetatable(class.new(...), newClass.instanceMeta)
                    p.__type = newClass.className
                    for field, F in pairs(newClass.classVariables) do
                        if p.regularFields[field] == nil then
                            p.regularFields[field] = F.value
                        end
                    end
                    return p
                end

                for field, F in pairs(class.classVariables) do
                    newClass[field] = F.status
                    newClass.classVariables[field].isMethod = F.isMethod
                end

                newClass.override = function (FunctionName, Function) -- unlocked when yes ok yes ok eys ok eys 
                    if newClass.classVariables[FunctionName] and newClass.classVariables[FunctionName].isMethod then
                        local super = newClass.classVariables[FunctionName].value
                        newClass.classVariables[FunctionName].value = function (...)
                            Function(super, ...)
                        end
                    end
                end
                return newClass
            end
        }
        class.instanceMeta = Class.getInstanceMetatable(class)
        return setmetatable(class, Class.getClassMetatable())
    end
}

return setmetatable(Class, {__call = function (t, className)
    return Class.new(className)
end})