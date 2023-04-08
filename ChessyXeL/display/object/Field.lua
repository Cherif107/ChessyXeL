---@class display.object.Field A Field class for Objects if the field was nil
---[[ FIELDS:START ]]---
---@field public name string Field's name
---@field public get function | nil Get function for the Field (not __index)
---@field public set function | nil Set function for the Field (not __newindex)
---@field initializedFields table<string, display.object.Field> A List of Fields that this Field initialized already.
---[[ FIELDS:END ]]---
local Field = {}

function Field.parseIndex(name, key)
    return type(key) == 'number' and name..'['..key..']' or name..'.'..key or error('Error: Cannot Index with key of type "'..type(key)..'".')
end

function Field.new(name, get, set)
    local field = {name = name, get = get, set = set, initializedFields = {}}
    field.rawAdd = function(k, value) rawset(field, k, value) end
    return setmetatable(field, {
        __newindex = function(this, key, value)
            local f = Field.parseIndex(this.name, key)
            local prop = getProperty(f)
            if prop == f and this.initializedFields[key] and this.initializedFields[key].set then
                this.initializedFields[key].set(Field.parseIndex(this.name, key), value, key)
            else
                setProperty(f, value)
            end
        end,
        __index = function(this, key)
            local f = Field.parseIndex(this.name, key)
            local prop = getProperty(f)
            if prop == f then
                local initedF = rawget(this, 'initializedFields')[key] or Field.new(Field.parseIndex(rawget(this, 'name'), key))
                if initedF and rawget(initedF, get) then
                    return rawget(initedF, get)(Field.parseIndex(rawget(this, 'name'), key), key)
                end
            else
                return prop
            end
        end
    })
end

return setmetatable(Field, {__call = function (t, name, get, set)
    return Field.new(name, get, set)
end})
