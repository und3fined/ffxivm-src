local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local OpsTeamUpPanelVM = require("Game/Ops/VM/OpsTeamUp/OpsTeamUpMainPanelVM")
local OpsTeamUpDefine = require("Game/Ops/OpsTeamUp/OpsTeamUpDefine")
local ActivityCfg = require("TableCfg/ActivityCfg")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local EventID = require("Define/EventID")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local NodeOpType = ProtoCS.Game.Activity.NodeOpType
local OpsActivityMgr
local ModuleOpenMgr

---@class OpsTeamUpMgr : MgrBase
local OpsTeamUpMgr = LuaClass(MgrBase)

---OnInit
function OpsTeamUpMgr:OnInit()
    
end

function OpsTeamUpMgr:OnBegin()
    OpsActivityMgr = _G.OpsActivityMgr
    ModuleOpenMgr = _G.ModuleOpenMgr
end

function OpsTeamUpMgr:OnEnd()
end

function OpsTeamUpMgr:OnShutdown()

end

function OpsTeamUpMgr:OnRegisterNetMsg()

end

function OpsTeamUpMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.OpsActivityUpdateInfo, self.UpdateMembers)
	self:RegisterGameEvent(EventID.OpsActivityUpdate, self.UpdateMembersRedDot)
	self:RegisterGameEvent(EventID.OpsActivityNodeChanged, self.UpdateChangedMembers)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
end

function OpsTeamUpMgr:OnGameEventLoginRes(Params)
	if not ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDActivitySystem) then
        return
    end
    self.NeedQueryData = true
	-- self:SendShareTeamMembersNodeOperate()
end

function OpsTeamUpMgr:SendShareTeamMembersNodeOperate()
    _G.OpsActivityMgr:SendActivityNodeOperate(OpsTeamUpDefine.MemberNodeID, ProtoCS.Game.Activity.NodeOpType.NodeOpTypeShareTeamMembers, {})
end

function OpsTeamUpMgr:UpdateMembersRedDot()
    ---需要等活动中心查询完数据后，判断是否请求数据
    if self.NeedQueryData then
        self.NeedQueryData = false
        local CfgData = OpsTeamUpMgr:GetActivityCfgData()
        if CfgData and CfgData.ClassifyID then
            local ActivityList = OpsActivityMgr:GetActivityListByClassify(CfgData.ClassifyID)
            if ActivityList then
                local IsOpen = table.find_by_predicate(ActivityList, function(Data)
                    return Data.Activity.ActivityID == OpsTeamUpDefine.TeamUpActivityID
                end)
                if IsOpen then
                    self:SendShareTeamMembersNodeOperate()
                end
            end
        end
    end
    if self.Members then
        OpsTeamUpPanelVM:UpdataTeamMember(self.Members)
    end
end

function OpsTeamUpMgr:UpdateMembers(Msg)
    ---可能不是节点请求触发的事件
    if Msg == nil then
        return
    end
    local Data = Msg.NodeOperate
    if Data and Data.OpType == NodeOpType.NodeOpTypeShareTeamMembers then
        local MemberData 
        ---服务器改了，可能为空，需要处理
        if Data.Result == nil then
            self.Members = {}
            OpsTeamUpPanelVM:UpdataTeamMember(self.Members)
        else
            MemberData = Data.Result.TeamMember
            if MemberData then
                self.Members = MemberData.Members
                OpsTeamUpPanelVM:UpdataTeamMember(self.Members)
            end
        end
    end
end

function OpsTeamUpMgr:UpdateChangedMembers(NodeList)
    ---如果是节点变更，重新拉一次数据更新红点
    if NodeList then
        for _, Node in ipairs(NodeList) do
            if Node.Head.NodeID == OpsTeamUpDefine.MemberNodeID then
                self:SendShareTeamMembersNodeOperate()
                break
            end
        end
    end
end

--------------------------------------------------表格数据获取 start -------------------------------------------------------
function OpsTeamUpMgr:GetRewardCfgDataByNodeID(NodeID)
    local NodeData = ActivityNodeCfg:FindCfgByKey(NodeID)
    if NodeData then
        return NodeData.Rewards
    end
end

function OpsTeamUpMgr:GetCfgDataByNodeID(NodeID)
    local NodeData = ActivityNodeCfg:FindCfgByKey(NodeID)
    if NodeData then
        return NodeData
    end
end

function OpsTeamUpMgr:GetActivityCfgData()
    return self:GetActivityCfgDataByID(OpsTeamUpDefine.TeamUpActivityID)
end

function OpsTeamUpMgr:GetActivityCfgDataByID(ActivityID)
    local ActivityData = ActivityCfg:FindCfgByKey(ActivityID)
    if ActivityData then
        return ActivityData
    end
end
--------------------------------------------------表格数据获取 end -------------------------------------------------------

function OpsTeamUpMgr:NodeJump(NodeID)
    local CfgData = ActivityNodeCfg:FindCfgByKey(NodeID)
    if CfgData then
        OpsActivityMgr:Jump(CfgData.JumpType, CfgData.JumpParam)
    end
end

--要返回当前类
return OpsTeamUpMgr