local Basic = require 'ChessyXeL.Basic'
local FieldStatus = require 'ChessyXeL.FieldStatus'
local Method = require 'ChessyXeL.Method'
local TableUtil = require 'ChessyXeL.util.TableUtil'
local Signal = require 'ChessyXeL.Signal'

---@class groups.Group : Basic
local Group = Basic.extend 'Group'

Group.members = FieldStatus.PUBLIC('default', 'default', {})
Group.maxSize = FieldStatus.PUBLIC('default', 'default', 0)
Group.length = FieldStatus.PUBLIC('default', 'default', 0)
Group.order = FieldStatus.PUBLIC('default', function (V, I)
    I.forEach(function (member)
        member.order = V + TableUtil.indexOf(I.members, member)
    end)
    I.order = V
end, 0)

Group.memberAdded = FieldStatus.PUBLIC(function (I)
    return I._memberAdded
end, 'never', Signal())
Group.memberRemoved = FieldStatus.PUBLIC(function (I)
    return I._memberRemoved
end, 'never', Signal())

Group._memberAdded = FieldStatus.NORMAL('default', 'default', Signal())
Group._memberRemoved = FieldStatus.NORMAL('default', 'default', Signal())
Group._marker = FieldStatus.NORMAL('default', 'default', 0)

Group.destroy = Method.PUBLIC(function (group)
    group.forEach(function (member)
        if member ~= nil and member.destroy then
            member.destroy()
        end
    end)
    group.members = nil
end)
Group.getFirstNil = Method.PUBLIC(function (group)
    for i = 1, #group.members do
        if group.members[i] == nil then
            return i
        end
    end
    return -1
end)
Group.add = Method.PUBLIC(function (group, object, onTop)
    if object == nil or TableUtil.indexOf(group.members, object) ~= -1 then
        return object
    end

    local idx = group.getFirstNil()
    if idx ~= -1 then
        group.members[idx] = object
        if idx > group.length then
            group.length = idx + 1
        end
        if object.__type ~= 'Group' then
            object.add(onTop)
        end
        if onTop then
            object.order = group.order + group.length
        else
            object.order = group.order
        end
        group._memberAdded.dispatch(object)
        return object
    end

    if group.maxSize > 0 and group.length >= group.maxSize then
        return object
    end

    group.members[#group.members+1] = object
    group.length = group.length + 1

    if object.__type ~= 'Group' then
        object.add(onTop)
    end
    if onTop then
        object.order = group.order + group.length
    else
        object.order = group.order
    end
    group._memberAdded.dispatch(object)
    return object
end)
Group.insert = Method.PUBLIC(function (group, object, position)
    if object == nil or TableUtil.indexOf(group.members, object) ~= -1 then
        return object
    end

    if position <= group.length and group.members[position] == nil then
        group.members[position] = object
        group._memberAdded.dispatch(object)
        return object
    end

    if group.maxSize > 0 and group.length >= group.maxSize then
        return object
    end

    table.insert(group.members, position, object)
    object.order = group.order + position
    group.length = group.length + 1
    group._memberAdded.dispatch(object)
    return object
end)
Group.remove = Method.PUBLIC(function (group, object, Splice)
    if group.members == nil then return nil end
    local idx = TableUtil.indexOf(group.members, object)

    if idx == nil then return nil end

    if Splice then
        TableUtil.splice(group.members, idx, 1)
        group.length = group.length - 1
    else
        group.members[idx] = nil
    end

    group._memberRemoved.dispatch(object)
    return object
end)
Group.replace = Method.PUBLIC(function (group, object, newObject)
    local idx = TableUtil.indexOf(group.members, object)
    if idx == -1 then return nil end

    group.members[idx] = newObject

    group.memberRemoved.dispatch(object)
    group.memberAdded.dispatch(newObject)

    return newObject
end)
Group.sort = Method.PUBLIC(function (group, comp)
    return table.sort(group.members, comp)
end)
Group.getFirstExisting = Method.PUBLIC(function (group)
    for i = 1, #group.members do
        if group.members[i] ~= nil and group.members[i].exists then
            return group.members[i]
        end
    end
end)
Group.getFirstAlive = Method.PUBLIC(function (group)
    for i = 1, #group.members do
        if group.members[i] ~= nil and group.members[i].exists and group.members[i].alive then
            return group.members[i]
        end
    end
end)
Group.getFirstDead = Method.PUBLIC(function (group)
    for i = 1, #group.members do
        if group.members[i] ~= nil and not group.members[i].alive then
            return group.members[i]
        end
    end
end)
Group.countLiving = Method.PUBLIC(function (group)
    local count = 0
    for i = 1, #group.members do
        if group.members[i] ~= nil and group.members[i].alive and group.members[i].exists then
            count = count + 1
        end
    end
    return count
end)
Group.countDead = Method.PUBLIC(function (group)
    local count = 0
    for i = 1, #group.members do
        if group.members[i] ~= nil and not group.members[i].alive then
            count = count + 1
        end
    end
    return count
end)
Group.getRandom = Method.PUBLIC(function (group, startIndex, length)
    if startIndex < 0 then startIndex = 1 end
    if length <= 0 then length = group.length end
    return group.members[math.random(startIndex, length)]
end)
Group.clear = Method.PUBLIC(function (group)
    group.members.forEach(function (member)
        group.remove(member)
    end)
    group.members = {}
end)
Group.kill = Method.PUBLIC(function (group)
    group.forEach(function (member)
        if member ~= nil and member.kill then
            member.kill()
        end
    end)
end)
Group.revive = Method.PUBLIC(function (group)
    group.forEach(function (member)
        if member ~= nil then
            member.revive()
        end
    end)
end)
Group.forEach = Method.PUBLIC(function (group, foreach)
    for i = 1, #group.members do
        if group.members[i] ~= nil then
            foreach(group.members[i])
        end
    end
end)
Group.forEachExists = Method.PUBLIC(function (group, foreach)
    for i = 1, #group.members do
        if group.members[i] ~= nil and group.members[i].exists then
            foreach(group.members[i])
        end
    end
end)
Group.forEachAlive = Method.PUBLIC(function (group, foreach)
    for i = 1, #group.members do
        if group.members[i] ~= nil and group.members[i].exists and group.members[i].alive then
            foreach(group.members[i])
        end
    end
end)
Group.forEachDead = Method.PUBLIC(function (group, foreach)
    for i = 1, #group.members do
        if group.members[i] ~= nil and not group.members[i].alive then
            foreach(group.members[i])
        end
    end
end)
Group.new = function (maxSize)
    local group = Group.create()
    group.members = {}
    group.maxSize = math.floor(math.abs(maxSize or 0))


    return group
end

return Group