local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCommon = require("Protocol/ProtoCommon")
local PWorldQuestDefine = require("Game/PWorld/Quest/PWorldQuestDefine")

local Json = require("Core/Json")
local SaveKey = require("Define/SaveKey")
local USaveMgr = _G.UE.USaveMgr

local PWorldEntMgr = LuaClass(MgrBase)
local EventID

function PWorldEntMgr:OnInit()
end

function PWorldEntMgr:OnBegin()
    EventID = _G.EventID
	self.TaskOpCache = {}
end

function PWorldEntMgr:OnEnd()

end

function PWorldEntMgr:OnShutdown()
	self.TaskOpCache = {}
end

function PWorldEntMgr:OnRegisterNetMsg()
    --
end

function PWorldEntMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MajorProfSwitch ,            self.OnMajorProfCHG)
	self:RegisterGameEvent(EventID.TeamRecruitTaskSetConfirm ,  self.OnEveTeamRecruitTaskUpd)
end

function PWorldEntMgr:OnMajorProfCHG(ProfID)
    local PWorldEntDetailVM = require("Game/PWorld/Entrance/PWorldEntDetailVM")
    PWorldEntDetailVM:Flush()
end

local function TaskID2Idx(ID)
    return ID + 1
end

function PWorldEntMgr:OnEveTeamRecruitTaskUpd(Param)
    self:SetTaskOpCache(Param.PWorldEntID, TaskID2Idx(Param.Task))
end

function PWorldEntMgr:SetTaskOpCache(EntID, V)
    self.TaskOpCache[EntID] = V
end

function PWorldEntMgr:GetTaskOpCache(EntID, EntTy)
    local Ret = self.TaskOpCache[EntID]
    if Ret == nil then
        if EntTy == ProtoCommon.ScenePoolType.ScenePoolChocobo
                or EntTy == ProtoCommon.ScenePoolType.ScenePoolChocoboRandomTrack then
            Ret = PWorldQuestDefine.TaskType2Idx.SceneModeChocboRank
        else
            Ret = PWorldQuestDefine.TaskType2Idx.SceneModeNormal
        end
    end
    
    return Ret
end

function PWorldEntMgr:HasPWEVisited(EntID)
    local JsonStr = USaveMgr.GetString(SaveKey.PWEVisitState, "", true)
    if string.isnilorempty(JsonStr) then
        return false
    end

    local Dict = Json.decode(JsonStr)

    return Dict[tostring(EntID)]
end

function PWorldEntMgr:SetPWEVisited(EntID)
    local JsonStr = USaveMgr.GetString(SaveKey.PWEVisitState, "", true)
    local Dict = string.isnilorempty(JsonStr) and {} or Json.decode(JsonStr)
    Dict[tostring(EntID)] = true
    local SaveStr = Json.encode(Dict)
    USaveMgr.SetString(SaveKey.PWEVisitState, SaveStr, true)
end

return PWorldEntMgr
