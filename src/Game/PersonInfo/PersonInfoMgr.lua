---
--- Author: xingcaicao
--- DateTime: 2023-04-11 15:58:45
--- Description: 个人信息/个人名片
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local PersonInfoVM = require("Game/PersonInfo/VM/PersonInfoVM")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local ProtoCS = require("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local DataReportUtil = require("Utils/DataReportUtil")
local EventID = require("Define/EventID")
local ClientSetupID = require("Game/ClientSetup/ClientSetupID")
local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_GROUP_CMD
local NOTE_SUB_ID = ProtoCS.CS_NOTE_CMD 

---@class PersonInfoMgr : MgrBase
local Class = LuaClass(MgrBase)

function Class:OnInit()

end

function Class:OnBegin()
end

function Class:OnEnd()

end

function Class:OnShutdown()

end

function Class:OnRegisterNetMsg()
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_TEAM, ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CsSubCmdQueryByTeamID, self.OnNetQueryTeamInfo) -- 查询队伍
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUERY_EQUIP_GEM, 0, self.OnNetMsgQueryGemInfoByRole) -- 查询玩家魔晶石
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUERY_ROLESIMPLE, 0, self.OnNetMsgQueryRoleSimpleByRoleIDs) -- 查询玩家详情
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GROUP, SUB_MSG_ID.CS_CMD_GROUP_QUERY_ROLE_GROUP, self.OnNetMsgQueryArmyInfoByRole) -- 查询公会信息
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_NOTE, NOTE_SUB_ID.CS_CMD_SCENE_FINISH_LOG, self.OnSceneFinishLogRsp) -- 查询自己的已完成副本数据（服务器认为放在登录下发主角数据里有风险）
end

function Class:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.ClientSetupPost, self.OnEventClientSetupPost)
    self:RegisterGameEvent(_G.EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:RegisterGameEvent(_G.EventID.PWorldFinished, self.OnGameEventPWorldFinished)
end

function Class:OnGameEventLoginRes()
    ---获取自己的已完成副本数据
	self:SendSceneFinishLogReq()
end

function Class:OnGameEventPWorldFinished()
    ---获取自己的已完成副本数据
	self:SendSceneFinishLogReq()
end

function Class:OnNetMsgQueryGemInfoByRole( MsgBody )
    -- print('testinfo MsgBody = ' .. table.tostring(MsgBody))
	local Msg = MsgBody.EquipGems
	if nil == Msg then
		return
	end

    -- local RoleID = Msg.RoleID
    -- if nil == RoleID then
    --     return
    -- end

    local GemInfo = Msg
    local GemMap = {}
    for _, Item in pairs(GemInfo) do
        GemMap[Item.EquipPart] = Item.GemInfo
    end

    PersonInfoVM.GemMap = GemMap
end

---查询玩家魔晶石信息
---@param RoleID number @角色ID
function Class:SendQueryGemInfoByRoleID( RoleID )
	local MsgID = CS_CMD.CS_CMD_QUERY_EQUIP_GEM
	local SubMsgID = 0

	local MsgBody = {
        Cmd = SubMsgID,
        RoleID = RoleID
    }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function Class:OnEventClientSetupPost( EventParams )
	if nil == EventParams then
		return
	end

    local SetupKey = EventParams.IntParam1
    if SetupKey == ClientSetupID.ShownPortraitInitSaveTips then  -- 是否已提示初始肖像保存
        local Value = tonumber(EventParams.StringParam1)
        PersonInfoVM:UpdatePortraitInitSaveTipsRedDot(Value ~= 1)
    end
end

function Class:OnNetMsgQueryRoleSimpleByRoleIDs(MsgBody)
	local RoleList = MsgBody.RoleList
    if nil == RoleList then
        return
    end
    local CurRoleID = PersonInfoVM.RoleID

    for _, v in ipairs(RoleList) do
        if CurRoleID == (v or {}).RoleID then
            --穿戴的装备列表
            local EquipList = (v.Avatar or {}).EquipList
            -- table.sort(EquipList, function(a, b)  end)
            PersonInfoVM:SetOnEquipList(EquipList or {})
            return
        end
    end
end

function Class:OnNetMsgQueryArmyInfoByRole( MsgBody )
    -- 暂时不用了使用 GetArmySimpleDataByRoleIDs
    -- print('testinfo MsgBody = ' .. table.tostring(MsgBody))
	-- local Msg = MsgBody.RoleGroup
	-- if nil == Msg then
	-- 	return
	-- end

    -- local RoleID = Msg.RoleID
    -- if nil == RoleID then
    --     return
    -- end

    -- -- 公会简要信息, group.GroupSimpleInfo
    -- PersonInfoVM:SetArmySimpleInfo(RoleID, Msg.Simple)
end

-- ---查询玩家详情信息
-- ---@param RoleID number @角色ID
-- function Class:SendQueryRoleSimpleByRoleID( RoleID )
-- 	local MsgID = CS_CMD.CS_CMD_QUERY_ROLESIMPLE
-- 	local SubMsgID = 0
-- 	local MsgBody = { RoleIDList = { RoleID } }

-- 	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
-- end

---查询玩家部队信息
---@param RoleID number @角色ID
function Class:SendQueryArmyInfoByRoleID( RoleID )
    _G.ArmyMgr:GetArmySimpleDataByRoleIDs({RoleID}, function (GroupSimples)
        for _, GroupSimple in pairs(GroupSimples) do
            if GroupSimple.RoleID == RoleID then
                local Simple = GroupSimple.Simple or {}
                Simple.GroupPetition = GroupSimple.GroupPetition
                Simple.RoleGroupState = GroupSimple.State

                PersonInfoVM:SetArmySimpleInfo(RoleID, Simple)
            end
        end
    end, nil)
end

function Class:SendSceneFinishLogReq()
	local MsgID = CS_CMD.CS_CMD_NOTE
	local SubMsgID = NOTE_SUB_ID.CS_CMD_SCENE_FINISH_LOG

	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function Class:ShowPersonInfoArmyTipsView()
    local RoleID = PersonInfoVM.ArmyLeaderRoleID
    if nil == RoleID then
        return
    end

	_G.RoleInfoMgr:QueryRoleSimple(RoleID, function()
        -- UIViewMgr:ShowView(UIViewID.PersonInfoArmyPanel)
        _G.ArmyMgr:OpenArmyJoinInfoPanel(RoleID)
    end, nil, false)
end

---查询玩家部队信息
---@param TeamID number @角色ID
function Class:SendQueryTeamInfo( TeamID )
    local SUB_MSG_ID = ProtoCS.Team.Team.CS_SUBMSGID_TEAM.CsSubCmdQueryByTeamID
    local CMD = ProtoCS.CS_CMD.CS_CMD_TEAM

	local MsgBody = {
        SubCmd = SUB_MSG_ID,
        QueryByTeam = { TeamID = TeamID },
    }

    _G.FLOG_INFO(string.format('[PersonInfo][PersonInfoMgr][SendQueryTeamInfo] MsgBody = %s', table.tostring(MsgBody)))

	GameNetworkMgr:SendMsg(CMD, SUB_MSG_ID, MsgBody)
end

function Class:OnNetQueryTeamInfo(MsgBody)
    _G.FLOG_INFO(string.format('[PersonInfo][PersonInfoMgr][OnNetQueryTeamInfo] MsgBody = %s', table.tostring(MsgBody)))

    if not MsgBody then
        return
    end

    local Resp = MsgBody.QueryByTeam

    if Resp then
        _G.EventMgr:SendEvent(_G.EventID.TeamNumberInfoQuerySucc, {Cnt = Resp.MemberNum})
    end
end

-------------------------------------------------------------------------------------------------
--- 对外接口

---打开个人简略信息界面
---@param RoleID number @角色ID
---@param Source PersonInfoDefine.SimpleViewSource @来源，默认SimpleViewSource.Default
function Class:ShowPersonalSimpleInfoView( RoleID, Source )

    if UIViewMgr:IsViewVisible(UIViewID.PersonInfoMainPanel) then
        -- can not open panel cyclic
        return 
    end

    local MajorRoleID = MajorUtil.GetMajorRoleID()

    if nil == RoleID or UIViewMgr:IsViewVisible(UIViewID.PersonInfoSimplePanel) then
        return
    end

    if RoleID == MajorRoleID then
        -- print("can't open card, because it's the major")
        return
    end

    -- 某些场景下屏蔽显示个人信息界面
    if _G.PWorldMgr:CurrIsInPVPColosseum() then
        return
    end

    if RoleID == PersonInfoVM.RoleID then
        PersonInfoVM:Clear()
    end

    PersonInfoVM:SetRoleID(RoleID)

    PersonInfoVM.ArmySimpleInfo = nil
    self:SendQueryArmyInfoByRoleID(RoleID)

	_G.RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
        PersonInfoVM:UpdateRoleInfo(RoleVM)
        _G.ArmyMgr:GetArmySimpleDataByRoleIDs({RoleID}, function()

            if RoleVM.IsCancellation then
                MsgTipsUtil.ShowTips(_G.LSTR(620141))
                return
            end

            UIViewMgr:ShowView(UIViewID.PersonInfoSimplePanel, {Source = Source})
        end, nil)
    end, nil, false)
end

---打开个人信息界面
---@param RoleID number @角色ID
function Class:ShowPersonInfoView( RoleID )
    if nil == RoleID or UIViewMgr:IsViewVisible(UIViewID.PersonInfoMainPanel) then
        return
    end

    if RoleID == PersonInfoVM.RoleID then
        PersonInfoVM:Clear()
    end

    PersonInfoVM:SetRoleID(RoleID)
    self:SendQueryArmyInfoByRoleID(RoleID)
    self:SendQueryGemInfoByRoleID( RoleID )

	_G.RoleInfoMgr:QueryRoleSimple(RoleID, function(_, RoleVM)
        if RoleVM.IsCancellation then
            return
        end
        
        PersonInfoVM:UpdateRoleInfo(RoleVM)
        UIViewMgr:ShowView(UIViewID.PersonInfoMainPanel)
    end, nil, false)
end

---打开个人信息主页界面
---@param Source PersonInfoDefine.SimpleViewSource @来源，默认SimpleViewSource.Default
function Class:OpenHomePage(Source)
    if nil == PersonInfoVM.RoleID then
        return
    end

    PersonInfoVM.DataRef = PersonInfoVM.DataRef + 1
    UIViewMgr:ShowView(UIViewID.PersonInfoMainPanel, {Source = Source})
end

function Class:ReportSystemFlowData(Type)
    DataReportUtil.ReportSystemFlowData("NameplateFunctionFlow", Type)
end

function Class:OnSceneFinishLogRsp(MsgBody)
	self.SceneFinishLogs = MsgBody.SceneFinishLog.SceneFinishLogs
end

function Class:GetMajorSceneFinishLogs()
	return self.SceneFinishLogs
end

return Class