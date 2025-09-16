local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local UIBindableList = require("UI/UIBindableList")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local TaskItemVM = require("Game/Ops/VM/OpsCrystalSunmmoingTaskItemVM")
local InviteItemVM = require("Game/Ops/VM/OpsCrystalSunmmoingInviteItemVM")
local NodeType = ProtoRes.Game.ActivityNodeType

local OpsCrystalSunmmoingVM = LuaClass(UIViewModel)
local CsRewardStatus = ProtoCS.Game.Activity.RewardStatus
local ActTypeDefine = {
    Invitee = 1,
    Inviter = 2
}

function OpsCrystalSunmmoingVM:Ctor()
    self.TaskVMList = UIBindableList.New(TaskItemVM)
    self.InviteVMList = UIBindableList.New(InviteItemVM)
    
    self.CurActType = ActTypeDefine.Invitee
    self.InviteCode = ""  -- 我的邀请码
    self.HasBindCode = "" -- 已绑定邀请码
    self.GetInviteListNodeID = 0
    self.BindNodeID = 0
    self.BindReward = {}
    self.TaskData = {}
    self.BindRoleData = {}
    self.BindTotalNum = 0
    self.StrParamText1 = ""
    self.StrParamText2 = ""
    self.ShareParams = {}
end

local SortRule = {
    [CsRewardStatus.RewardStatusWaitGet] = 3,
    [CsRewardStatus.RewardStatusNo] = 2,
    [CsRewardStatus.RewardStatusDone] = 1,
}

local function FillNodeData(v, NodeCfg)
    local Node = {}
    local ExtraData = v.Extra or {}
    local RewardStatus = v.Head.RewardStatus
    Node.Index = 0
    Node.NodeID = v.Head.NodeID
    Node.NodeDes = NodeCfg.NodeDesc
    Node.TotalTask = NodeCfg.Target
    Node.FinishedTask = ExtraData.Progress and ExtraData.Progress.Value or 0
    Node.RewardStatus = RewardStatus
    Node.Rewards = NodeCfg.Rewards
    Node.JumpType1 = NodeCfg.JumpType
    Node.JumpID1 = tonumber(NodeCfg.JumpParam) or 0
    Node.Sort = SortRule[RewardStatus] 
    Node.NodeSort = NodeCfg.NodeSort or v.Head.NodeID
    return Node
end

function OpsCrystalSunmmoingVM:Update(ActivityData)
    local Activity = ActivityData.Activity
    self.ActivityID = Activity.ActivityID
    local NodeList = ActivityData.NodeList
    local TaskData = {}
    for i, v in ipairs(NodeList) do
        if not v.Head.EmergencyShutDown then
            local ExtraData = v.Extra or {}
            local NodeCfg = ActivityNodeCfg:FindCfgByKey(v.Head.NodeID) or {}
            if NodeCfg.NodeType == NodeType.ActivityNodeTypeBindInviterCode then
                self.CurActType = ActTypeDefine.Invitee
                self.BindNodeID = NodeCfg.NodeID
                self.BindReward = NodeCfg.Rewards[1]
                local ParamName = ExtraData.Data and ExtraData.Data or "BindCode"
                self.HasBindCode = ExtraData[ParamName] and ExtraData[ParamName].Code or ""
            elseif NodeCfg.NodeType == NodeType.ActivityNodeTypeShareInviterCode then
                self.CurActType = ActTypeDefine.Inviter
                self.ShareParams = NodeCfg.Params
                self.ShareRewardStatus = v.Head.RewardStatus
                table.insert(TaskData, FillNodeData(v, NodeCfg))
            elseif NodeCfg.NodeType == NodeType.ActivityNodeTypeCreatInviteCode then
                local ParamName = ExtraData.Data and ExtraData.Data or "InviterCode"
                self.InviteCode = ExtraData[ParamName] and ExtraData[ParamName].InviterCode or ""
                self.BindTotalNum = NodeCfg.Params and NodeCfg.Params[1] or 0
            elseif NodeCfg.NodeType == NodeType.ActivityNodeTypeBindInvitee then
                table.insert(TaskData, FillNodeData(v, NodeCfg))
            elseif NodeCfg.NodeType == NodeType.ActivityNodeTypeInviteeBindList then
                self.GetInviteListNodeID = NodeCfg.NodeID
                local SplitList = string.split(NodeCfg.StrParam, "|")
                for i, v in ipairs(SplitList) do
                    if self["StrParamText".. i] then
                        self["StrParamText".. i] = _G.LSTR(tonumber(v))
                    else
                        self.PreviewMonutID = tonumber(v)
                    end
                end
            else
                table.insert(TaskData, FillNodeData(v, NodeCfg))
            end
        end
    end

    self.TaskData = TaskData
    table.sort(self.TaskData,function(l, r) 
        if l.Sort ~= r.Sort  then
            return l.Sort > r.Sort 
        else
            return l.NodeSort > r.NodeSort 
        end
    end)

    for i = 1, #self.TaskData, 1 do
        self.TaskData[i].RealIndex = i
    end

    if next(self.TaskData) then
        self.TaskVMList:UpdateByValues(self.TaskData)
    end
end

function OpsCrystalSunmmoingVM:GetHasBindInviteCode()
    return self.HasBindCode
end

function OpsCrystalSunmmoingVM:IsInviteeType()
    return self.CurActType == ActTypeDefine.Invitee
end

function OpsCrystalSunmmoingVM:GetBindReward()
    return self.BindReward
end

function OpsCrystalSunmmoingVM:GetInviteCode()
    return self.InviteCode
end

function OpsCrystalSunmmoingVM:GetBindTotalNum()
    return self.BindTotalNum
end

function OpsCrystalSunmmoingVM:GetEmptyRoleData(Index)
    local EmptyRoleData = 
    {
        IsEmptyRole = 1, 
        ShareParams = self.ShareParams,
        NodeType = NodeType.ActivityNodeTypeShareInviterCode,
        ShareRewardStatus = self.ShareRewardStatus,
        RealIndex = Index,
        InviteCode = self.InviteCode,
        ActivityID = self.ActivityID,
    }   

    return EmptyRoleData
end

function OpsCrystalSunmmoingVM:SetInviteList(RoleData)
    local BindTotalNum = self:GetBindTotalNum() or 10
    if not next(RoleData) then
        local Data = {}
        for i = 1, BindTotalNum, 1 do
            table.insert(Data, self:GetEmptyRoleData(i))
        end
    
        self.InviteVMList:UpdateByValues(Data)
    else
        self.InviteVMList:UpdateByValues({})
        local QueryList = {}
        for i, v in ipairs(RoleData) do
            QueryList[i] = v.RoleID
        end

        _G.RoleInfoMgr:QueryRoleSimples(QueryList, function()
            local NowTime = _G.TimeUtil.GetServerTime()
            local FinalRoleData = {}
            for i, v in ipairs(RoleData) do
                local RoleVM = _G.RoleInfoMgr:FindRoleVM(v.RoleID)
                if RoleVM then
                    local TempData = {
                        ProfID = v.ProfID,
                        RoleID = v.RoleID,
                        Level = v.Level,
                        OnlineStatusIcon = RoleVM.OnlineStatusIcon,
                        Name = RoleVM.Name,
                        IsOnline = RoleVM.IsOnline,
                        OpenID = RoleVM.OpenID,
                        GetInviteListNodeID = self.GetInviteListNodeID,
                        LoginTime = RoleVM.LoginTime,
                    }

                    if RoleVM.LogoutTime == 0 or TempData.IsOnline then
                        TempData.LogoutTime = NowTime
                    else
                        TempData.LogoutTime = RoleVM.LogoutTime
                    end

                    table.insert(FinalRoleData, TempData)
                end
            end

            table.sort(FinalRoleData, function(l, r)
                if l.IsOnline and r.IsOnline then
                    return l.LoginTime > r.LoginTime
                else
                    if l.LogoutTime ~= r.LogoutTime  then
                        return l.LogoutTime > r.LogoutTime
                    else
                        return l.Level > r.Level 
                    end
                end
            end)

            for i = 1, BindTotalNum, 1 do
                if FinalRoleData[i] then
                    FinalRoleData[i].RealIndex = i
                else
                    table.insert(FinalRoleData, self:GetEmptyRoleData(i))
                end
            end

            self.InviteVMList:UpdateByValues(FinalRoleData)
        end, nil, false)
    end
end

return OpsCrystalSunmmoingVM
