---@class util.TypeUtil
local TypeUtil = {
    typeOf = function (value)
        local type = type(value)
        if type == 'number' then
            return math.type(value)
        elseif type == 'table' then
            if value.__type == 'Class' then
                return 'Class'
            elseif value.__isClassInstance then
                return 'ClassInstance'
            end
        end
        return type
    end,
    typeOfArray = function (array)
        for i = 1, #array do
            return type(array[i])
        end
    end
}

return TypeUtil