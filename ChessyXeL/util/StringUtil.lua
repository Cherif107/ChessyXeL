---@class StringUtil A Tool that adds a bunch of utilities to the `string` Table

string.random = function (length)
    local str = ''
    math.randomseed(os.time() + os.clock() * 1000000000)
    for i = 1, length do
        str = str.. string.char(math.random(97, 122))
    end
    return str
end

function string.split(self, split)
    split = split or '%s'
    local t={}
    for str in self:gmatch("([^"..split.."]+)") do table.insert(t, str) end
    return t
end

function string.fromTable(table, useBrackets, optimized, spacing, useSpacingOnFirst) -- leave the other 2 options empty if you dont know what you're doing
    useBrackets, spacing = useBrackets or false, spacing or ''
    optimized = (optimized == nil and true or optimized)
    useSpacingOnFirst = (useSpacingOnFirst == nil and true or useSpacingOnFirst)
    local stringifiedTable = '{\n'

    for key, value in pairs(table) do
        key = (type(key) == 'string' and ((useBrackets or key:find(' ')) and '["'..key..'"]' or key) or (type(key) == 'table' and '['..string.fromTable(key, useBrackets, optimized, optimized and (spacing..'\t') or '', false)..']' or '['..tostring(key)..']'))
        if type(value) ~= "function" then
            value = (type(value) == 'string' and ('"'..value:gsub('\"', '\\"'):gsub('\n', '\\n'):gsub('\t', '\\t')..'"') or (type(value) == 'table' and string.fromTable(value, useBrackets, optimized, optimized and (spacing..'\t') or '') or tostring(value)))
            stringifiedTable = stringifiedTable..(optimized and spacing..'\t' or '')..key..' = '..value..',\n'
        end
    end
    return stringifiedTable..spacing..'}'
end