local function die (tbl, i)
    i = i or 1
    if tbl[i] ~= nil then
        return tbl[i], die(tbl, i + 1)
    end
end
---@class EnumData Data inside enums
---[[ FIELDS:START ]]---
---@field name string Enum Data Name
---@field parent Enum The Enum that contains Enum Data
---@field data table OPTIONAL Only if Enum Data has Paremeters, RGB(r, g, b)
---[[ FIELDS:END ]]---
local EnumData
EnumData = {
    ---@param name string Enum Data name
    ---@param data? table Enum Data that contains Parameters ex: RGB(r, g, b)
    ---@return EnumData
    new = function (name, data)
        local enumData = {
            name = name
        }
        local meta = {
            __tostring = function (t)
                local str = t.name
                if t.data then
                    str = str..'('
                    for k, v in pairs(t.data) do
                        str = str..tostring(v)..', '
                    end
                    str = str:sub(1, -3)..')'
                end
                return str
            end,
            __type = 'EnumData'
        }
        if data then
            enumData.data = {}
            for i = 1, #data do
                enumData.data[i] = EnumData.new(data[i], nil)
                enumData.data[i].parent = enumData
            end
        end
        return setmetatable(enumData, meta)
    end
}
---@class Enum Used to define a custom Data Type
local Enum = {
    ---@param data table Enum Data
    ---@return Enum
    new = function (data)
        local enum = setmetatable({}, {
            __tostring = function (t)
                local str = 'Enum('
                for k, v in pairs(t) do
                    str = str..tostring(v)..', '
                end
                return str:sub(1, -3)..')'
            end,
            __type = 'Enum'
        })
        for _enumData, enumData in pairs(data) do
            if type(_enumData) == 'number' then
                enum[enumData] = EnumData.new(enumData, nil)
                enum[enumData].parent = enum
            else
                enum[_enumData] = EnumData.new(_enumData, enumData)
                getmetatable(enum[_enumData]).__call = function(t, ...)
                    local returnMe = {}
                    local args = {...}
                    for i = 1, #t.data do
                        returnMe[t.data[i]] = args[i]
                        t.data[i].order = i
                    end
                    local a = setmetatable(returnMe, {
                        __tostring = function (t)
                            local cone = {}
                            for i, q in pairs(t) do
                                cone[i.order] = tostring(q)
                            end
                            return getmetatable(t).parent.name..'('..table.concat(cone, ', ')..')'
                        end,
                        __type = 'EnumDataValue',
                    })
                    getmetatable(a).parent = enum[_enumData]
                    -- a.match = function (enumDataValue)
                    --     local matching = false
                    --     if getmetatable(enumDataValue).parent == getmetatable(a).parent then
                    --         for i, p in pairs(a) do
                    --             if i ~= 'match' then
                    --                 if p == enumDataValue[i] or enumDataValue[i] == '_' then
                    --                     matching = true
                    --                 else
                    --                     matching = false
                    --                     break
                    --                 end
                    --             end
                    --         end
                    --     end
                    --     return matching
                    -- end
                    return a
                end
                enum[_enumData].parent = enum
            end
        end
        return enum
    end,
    ---@param value table Enum Value
    ---@param cases table<EnumData, function> Switch Cases (EnumData => Function)
    ---@return any | nil
    switch = function(value, cases) --- Enum Switchcases
        for i, q in pairs(cases) do
            if value == i then
                return q()
            elseif getmetatable(value).parent == i then
                local packed = {}
                for _, v in pairs(value) do
                    packed[_.order] = v
                end
                return q(unpack(packed))
            end
        end
        if cases.default then
            return cases.default()
        end
        return nil
    end
}

return setmetatable(Enum, {__call = function (t, data)
    return Enum.new(data)
end})
