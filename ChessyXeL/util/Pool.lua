local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local TableUtil = require 'ChessyXeL.util.TableUtil'
---@class util.Pool : Class
local Pool = Class 'Pool'

Pool._pool = FieldStatus.NORMAL('default', 'default', {})
Pool._class = FieldStatus.NORMAL('default', 'default')
Pool._count = FieldStatus.NORMAL('default', 'default', 0)
Pool.length = FieldStatus.PUBLIC(function (pool)
    return pool._count
end, 'never')

Pool.get = Method.PUBLIC(function (pool)
    if pool._count < 2 then
        return pool._class.new()
    end
    pool._count = pool._count - 1
    return pool._pool[pool._count]
end)
Pool.put = Method.PUBLIC(function (pool, object)
    if object ~= nil then
        local i = TableUtil.indexOf(pool._pool, object)
        if i == -1 or i >= pool._count then
            -- object.destroy()
            pool._count = pool._count + 1
            pool._pool[pool._count] = object
        end
    end
end)
Pool.putUnsafe = Method.PUBLIC(function (pool, object)
    if object ~= nil then
        -- object.destroy()
        pool._count = pool._count + 1
        pool._pool[pool._count] = object
    end
end)
Pool.preAllocate = Method.PUBLIC(function (pool, numObjects)
    while numObjects > 0 do
        numObjects = numObjects - 1
        pool._count = pool._count + 1
        pool._pool[pool._count] = pool._class.new()
    end
end)
Pool.clear = Method.PUBLIC(function (pool)
    pool._count = 0
    local oldPool = pool._pool
    pool._pool = {}
    return oldPool
end)

Pool.new = function (class)
    local pool = Pool.create()
    pool.privateAccess = true pool._class = class
    pool.privateAccess = false
    return pool
end

return Pool