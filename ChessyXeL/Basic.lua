local Class = require 'ChessyXeL.Class'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local Log = require 'ChessyXeL.debug.Log'
local TableUtil = require 'ChessyXeL.util.TableUtil'

---@class Basic:Class A very simple Updateable Class that keeps track of its Instances and also makes Special IDS for them
---@field public instances table<string, Basic> the table that keeps track of the Instances
---@field public update function Runs every frame
---@field public ID number Object identifier
---@field basicCount number Counts all the instances (used for IDs)
local Basic = Class('Basic')

Basic.basicCount = FieldStatus.PUBLIC('default', 'default', 0, true)
Basic.instances = FieldStatus.PUBLIC('default', 'default', {}, true)
Basic.update = FieldStatus.PUBLIC('default', 'default', nil, false)
Basic.active = FieldStatus.PUBLIC('default', 'default', true, false)
Basic.ID = FieldStatus.PUBLIC('default', 'default', 0, false)
Basic.destroy = Method.PUBLIC(function (basic)
    if basic then table.remove(Basic.instances, basic.ID) end
end)
Basic.new = function()
    local basic = Basic.create()
    Basic.basicCount = Basic.basicCount + 1
    Basic.instances[#Basic.instances + 1] = basic

    basic.ID = Basic.basicCount
    if Log.logger.enabled and Log.logObjects then
        Log.logger.log('Basic of ID '..Basic.basicCount..' Was Created')
    end
    return basic
end

local o = onUpdate
function onUpdate(elapsed)
    if o then
        o(elapsed)
    end
    for i = 1, #Basic.instances do
        local instance = Basic.instances[i]
        if instance and instance.update ~= nil and instance.active then
            instance.update(elapsed)
        end
    end
end

return Basic