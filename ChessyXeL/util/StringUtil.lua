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