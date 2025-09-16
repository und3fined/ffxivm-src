local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

---@class VersionMgr : MgrBase
local VersionMgr = LuaClass(MgrBase)

--现在还没配置到GameMgrConfig，以后有需要再配置
function VersionMgr:OnInit()
end

function VersionMgr:OnBegin()
end

function VersionMgr:OnEnd()
end

function VersionMgr:OnShutdown()
end

function VersionMgr:OnRegisterNetMsg()
end

function VersionMgr:OnRegisterGameEvent()
end

return VersionMgr
