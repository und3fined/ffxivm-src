local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local LogMgr = require("Log/LogMgr")
local OpsActivityDefine = require("Game/Ops/OpsActivityDefine")
local OpsCeremonyDefine = require("Game/Ops/View/OpsCeremony/OpsCeremonyDefine")
local ActivityCfg = require("TableCfg/ActivityCfg")
local ProtoRes = require("Protocol/ProtoRes")
local SaveKey = require("Define/SaveKey")
local TimeUtil = require("Utils/TimeUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local JumpUtil = require("Utils/JumpUtil")
local AccountUtil = require("Utils/AccountUtil")
local PayUtil = require("Utils/PayUtil")
local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
local ActivityPageCfg = require("TableCfg/ActivityPageCfg")
local ModuleOpenCfg = require("TableCfg/ModuleOpenCfg")
local CommercializationRandConsumeCfg = require("TableCfg/CommercializationRandConsumeCfg")
local FestivalLayersetCfg = require("TableCfg/FestivalLayersetCfg")
local TimeZoneOffset = ProtoRes.Game.TimeZoneOffset
local FLOG_WARNING = LogMgr.Warning
local LSTR
local GameNetworkMgr
local UIViewMgr
local RedDotMgr
local EventMgr
local USaveMgr
local ModuleOpenMgr
local GoldSauserCeremonyMgr
local MsgTipsUtil
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.Game.Activity.Cmd
local OPS_JUMP_TYPE = ProtoRes.Game.OPS_JUMP_TYPE
local ActivityNodeType = ProtoRes.Game.ActivityNodeType
local ActivityType =ProtoRes.Game.ActivityType

---@class OpsActivityMgr : MgrBase
local OpsActivityMgr = LuaClass(MgrBase)

---OnInit
function OpsActivityMgr:OnInit()
	self.QueryActivityList = false

	self.IDIPActivitys = {}
	self.IDIPActivityNodes = {}
	
	self.CommonActivitysMap = {}
	self.SeasonActivitys = {}
	self.ActivityNodeMap = {}
end

function OpsActivityMgr:OnBegin()
	LSTR = _G.LSTR
	GameNetworkMgr = _G.GameNetworkMgr
	UIViewMgr = _G.UIViewMgr
	RedDotMgr = _G.RedDotMgr
	EventMgr = _G.EventMgr
	USaveMgr = _G.UE.USaveMgr
	ModuleOpenMgr = _G.ModuleOpenMgr
	GoldSauserCeremonyMgr = _G.GoldSauserCeremonyMgr
	MsgTipsUtil = _G.MsgTipsUtil
	OpsActivityDefine.RedDotName = RedDotMgr:GetRedDotNameByID(OpsActivityDefine.RedDotID) or ""

	self:ReadSaveKeyData()
	self:InitOpsActivityRedDotFun()

	self.LoadLayerMapEditCfgMap = {}
	self.CacheLayerIDs = nil
end


function OpsActivityMgr:OnEnd()
end

function OpsActivityMgr:OnShutdown()

end

function OpsActivityMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, SUB_MSG_ID.List, self.OnNetMsgQueryActivityList) -- 查询活动信息
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, SUB_MSG_ID.Detail, self.OnNetMsgQueryActivity) -- 查询单个活动详情
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, SUB_MSG_ID.ListByID, self.OnNetMsgQueryActivityListByID) -- 查询多个活动详情
	
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, SUB_MSG_ID.ChgNotify, self.OnNetMsgActivityChgNotify) -- 活动信息变化通知
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, SUB_MSG_ID.Reward, self.OnNetMsgNodeGetReward) -- 领取活动节点奖励
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, SUB_MSG_ID.NodeOperate, self.OnNetMsgNodeOperate) -- 节点操作
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, SUB_MSG_ID.EventReport, self.OnNetMsgActivityEventReport) -- 事件上报
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, SUB_MSG_ID.ActReward, self.OnNetMsgActivityGetReward) -- 领取指定活动所有节点奖励
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ACTIVITY_SYSTEM, SUB_MSG_ID.NodesChange, self.OnNetMsgNodeChangeNotify) -- 活动节点变化通知
	---拉回流活动的网络时间注册
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_QUERY_LAST_LOGIN_ROLES, 0, self.OnNetMsgQueryLastLoginRoles) -- 领取指定活动所有节点奖励

end

function OpsActivityMgr:OnRegisterGameEvent()

	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify) --系统解锁

    self:RegisterGameEvent(EventID.PandoraShowRedot, self.OnUpdatePandoraActivityRedot)
	self:RegisterGameEvent(EventID.SinkActivityToBottom, self.OnUpdatePandoraActivityToBottom)
end

function OpsActivityMgr:OnUpdatePandoraActivityRedot(Params)
	if Params == nil then
		return
	end
	for key, value in pairs(self.CommonActivitysMap) do
		local Activitys = value or {}
		for i = 1, #Activitys do
			local Activity = Activitys[i].Activity
			if (Activity.ActivityType == ActivityType.ActivityTypePandora and Activity.Title == Params.AppId) then
				self:UpdateActivityRedDot(key, Activity)
				EventMgr:SendEvent(EventID.OpsActivityUpdate)
				return
			end
		end
	end

end

function OpsActivityMgr:OnUpdatePandoraActivityToBottom(Params)
	if Params == nil then
		return
	end
	for key, value in pairs(self.CommonActivitysMap) do
		local Activitys = value or {}
		for i = 1, #Activitys do
			local Activity = Activitys[i].Activity
			if (Activity and Activity.ActivityType == ActivityType.ActivityTypePandora and Activity.Title == Params.AppId) then
				if self.ActivityNodeMap and self.ActivityNodeMap[Activity.ActivityID] then
					self.ActivityNodeMap[Activity.ActivityID].ActivityFinish = _G.PandoraMgr:IsActivityNeedToSinkToBottom(Activity.Title)
					EventMgr:SendEvent(EventID.OpsActivityUpdate)
					return
				end
			end
		end
	end
end

function OpsActivityMgr:OnGameEventLoginRes(Params)
	if not ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDActivitySystem) then
        return
    end
	self:SendQueryActivityList()
end


function OpsActivityMgr:OnModuleOpenNotify(InModuleID)
    if InModuleID == ProtoCommon.ModuleID.ModuleIDActivitySystem then
        self:SendQueryActivityList()
    end
end

---查询活动简单信息
function OpsActivityMgr:SendQueryActivityList( )
	local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
	local SubMsgID = SUB_MSG_ID.List

	local MsgBody = {
        Cmd = SubMsgID,
    }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function OpsActivityMgr:SendQueryActivityListByID(ListByIDs)
	if ListByIDs == nil then
		return
	end
    local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
    local SubMsgID = SUB_MSG_ID.ListByID 

    local MsgBody = {}
	MsgBody.Cmd = SubMsgID

    MsgBody.ListByID = {ActIDs = ListByIDs}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


function OpsActivityMgr:OnNetMsgQueryActivityListByID(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.ListByID then
		return
	end
	local Data = MsgBody.ListByID

	local ActivityList = Data.Details or {}
	for i = 1, #ActivityList do
		self:SetActivityInfo(ActivityList[i])
	end

	EventMgr:SendEvent(EventID.OpsActivityUpdate)
	
end


function OpsActivityMgr:OnNetMsgQueryActivityList(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.List then
		return
	end
	local List = MsgBody.List
	local IDIPCfgs = List.Cfgs or {}
	self.IDIPActivitys = IDIPCfgs.Acts or {}
	self.IDIPActivityNodes = IDIPCfgs.Nodes or {}
	
	self.CommonActivitysMap = {}
	self.SeasonActivitys = {}

	RedDotMgr:DelRedDotByName(OpsActivityDefine.RedDotName)
	local ActivityList = List.Details or {}
	for i = 1, #ActivityList do
		self:SetActivityInfo(ActivityList[i])
	end
	self.QueryActivityList = true


	EventMgr:SendEvent(EventID.OpsActivityUpdate)
end

function OpsActivityMgr:FindActivityCfgByIDIP(ActivityID)
	if self.IDIPActivitys == nil then
		return
	end

	for i = 1, #self.IDIPActivitys do
		local Act = self.IDIPActivitys[i]
		if Act and Act.ActivityID == ActivityID then
			return self.IDIPActivitys[i]
		end
	end
end

function OpsActivityMgr:FindActivityNodeCfgByIDIP(ActivityNodeID)
	if self.IDIPActivityNodes == nil then
		return
	end

	for i = 1, #self.IDIPActivityNodes do
		local ActivityNode = self.IDIPActivityNodes[i]
		if ActivityNode and ActivityNode.NodeID == ActivityNodeID then
			return self.IDIPActivityNodes[i]
		end
	end

end

function OpsActivityMgr:GetCommonClassifyList()
	local ClassifyList = {}
	if self.CommonActivitysMap == nil then
		return ClassifyList
	end

	for key, value in pairs(self.CommonActivitysMap) do
		local Activitys = value or {}
		if #Activitys > 0 then
			local PageCfg = ActivityPageCfg:FindCfgByKey(key) or {}
			local ModuleCfg = ModuleOpenCfg:FindCfgByKey(PageCfg.UnLockID) or {}
			if ModuleOpenMgr:CheckOpenState(ModuleCfg.ModuleID) == true then
				table.insert(ClassifyList, {Classcify = key})
			end
		end
	end
	table.sort(ClassifyList, OpsActivityDefine.SortPagePredicate)
	return ClassifyList
end

function OpsActivityMgr:IsNewBieStrategyFinish()
	local IsNewBieStrategyFinish = _G.OpsNewbieStrategyMgr:IsNewBieStrategyFinish()
	return IsNewBieStrategyFinish
end

--获取页签下的常规活动数据列表
function OpsActivityMgr:GetActivityListByClassify(ClassifyID)
	local ActivityList = {}
	if self.CommonActivitysMap == nil then
		return ActivityList
	end

	local Activitys = self.CommonActivitysMap[ClassifyID] or {}
	for i = 1, #Activitys do
		local Activity = Activitys[i].Activity
		if (Activity.ActivityType == ActivityType.ActivityTypePandora and _G.PandoraMgr:IsActivityReady(Activity.Title) == true) or Activity.ActivityType == ActivityType.ActivityTypeNormal then
			local Detail = self.ActivityNodeMap[Activity.ActivityID] or {}
			table.insert(ActivityList, {Activity = Activity, Detail = Detail})
		end
	end
	table.sort(ActivityList, OpsActivityDefine.SortActivityPredicate)
	return ActivityList
end

---查询活动信息
function OpsActivityMgr:SendQueryActivity(ActivityID)
	local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
	local SubMsgID = SUB_MSG_ID.Detail

	local MsgBody = {
        Cmd = SubMsgID,
		Detail = { ActID = ActivityID },
    }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function OpsActivityMgr:OnNetMsgQueryActivity(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.Detail then
		return
	end
	local Detail = MsgBody.Detail
	self:SetActivityInfo(Detail.Detail)

	EventMgr:SendEvent(EventID.OpsActivityUpdate)
end

function OpsActivityMgr:OnNetMsgActivityChgNotify(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.ChgNotify then
		return
	end

	local Acts = MsgBody.ChgNotify.Acts or {}
	local ListByIDs = {}
	local HasRemoveActivitys = false
	for i = 1, #Acts do
		local ActivityID = Acts[i].ActID
		--状态(未显示0->显示中1->运行中2->已结束3->已删除4)
		if Acts[i].Status == 0 or Acts[i].Status == 1 or Acts[i].Status == 2 then
			table.insert(ListByIDs, ActivityID)
		elseif Acts[i].Status == 3 or Acts[i].Status == 4 then
			HasRemoveActivitys = true
            GoldSauserCeremonyMgr:CheckTheNewActiveCereKey(ActivityID)
			self:RemoveActivityFromSeasonActivitys(ActivityID)
			_G.QuestMgr.QuestRegister:RegisterActivity(ActivityID, false)
			EventMgr:SendEvent(EventID.RemoveActivity, {Acts = Acts[i]})
			local Cfg = ActivityCfg:FindCfgByKey(ActivityID)
			if Cfg ~= nil and (Cfg.ActivityType == ActivityType.ActivityTypeNormal or Cfg.ActivityType == ActivityType.ActivityTypePandora) then
				RedDotMgr:DelRedDotByName(self:GetRedDotName(Cfg.ClassifyID, ActivityID))
			end
			
		end
	end

	if HasRemoveActivitys then
		_G.EventMgr:SendEvent(EventID.SeasonActivityUpdatRedDot)
	end

	if #ListByIDs > 0 then
		self:RegisterTimer(function()
			OpsActivityMgr:SendQueryActivityListByID(ListByIDs)
			GoldSauserCeremonyMgr:CheckSendReq(ListByIDs)
		end, 10, 0, 1)
	else
		EventMgr:SendEvent(EventID.OpsActivityUpdate)
	end

end

function OpsActivityMgr:OnNetMsgNodeChangeNotify(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.NodesChange then
		return
	end

	local NodeChangeNotify = MsgBody.NodesChange or {}
	local NodesList = NodeChangeNotify.Nodes or {}
	for i = 1, #NodesList do
		self:UpdateActivityNode(NodesList[i])
	end

	EventMgr:SendEvent(EventID.OpsActivityUpdate)
end

--刷新活动
function OpsActivityMgr:SetActivityInfo(ActivityDate)
	if ActivityDate == nil then
		return
	end
	local ActivityHead = ActivityDate.Head
	local ActivityID = ActivityHead.ActivityID
	local Cfg = ActivityCfg:FindCfgByKey(ActivityID)
	if Cfg == nil then
		_G.FLOG_WARNING("OpsActivityMgr:SetActivityInfo  can't find cfg, ActivityID =%d", ActivityID)
		return 
	end

	
	local ShowMinVersion = Cfg.ShowMinVersion or ""
	local ShowMaxVersion = Cfg.ShowMaxVersion or ""

	if ShowMinVersion ~= "" and not _G.ClientVisionMgr:CheckVersionByGlobalVersion(ShowMinVersion) then
		_G.FLOG_WARNING("OpsActivityMgr:SetActivityInfo  ActivityID = %d, ShowMinVersion = %s > GameVersion", ActivityID, ShowMinVersion)
		return
	end

	if ShowMaxVersion ~= "" and  ShowMaxVersion ~= UE.UVersionMgr.GetGameVersion() and _G.ClientVisionMgr:CheckVersionByGlobalVersion(ShowMaxVersion) then
		_G.FLOG_WARNING("OpsActivityMgr:SetActivityInfo  ActivityID = %d, ShowMaxVersion = %s < GameVersion", ActivityID, ShowMaxVersion)
		return
	end

	if Cfg.ActivityType == ActivityType.ActivityTypeNormal or Cfg.ActivityType == ActivityType.ActivityTypePandora then
		self:RemoveActivityFromCommonActivitysMap(Cfg.ClassifyID, ActivityID)
		if ActivityHead.EmergencyShutDown == false and not ActivityHead.Hiden then
			self:AddActivityToCommonActivitysMap(Cfg.ClassifyID, {Activity = Cfg})
		end
	elseif Cfg.ActivityType == ActivityType.ActivityTypeSeasonal then
		self:RemoveActivityFromSeasonActivitys(ActivityID)
		if ActivityHead.EmergencyShutDown == false and not ActivityHead.Hiden then
			self:AddActivityToSeasonActivitys({Activity = Cfg})
		end
	else
		return
	end

	if self.ActivityNodeMap == nil then
		self.ActivityNodeMap = {}
	end 

	if ActivityHead.EmergencyShutDown == false then
		local NodeList = {}
		local Nodes = ActivityDate.Nodes
		for i = 1, #Nodes do
			local NodeHeadInfo = Nodes[i].Head
			
			if NodeHeadInfo.EmergencyShutDown == false then
				table.insert(NodeList, Nodes[i])
			end
		end

		local ActivityFinish = false
		if Cfg.ActivityType == ActivityType.ActivityTypePandora then
			--查询潘多拉活动是否完成
			ActivityFinish = _G.PandoraMgr:IsActivityNeedToSinkToBottom(Cfg.Title)
		else
			ActivityFinish = self:IsActivityFinish(NodeList)
		end
		self.ActivityNodeMap[ActivityID] = {NodeList = NodeList, ActivityFinish = ActivityFinish, Effected = ActivityHead.Effected} 
		_G.QuestMgr.QuestRegister:RegisterActivity(ActivityID, true)
	else
		self.ActivityNodeMap[ActivityID] = nil
		_G.QuestMgr.QuestRegister:RegisterActivity(ActivityID, false)
	end

	if (Cfg.ActivityType == ActivityType.ActivityTypeNormal or Cfg.ActivityType == ActivityType.ActivityTypePandora) and not ActivityHead.Hiden then
		self:UpdateActivityRedDot(Cfg.ClassifyID, Cfg)
	end

	-- add by sammr
	self:LoadLayerMapEditCfg(ActivityID, Cfg.LayerIDs)
end

-------------常规活动数据
function OpsActivityMgr:AddActivityToCommonActivitysMap(ClassifyID, ActivityDate)
	if self.CommonActivitysMap == nil then
		self.CommonActivitysMap = {}
	end
	local ClassifyActivityTab =  self.CommonActivitysMap[ClassifyID] or {}

	table.insert(ClassifyActivityTab, ActivityDate) 
	self.CommonActivitysMap[ClassifyID] = ClassifyActivityTab
end

function OpsActivityMgr:RemoveActivityFromCommonActivitysMap(ClassifyID, ActivityID)
	if self.CommonActivitysMap == nil then
		return
	end

	if ClassifyID == nil then
		return
	end

	local ClassifyActivityTab =  self.CommonActivitysMap[ClassifyID] or {}
	for i = 1, #ClassifyActivityTab do
		local Activity = ClassifyActivityTab[i].Activity
		if Activity.ActivityID == ActivityID then
			table.remove(ClassifyActivityTab, i)
			break
		end
	end

	if #ClassifyActivityTab > 0 then
		self.CommonActivitysMap[ClassifyID] = ClassifyActivityTab
	else
		self.CommonActivitysMap[ClassifyID] = nil
	end
end

-----------------季节活动
function OpsActivityMgr:AddActivityToSeasonActivitys(ActivityDate)
	if self.SeasonActivitys == nil then
		self.SeasonActivitys = {}
	end

	table.insert(self.SeasonActivitys, ActivityDate)
end

function OpsActivityMgr:RemoveActivityFromSeasonActivitys(ActivityID)
	if self.SeasonActivitys == nil then
		return
	end

	local SeasonActivityTab =  self.SeasonActivitys or {}
	for i = 1, #SeasonActivityTab do
		local Activity = SeasonActivityTab[i].Activity
		if Activity.ActivityID == ActivityID then
			table.remove(SeasonActivityTab, i)
			break
		end
	end
	self.SeasonActivitys = SeasonActivityTab
end


-----------------------------------------------------------------------

function OpsActivityMgr:IsActivityOpenByType(ActivityType)
	if self.ActivityNodeMap == nil then
		return nil
	end
	local ActivityNodeMap = self.ActivityNodeMap
	for ActivityID, _ in pairs(ActivityNodeMap) do
		local Cfg = ActivityCfg:FindCfgByKey(ActivityID)
		if Cfg then
			return Cfg.ActivityType == ActivityType
		end
	end

	return nil
end

function OpsActivityMgr:GetActivtyNodeInfo(ActivityID)
	if self.ActivityNodeMap == nil then
		return nil
	end

	return self.ActivityNodeMap[ActivityID]
end

function OpsActivityMgr:UpdateActivityNode(Node)
	if Node == nil or Node.Head == nil then
		return
	end
	local NodeID = Node.Head.NodeID
	local CfgData = ActivityNodeCfg:FindCfgByKey(NodeID)
	if CfgData and self.ActivityNodeMap and self.ActivityNodeMap[CfgData.ActivityID] then
		local NodeList = self.ActivityNodeMap[CfgData.ActivityID].NodeList
		if NodeList then
			for i = 1, #NodeList  do
				if NodeList[i].Head and NodeList[i].Head.NodeID == NodeID then
					NodeList[i] = Node
				end
			end
			self.ActivityNodeMap[CfgData.ActivityID].NodeList = NodeList
			self.ActivityNodeMap[CfgData.ActivityID].ActivityFinish = self:IsActivityFinish(NodeList)
		end

		local Cfg = ActivityCfg:FindCfgByKey(CfgData.ActivityID)
		if Cfg then
			if Cfg.ActivityType == ActivityType.ActivityTypeNormal then
				self:UpdateActivityRedDot(Cfg.ClassifyID, Cfg)
			end
		end
	end
end

function OpsActivityMgr:IsActivityFinishByID(ActivityID)
	if self.ActivityNodeMap[ActivityID] == nil then
		return false
	end
	return self.ActivityNodeMap[ActivityID].ActivityFinish
end

function OpsActivityMgr:IsActivityFinish(NodeList)
	if NodeList == nil or #NodeList == 0 then
		return false
	end

	--沙漠炎火使用了优惠码购买则直接完成
	for i = 1, #NodeList do
		local NodeHeadInfo = NodeList[i].Head
		local Extra = NodeList[i].Extra
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeHeadInfo.NodeID)
		if NodeCfg then
			if NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeShareBuy then
				local ShareBuyData = Extra.ShareBuy or {}
            	if ShareBuyData.Status == ProtoCS.Game.Activity.enStatus.DiscountPayed then
					return true
				end
			end
		end
	end


	for i = 1, #NodeList do
		local NodeHeadInfo = NodeList[i].Head
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeHeadInfo.NodeID)
		if NodeCfg then
			if NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeLotteryDrawNoLayBack then
				if NodeHeadInfo.Finished == false then
					return false
				end
			end
		end
	end

	local HasAccumulativeFinishNode = false
	for i = 1, #NodeList do
		local NodeHeadInfo = NodeList[i].Head
		local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeHeadInfo.NodeID)
		if NodeCfg then
			if NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeAccumulativeFinishNode then
				HasAccumulativeFinishNode = true
				if NodeHeadInfo.Finished == false or NodeHeadInfo.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
					return false
				end
			end
		end
	end

	if HasAccumulativeFinishNode == false then
		for i = 1, #NodeList do
			local NodeHeadInfo = NodeList[i].Head
			local NodeCfg = ActivityNodeCfg:FindCfgByKey(NodeHeadInfo.NodeID)
			if NodeCfg and NodeCfg.NodeType ~= ActivityNodeType.ActivityNodeTypePictureShare then
				if NodeCfg and NodeCfg.Target > 0 and (NodeHeadInfo.Finished == false or NodeHeadInfo.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet)then
					return false
				end
			end
		end
	end

	return true
end


---获取活动节点奖励
function OpsActivityMgr:SendActivityNodeGetReward(ActivityNodeID)
	local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
	local SubMsgID = SUB_MSG_ID.Reward

	local MsgBody = {
        Cmd = SubMsgID,
		Reward = { NodeID = ActivityNodeID },
    }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


function OpsActivityMgr:OnNetMsgNodeGetReward(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.Reward then
		return
	end
	local Reward = MsgBody.Reward
	self:SetActivityInfo(Reward.Detail)

	EventMgr:SendEvent(EventID.OpsActivityNodeGetReward, MsgBody)
end

function OpsActivityMgr:SendActivityNodeOperate(ActivityNodeID, NodeOpType, Data)
	local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
	local SubMsgID = SUB_MSG_ID.NodeOperate

	local MsgBody = {
        Cmd = SubMsgID,
		NodeOperate = { NodeID = ActivityNodeID, OpType = NodeOpType},
    }

	if next(Data) then
		local k, v = next(Data)
		MsgBody.NodeOperate[k] = v
	end

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function OpsActivityMgr:ParsePlatformConfig(ConfigStr, PlatFormStr)
    local ParamsConfig = {}
    local CurSection = nil
    for line in ConfigStr:gmatch("[^\r\n]+") do
        line = line:gsub("%s*%-%-.*$", ""):match("^%s*(.-)%s*$") 
        if line == "" then goto continue end

        local Section = line:match("%[(%w+)%]") 
        if Section then
            CurSection = Section
        elseif CurSection == PlatFormStr then
            local key, value = line:match("^%s*([%w_]+)%s*=%s*(.-)%s*$")
            if key then
                ParamsConfig[key] = (value == "" or value == " ") and nil or value
            end
        end

        ::continue::
    end

    return ParamsConfig
end

---@param JumpType   活动跳转类型
---@param JumpParam  跳转参数
---@param ReplaceParamData 小程序跳转传入约定参数  {QQ = {ReplaceParamName = {ParamValue1, ParamValue2}}, WeChat = {ReplaceParamName = {ParamValue1, ParamValue2}}}
function OpsActivityMgr:Jump(JumpType, JumpParam, ReplaceParamData)
	if JumpType == OPS_JUMP_TYPE.TABLE_JUMP then
		JumpUtil.JumpTo(tonumber(JumpParam), true)
	elseif JumpType == OPS_JUMP_TYPE.PANDORA_JUMP then
		_G.PandoraMgr:OpenApp(JumpParam)
	elseif JumpType == OPS_JUMP_TYPE.WEB_JUMP then
		AccountUtil.OpenUrlWithParam(JumpParam)
	elseif JumpType == OPS_JUMP_TYPE.MINPROGRAM_JUMP then
		local PlatFormStr
		if _G.LoginMgr:IsQQLogin() then
			PlatFormStr = "QQ"
		elseif _G.LoginMgr:IsWeChatLogin() then
			PlatFormStr = "WeChat"
		else
			FLOG_INFO("OpsActivityMgr:JumpToMiniApp UnSupport Platform Type")
			return
		end

		local ParamsData = self:ParsePlatformConfig(JumpParam, PlatFormStr)
		if not next(ParamsData) then return end
		if ReplaceParamData and ReplaceParamData[PlatFormStr] then
			local ReplaceData = ReplaceParamData[PlatFormStr]
			for name, values in pairs(ReplaceData) do
				ParamsData[name] = string.sformat(ParamsData[name], table.unpack(values))
			end
		end

		JumpUtil.JumpMiniAppByParamsData(ParamsData)
	else
		FLOG_INFO("OpsActivityMgr:Jump UnDefine Type")
	end
end

function OpsActivityMgr:OnNetMsgNodeOperate(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.NodeOperate then
		return
	end
	local NodeOperate = MsgBody.NodeOperate 
	self:SetActivityInfo(NodeOperate.ActivityDetail)
	EventMgr:SendEvent(EventID.OpsActivityUpdateInfo, MsgBody)
end


function OpsActivityMgr:SendActivityEventReport(NodeType, Args)
	local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
	local SubMsgID = SUB_MSG_ID.EventReport

	local MsgBody = {
        Cmd = SubMsgID,
		EventReport = { NodeType = NodeType, Args = Args},
    }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end


function OpsActivityMgr:OnNetMsgActivityEventReport(MsgBody)
	EventMgr:SendEvent(EventID.OpsActivityReportSuccess)
end

--领取指定活动所有节点奖励
function OpsActivityMgr:SendActivityGetReward(ActivityID)
	local MsgID = CS_CMD.CS_CMD_ACTIVITY_SYSTEM
	local SubMsgID = SUB_MSG_ID.ActReward

	local MsgBody = {
        Cmd = SubMsgID,
		ActReward = { ActID = ActivityID },
    }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function OpsActivityMgr:OnNetMsgActivityGetReward(MsgBody)
	if nil == MsgBody or nil ==  MsgBody.ActReward then
		return
	end
	local ActReward = MsgBody.ActReward

	self:SetActivityInfo(ActReward.Detail)
	EventMgr:SendEvent(EventID.ShowLoginDayReward)

	EventMgr:SendEvent(EventID.OpsActivityNodeGetReward, MsgBody)
end
-----------------------直购相关
function OpsActivityMgr:Recharge(Order, ActivityID, View)
	FLOG_INFO("OpsActivityMgr Recharge ActivityID: "..tostring(ActivityID))
	self.RechargeActivityID = ActivityID

	PayUtil.BuyCoins(Order,
	function(_, BillData) self:OnBillReceived(BillData) end,
	function(_) self:OnLoginExpired() end,
	nil, -- 切后台可能导致米大师回调丢失，不再使用
	function(_, GoodsData) self:OnGoodsReceived(GoodsData) end,
	View)
end


function OpsActivityMgr:OnBillReceived(BillData)
	if BillData == nil then
		FLOG_ERROR("Cannot get pay bill data")
		return
	end

	if BillData.URL == "" then
		FLOG_ERROR("Pay bill is empty")
	end
end

function OpsActivityMgr:OnLoginExpired()
	FLOG_ERROR("Login expired!")
end


function OpsActivityMgr:OnGoodsReceived(GoodsData)
	self:OnRechargeSucceed()
end

function OpsActivityMgr:OnRechargeSucceed()
    FLOG_INFO("OnRechargeSucceed...ActivityID: "..tostring(self.RechargeActivityID))
	if self.RechargeActivityID then
		EventMgr:SendEvent(EventID.RechargeActivitySuccess, self.RechargeActivityID)
		self.RechargeActivityID = nil
	end
end

-----------------------关卡数据相关
---加载季节layer数据
function OpsActivityMgr:LoadLayerMapEditCfg(ActivityID, LayerIDs)
	if not LayerIDs then
		return
	end
	local LoadLayerMapEditCfgMap = self.LoadLayerMapEditCfgMap
	if not LoadLayerMapEditCfgMap then
		return
	end
	if LoadLayerMapEditCfgMap[ActivityID] then
		return
	end

	local IsLoad = false
	for _, LayerID in ipairs(LayerIDs) do
		local FestivalLayersetCfgItem = FestivalLayersetCfg:FindCfgByKey(LayerID)
		if FestivalLayersetCfgItem then
			local PWorldMgrInstance = _G.UE.UPWorldMgr:Get()
			PWorldMgrInstance:LoadFestivalMapEditCfg(FestivalLayersetCfgItem.HolidayEditFile)
			IsLoad = true
		end
	end

	if (#LayerIDs > 0) then
		self.CacheLayerIDs = LayerIDs
	end
	
	if IsLoad then
		LoadLayerMapEditCfgMap[ActivityID] = true
	end
end

-----------------------红点相关
-----活动中心的红点
function OpsActivityMgr:UpdateActivityRedDot(ClassifyID, Activity)
	if Activity == nil then
		return
	end

	local RedPoints = Activity.RedPointList
	if string.isnilorempty(RedPoints) then
		return
	end

	local RedPointList = string.split(RedPoints, "|")
	for _, RedPoint in ipairs(RedPointList) do
		local  Value  = tonumber(RedPoint) or 0
		if self.OpsActivityRedDotFun[Value] ~= nil then
			local ActivityRedDotName = self:GetRedDotName(ClassifyID, Activity.ActivityID, self.OpsActivityRedDotFun[Value].Name)
			if self.OpsActivityRedDotFun[Value].Fun(self, Activity) == true then
				RedDotMgr:AddRedDotByName(ActivityRedDotName)
				---特殊逻辑，季节活动的胖胖企鹅和该处红点同步
				if Activity.ActivityID == OpsCeremonyDefine.FatPenguinBlessActivityID then
					EventMgr:SendEvent(EventID.FatPenguinBlessUpdatRedDot, true)
				end
			else
				RedDotMgr:DelRedDotByName(ActivityRedDotName)
				---特殊逻辑，季节活动的胖胖企鹅和该处红点同步
				if Activity.ActivityID == OpsCeremonyDefine.FatPenguinBlessActivityID then
					EventMgr:SendEvent(EventID.FatPenguinBlessUpdatRedDot, false)
				end
			end
		end
	end
end

function OpsActivityMgr:GetRedDotName(ClassifyID, ActivityID, Name)
	if ActivityID ~= nil and  ActivityID > 0 then
		if string.isnilorempty(Name) then
			return OpsActivityDefine.RedDotName .. '/' .. tostring(ClassifyID) .. '/' .. tostring(ActivityID)
		else
			return OpsActivityDefine.RedDotName .. '/' .. tostring(ClassifyID) .. '/' .. tostring(ActivityID)..'/' .. Name
		end
	end
	return OpsActivityDefine.RedDotName .. '/' .. tostring(ClassifyID)
end


function OpsActivityMgr:FirstRedDot(Activity)
	if Activity == nil then
		return false
	end
	local ActivityClickedTime = self:GetLastClickedTime(Activity.ActivityID)
	return ActivityClickedTime == nil
end

function OpsActivityMgr:DailyRedDot(Activity)
	if Activity == nil then
		return false
	end
	local ActivityClickedTime = self:GetLastClickedTime(Activity.ActivityID)
	return ActivityClickedTime == nil or not TimeUtil.GetIsCurDailyCycleTime(ActivityClickedTime) 
end

function OpsActivityMgr:WeekRedDot(Activity)
	if Activity == nil then
		return false
	end
	local ActivityClickedTime = self:GetLastClickedTime(Activity.ActivityID)
	return ActivityClickedTime == nil or not TimeUtil.GetIsCurWeekCycleTime(ActivityClickedTime)
end

function OpsActivityMgr:MonthRedDot(Activity)
	if Activity == nil then
		return
	end

	local ActivityClickedTime = self:GetLastClickedTime(Activity.ActivityID)
	return ActivityClickedTime == nil or not TimeUtil.GetIsCurMonthCycleTime(ActivityClickedTime)
end

function OpsActivityMgr:RewardRedDot(Activity)
	if not Activity then return end
	local NodeData = self.ActivityNodeMap[Activity.ActivityID]
	if NodeData == nil then
		return false
	end
	local NodeList = NodeData.NodeList
	if NodeList then
		for i, v in ipairs(NodeList) do
			local Head = v.Head or {}
			if not Head.EmergencyShutDown then
				if Head.RewardStatus and Head.RewardStatus == ProtoCS.Game.Activity.RewardStatus.RewardStatusWaitGet then
					return true
				end
			end
		end
	end

	return false
end

function OpsActivityMgr:LotteryRedDot(Activity)
	if not Activity then return end
	local NodeData = self.ActivityNodeMap[Activity.ActivityID]
	if NodeData == nil then
		return false
	end
	local NodeList = NodeData.NodeList
	if NodeList then
		for _, v in ipairs(NodeList) do
			if v.Head and not v.Head.EmergencyShutDown then
				--- 通过Extra节点中Lottery是否为空判断改节点是否为抽奖节点
				if v.Extra and v.Extra.Lottery then
					return self:CheckIsEnoughForLottery(v)
				end
			end
		end
	end

	return false
end

function OpsActivityMgr:PandoraRedDot(Activity)
	if not Activity then return end
	return _G.PandoraMgr:GetActivityRedDotStatus(Activity.Title)
end

function OpsActivityMgr:CheckIsEnoughForLottery(ActivityNode)
	local DrawNum = ActivityNode.Extra.Lottery.DrawNum
	local LotteryNode = ActivityNodeCfg:FindCfgByKey(ActivityNode.Head.NodeID)
	if DrawNum == nil or LotteryNode == nil then
		return false
	end
	local LotteryCousumeNode = CommercializationRandConsumeCfg:FindCfg("PoolID = "..LotteryNode.Params[1])
	if LotteryCousumeNode then
		local LotteryPropNum =  _G.BagMgr:GetItemNum(LotteryCousumeNode.ConsumeResID)
		-- 当前拥有抽奖币大于下抽所需抽奖币有红点
		if DrawNum < #LotteryCousumeNode.ConsumeResNum and LotteryPropNum >= LotteryCousumeNode.ConsumeResNum[DrawNum + 1] then
			return true
		else
			return false
		end
	end
end
---- 活动购买商城物品后再次刷红点
function OpsActivityMgr:StoreBuyRemindRedDot(Activity)
	if not Activity then return end
	local GoodsID
	local NodeData = self.ActivityNodeMap[Activity.ActivityID]
	if not NodeData then return end
	local NodeList = NodeData.NodeList
	for i, v in ipairs(NodeList) do
		if not v.Head.EmergencyShutDown then
			local ActivityNodeCfg = require("TableCfg/ActivityNodeCfg")
			local NodeCfg = ActivityNodeCfg:FindCfgByKey(v.Head.NodeID) or {}
			if NodeCfg.NodeType and NodeCfg.NodeType == ActivityNodeType.ActivityNodeTypeMallPurchased then
				GoodsID = NodeCfg.Params and NodeCfg.Params[1] or 0
				break
			end
		end
	end

	_G.StoreMgr:SetOneActivityBuyRecord(GoodsID, Activity.ActivityID)
	local StoreBuyRecord = _G.StoreMgr:GetActivityStoreBuyRecord()
	if StoreBuyRecord[Activity.ActivityID] then
		return true
	end

	return false
end

-- 月卡红点
function OpsActivityMgr:MonthCardRedDot(Activity)
	if Activity == nil then
		return false
	end

	return _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDMonthCard)  and _G.MonthCardMgr:GetMonthCardStatus() and _G.MonthCardMgr:GetMonthCardReward()
end

function OpsActivityMgr:JumpToMonthCard()
	JumpUtil.JumpTo(18)
end

function OpsActivityMgr:InitOpsActivityRedDotFun()
	if self.OpsActivityRedDotFun == nil then
		self.OpsActivityRedDotFun = {}
	end

	self.OpsActivityRedDotFun[ProtoRes.RED_POINT_TYPE.FIRST_PROMPT] = {Name = "First", Fun = self.FirstRedDot}
	self.OpsActivityRedDotFun[ProtoRes.RED_POINT_TYPE.DAILY_PROMPT] = {Name = "Daily", Fun = self.DailyRedDot}
	self.OpsActivityRedDotFun[ProtoRes.RED_POINT_TYPE.WEEK_PROMPT] = {Name = "Week", Fun = self.WeekRedDot}
	self.OpsActivityRedDotFun[ProtoRes.RED_POINT_TYPE.MONTH_PROMPT] = {Name = "Month", Fun = self.MonthRedDot}
	self.OpsActivityRedDotFun[ProtoRes.RED_POINT_TYPE.REWARD_PROMPT] = {Name = "Reward", Fun = self.RewardRedDot}
	self.OpsActivityRedDotFun[ProtoRes.RED_POINT_TYPE.STORE_BUY_SUCCESS_PROMPT] = {Name = "BuySuccessRemind", Fun = self.StoreBuyRemindRedDot}
	self.OpsActivityRedDotFun[ProtoRes.RED_POINT_TYPE.MONTHCARD_PROMPT] = {Name = "MonthCard", Fun = self.MonthCardRedDot}
	self.OpsActivityRedDotFun[ProtoRes.RED_POINT_TYPE.LOTTERY_PROMPT] = {Name = "Lottery", Fun = self.LotteryRedDot}
	self.OpsActivityRedDotFun[ProtoRes.RED_POINT_TYPE.PANDORA_PROMPT] = {Name = "Pandora", Fun = self.PandoraRedDot}
end

function OpsActivityMgr:GetLastClickedTime(ActivityID)
	if self.CustomizeRedDotList == nil then
		return nil
	end
	return self.CustomizeRedDotList[ActivityID]
end


function OpsActivityMgr:ReadSaveKeyData()
	self.CustomizeRedDotList = {}
    local RedDotStr = USaveMgr.GetString(SaveKey.OpsActivityRecordRedDot, "", true)
    local SplitStr = string.split(RedDotStr,",")
	for i = 1, #SplitStr, 2 do
		self.CustomizeRedDotList[tonumber(SplitStr[i])] = tonumber(SplitStr[i + 1])
	end
end

function OpsActivityMgr:RecordRedDotClicked(ActiviyID, TimeStamp)
	if self.CustomizeRedDotList == nil then
		self.CustomizeRedDotList = {}
	end

	self.CustomizeRedDotList[ActiviyID] = TimeStamp

	_G.StoreMgr:DelOneActivityStoreBuyRecord(ActiviyID)
	local Cfg = ActivityCfg:FindCfgByKey(ActiviyID)
	if Cfg ~= nil then
		self:UpdateActivityRedDot(Cfg.ClassifyID, Cfg)
	end

	self:WriteSaveKeyData()
end

function OpsActivityMgr:WriteSaveKeyData()
    local RedDotStr
    for Key, Value in pairs(self.CustomizeRedDotList) do
		if string.isnilorempty(RedDotStr) then
			RedDotStr = string.format("%d,%d", Key, Value)
		else
			RedDotStr = string.format("%s,%d,%d", RedDotStr, Key, Value)
		end
    end
    USaveMgr.SetString(SaveKey.OpsActivityRecordRedDot, RedDotStr, true)
end


function OpsActivityMgr:GetActivityStartTime(Activity)
	local ActivityTime = self:GetActivityTime(Activity)
	if ActivityTime == nil then
		return 0
	end

	if ActivityTime.StartTime == nil then
		return 0
	end

	local StartTime = ActivityTime.StartTime
	local ZoneOffset = ActivityTime.TimeZoneOffset - TimeZoneOffset.TimeZoneOffset0

	local ServerZone = 8 --这里先认为服务器在东8区，后面要以实际布置的服务器时区为准
	local year, month, day, hour, min, sec = StartTime:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	
	local TimeTable = {year = year, month = month, day = day, hour = hour, min = min, sec = sec}
	return os.time(TimeTable) + (ZoneOffset - ServerZone) * 3600
end

function OpsActivityMgr:GetActivityEndTime(Activity)
	local ActivityTime = self:GetActivityTime(Activity)
	if ActivityTime == nil then
		return 0
	end
	
	if ActivityTime.EndTime == nil then
		return 0
	end
	local EndTime = ActivityTime.EndTime
	local ZoneOffset = ActivityTime.TimeZoneOffset - TimeZoneOffset.TimeZoneOffset0

	local ServerZone = 8 --这里先认为服务器在东8区，后面要以实际布置的服务器时区为准
	
	local year, month, day, hour, min, sec = EndTime:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
	
	local TimeTable = {year = year, month = month, day = day, hour = hour, min = min, sec = sec}
	return os.time(TimeTable) + (ZoneOffset - ServerZone) * 3600
	
end

function OpsActivityMgr:IsOpsActivityOnShelf(ActivityID)
	local Cfg = ActivityCfg:FindCfgByKey(ActivityID)
	if Cfg == nil then
		return false
	end

	if Cfg.ClassifyID ~= nil then
		local ClassifyActivityTab =  self.CommonActivitysMap[Cfg.ClassifyID] or {}
		for i = 1, #ClassifyActivityTab do
			local Activity = ClassifyActivityTab[i].Activity or {}
			if Activity.ActivityID == ActivityID then
				local StartTime = OpsActivityMgr:GetActivityStartTime(Activity)
				local EndTime = OpsActivityMgr:GetActivityEndTime(Activity)
				if StartTime <= TimeUtil.GetServerLogicTime() and EndTime > TimeUtil.GetServerLogicTime() then
					return true
				else
					return false
				end
			end
		end
	end

	local SeasonActivityTab =  self.SeasonActivitys
	for i = 1, #SeasonActivityTab do
		local Activity = SeasonActivityTab[i].Activity or {}
		if Activity.ActivityID == ActivityID then
			local StartTime = OpsActivityMgr:GetActivityStartTime(Activity)
			local EndTime = OpsActivityMgr:GetActivityEndTime(Activity)
			if StartTime <= TimeUtil.GetServerLogicTime() and EndTime > TimeUtil.GetServerLogicTime() then
				return true
			else
				return false
			end
		end
	end

	return false
end


function OpsActivityMgr:JumpToActivity(ActivityID)
	local View = UIViewMgr:FindVisibleView(UIViewID.OpsActivityMainPanel)
    if not View then
        UIViewMgr:ShowView(UIViewID.OpsActivityMainPanel, {JumpData = {ActivityID}})
    else
        local Params = View.Params or {}
        Params.JumpData = {ActivityID}
        View:UpdateView(Params)
    end
end

function OpsActivityMgr:GetActivityTime(Activity)
	if Activity  == nil then
		return
	end
	return Activity.ChinaActivityTime
end


function OpsActivityMgr:OnNetMsgQueryLastLoginRoles(MsgBody)
	local Msg = MsgBody.Roles
	if nil == Msg then
		return
	end
    local FriendMap = {}
    for _, Item in pairs(Msg) do
		if Item and Item.OpenID then
			FriendMap[Item.OpenID] = Item
		end
    end
	EventMgr:SendEvent(EventID.OpcConcertLastLoginRolesUpdate, FriendMap)
end
--要返回当前类
return OpsActivityMgr