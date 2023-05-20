---@class util.File
local File = {
    save = function(file, content)
        local f = io.open(file, 'wb')
        f:write(content)
        return f, f:close()
    end,
    getContent = function(file)
        local f = io.open(file, 'rb')
        local content = f:read '*all'
        f:close()
        return content
    end,
    exists = function(file)
        local f = io.open(file, 'r')
        if f ~= nil then f:close() end
        return f ~= nil
    end,
    getScriptPath = function ()
        return debug.getinfo(1, "S").source:match [[^@?(.*[\/])[^\/]-$]]
    end
}
return File