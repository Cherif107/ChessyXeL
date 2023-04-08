---@class util.TableUtil utilities for lua tables / arrays
local TableUtil = {}
TableUtil.pop = function (array)
    local el = array[#array]
    array[#array] = nil
    return el
end
TableUtil.shift = function (array)
    local el = array[1]
    array[1] = nil
    return el
end
TableUtil.splice = function (array, pos, len, ...)
    local result = {}
    local argCount = select("#", ...)
    local removeEnd = pos + len - 1

    for i = pos, removeEnd do
      result[#result + 1] = array[i]
    end
    for i = removeEnd + 1, #array do
      array[i - len] = array[i]
    end
    for i = 1, argCount do
      array[pos + i - 1] = select(i, ...)
    end
    for i = #array, #array - len + 1, -1 do
      array[i] = nil
    end
    return result
  end
  
TableUtil.indexOf = function (array, element)
    for k, v in pairs(array) do
        if v == element then
            return k
        end
    end
    return -1
end
TableUtil.concat = function (array, array2)
    for i = 1, #array2 do
        array[#array + 1] = array2[i]
    end
    return array
end
TableUtil.swapAndPop = function (array, index)
    array[index] = array[#array]
    TableUtil.pop(array)
    return array
end
TableUtil.fastSplice = function(array, element)
    local index = TableUtil.indexOf(array, element)
    if index ~= -1 then
        return TableUtil.swapAndPop(array, index)
    end
    return array
end
TableUtil.clearArray = function (array, recursive)
    if recursive == nil then recursive = false end
    if array == nil then
        return array
    end
    if recursive then
        while #array > 0 do
            local el = TableUtil.pop(array)
            if type(el) == 'table' then
                TableUtil.clearArray(el, recursive)
            end
        end
    else
        while #array > 0 do
            TableUtil.pop(array)
        end
    end
    return array
end
return TableUtil