---@class display.object.Field A Field class for Objects if the field was nil
---[[ FIELDS:START ]]---
---@field public name string Field's name
---@field public get function | nil Get function for the Field (not __index)
---@field public set function | nil Set function for the Field (not __newindex)
---@field initializedFields table<string, display.object.Field> A List of Fields that this Field initialized already.
---[[ FIELDS:END ]]---
local Field = {}

function Field.parseIndex(name, key)
    if name ~= nil and #name > 0 then
        return (type(key) == 'number' and name..'['..key..']' or name..'.'..key)
    else
        return key
    end
end

function Field.new(name, get, set, isClassField, p)
    local field = {name = name, get = get, set = set, initializedFields = {}}
    field.rawAdd = function(k, value) rawset(field, k, value) end
    return setmetatable(field, {
        __newindex = function(this, key, value)
            local f = (isClassField and key or Field.parseIndex(this.name, key))
            local prop = f
            if getProperty ~= nil then
                if isClassField then
                    prop = getPropertyFromClass(p, Field.parseIndex(this.name, key))
                else
                    prop = getProperty(f)
                end
            end
            if prop == f and this.initializedFields[key] and this.initializedFields[key].set then
                this.initializedFields[key].set(f, value, key)
            else
                return (isClassField and setPropertyFromClass(p, Field.parseIndex(this.name, key), value) or setProperty(f, value))
            end
        end,
        __index = function(this, key)
            if key == 'get' then return rawget(this, 'get') end
            local f = (isClassField and key or Field.parseIndex(this.name, key))
            local prop = f
            if getProperty ~= nil then
                if isClassField then
                    prop = getPropertyFromClass(p, Field.parseIndex(this.name, key))
                else
                    prop = getProperty(f)
                end
            end

            if prop == f or prop == Field.parseIndex(this.name, key) then
                local initedF = rawget(this, 'initializedFields')[key] or Field.new(Field.parseIndex(this.name, key), nil, nil, isClassField, p)
                if initedF and rawget(initedF, 'get') then
                    return rawget(initedF, get)(f, key)
                end
                return initedF
            else
                return prop
            end
        end
    })
end

return setmetatable(Field, {__call = function (t, name, get, set, isClassField, p)
    return Field.new(name, get, set, isClassField, p)
end})