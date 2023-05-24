local Class = require 'ChessyXeL.Class'
local Method = require 'ChessyXeL.Method'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Stage = require 'ChessyXeL.Stage'

---@class debug.Log : Class
local Log = Class 'Log'

local startTime = os.clock()
local formatTime = function (seconds)
    local minutes = math.floor(seconds / 60)
    local hours = math.floor(minutes / 60)
    minutes = minutes - hours * 60
    seconds = seconds - hours * 60 * 60 - minutes * 60

    return string.format('%02d:%02d:%02d', math.floor(hours), math.floor(minutes), math.floor(seconds))
end

Log.onLog = FieldStatus.PUBLIC('default', 'default', nil)
Log.logs = FieldStatus.PUBLIC('default', 'default', {})
Log.enabled = FieldStatus.PUBLIC('default', 'default', true)
Log.log = Method.PUBLIC(function (log, message)
    table.insert(log.logs, 1, '['..formatTime(os.clock() - startTime)..']: '..message)
    if #log > 15 then
        table.remove(log.logs, 16)
    end
    local pre = log.enabled
    log.enabled = false
    if log.onLog then
        log.onLog(log.logs[1])
    end
    log.enabled = pre
    return true
end)
Log.logger = FieldStatus.PUBLIC('default', 'never', Log(), true)
Log.logObjects = FieldStatus.PUBLIC('default', 'default', true, true)

Stage.set('onError', function (err, fun)
    Log.logger.log('<error>'..err..'<error> [<function>'..tostring(fun)..'<function>]')
end)

return Log