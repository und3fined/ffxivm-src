
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local BagMgr = require("Game/Bag/BagMgr")
local TimeUtil = require("Utils/TimeUtil")
local EventMgr = require("Event/EventMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local ProtoCS = require("Protocol/ProtoCS")
local ChatMgr = require("Game/Chat/ChatMgr")
local MajorUtil = require("Utils/MajorUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local PworldCfg = require("TableCfg/PworldCfg")
local ActorMgr = require("Game/Actor/ActorMgr")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local RichTextUtil = require("Utils/RichTextUtil")
local RollTreasureboxCfg = require("TableCfg/RollTreasureboxCfg")
local AudioUtil = require("Utils/AudioUtil")
local TutorialDefine = require("Game/Tutorial/TutorialDefine")
local UILayer = require("UI/UILayer")
local UIViewStateMgr = require("UI/UIViewStateMgr")

local TeamRollItemVM
local ROLL_OPERATE = ProtoCS.ROLL_OPERATE
local ITEM_TYPE = ProtoCommon.ITEM_TYPE
local ITEM_TYPE_DETAIL = ProtoCommon.ITEM_TYPE_DETAIL
local FLOG_ERROR = _G.FLOG_ERROR
local CS_CMD = ProtoCS.CS_CMD
local CS_ROLL_CMD = ProtoCS.CS_ROLL_CMD
local LSTR = _G.LSTR
local UIViewMgr = _G.UIViewMgr
local UIViewID = _G.UIViewID
local GetAudioPath = "AkAudioEvent'/Game/WwiseAudio/Events/sound/zingle/Zingle_LvUP_Get/Play_Zingle_LvUP_Get.Play_Zingle_LvUP_Get'"
local GetAudioID

local DefaultResultList = {
	--- 选择放弃的奖励  点数为-1
	GiveUpResult = -1,
	--- 未操作的奖励
	NotOperatedResult = 0,
	--- 已拥有且唯一的奖励（目前只有时装、坐骑解锁道具、宠物解锁道具），后台视为已放弃，客户端没有点时显示未操作，点需求显示已拥有，放弃后直接改点数为-1
	AlreadyOwnedResult = -2,
}

---@class RollMgr : MgrBase
local RollMgr = LuaClass(MgrBase)
-- enum CS_ROLL_CMD {
--     ROLL_CMD_INVALID = 0;        // 无效
--     OPERATE = 1;        // 玩家操作
--     AWARD_NOTIFY = 2;   // 通知队伍内成员增量奖励详情
--     ROLL_NOTIFY = 3;    // 通知队伍内成员ROLL点详情
--     BELONG_NOTIFY = 4;  // 通知队伍内奖励归属结算
--   }

local SortAwardList = function(a,b) 
	if a.ExpireTime ~= b.ExpireTime then
		return a.ExpireTime < b.ExpireTime
	else
		return a.ID < b.ID
	end
end

function RollMgr:OnInit()
	self.AwardMap = {}
	self.TeamRollTimerID = {}
	self.CurrentAwardKey = 0 --最新奖励物的Key,代表当前掉落的奖励物TeamID
	self.IsPopWindow = true
	self.TeamPanelVisible = false
	self.IsAllDemand = false
	self.BoxRollAnimationTimerID = nil
	self.IsTreasureHuntRoll = false

end

function RollMgr:OnBegin()
	TeamRollItemVM = require("Game/Team/VM/TeamRollItemVM")
end

function RollMgr:OnEnd()
end

function RollMgr:OnShutdown()
end

function RollMgr:OnRegisterNetMsg()
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ROLL, CS_ROLL_CMD.AWARD_NOTIFY, self.OnNetMsgAwardNotify) -- 通知队伍内成员增量奖励详情
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ROLL, CS_ROLL_CMD.ROLL_NOTIFY, self.OnNetMsgRollNotify) -- 通知队伍内成员ROLL点详情
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ROLL, CS_ROLL_CMD.BELONG_NOTIFY, self.OnNetMsgBelongNotify) -- 通知队伍内奖励归属结算
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_ROLL, CS_ROLL_CMD.RollQuery, self.OnNetMsgRollQuery) -- 断线重连
end

function RollMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
	self:RegisterGameEvent(EventID.TeamRollAllGiveUp, self.OnAllAwardGiveUp)
	self:RegisterGameEvent(EventID.TeamRollAllRandom, self.OnAllAwardDemand)
	self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnClearDataByEvent)				-- 退出副本通知隐藏Roll界面
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnClearDataByEvent)
	--- 寻宝用  退队请数据
	self:RegisterGameEvent(EventID.TeamInTeamChanged, self.OnGameEventTeamInTeamChanged)
	
end

function RollMgr:OnNetMsgRollQuery(MsgBody)
	local RollQuery = MsgBody.Query
	if RollQuery == nil then
		FLOG_WARNING("RollMgr:OnNetMsgRollQuery RollQuery is nil")
		return
	end
	local Treasures = RollQuery.Treasures
	if table.is_nil_empty(Treasures) then
		FLOG_WARNING("RollMgr:OnNetMsgRollQuery Treasures is nil")
		return
	end
	local TempAwardList = Treasures[1].AwardList
	if table.is_nil_empty(TempAwardList) then
		FLOG_WARNING("RollMgr:OnNetMsgRollQuery TempAwardList is nil")
		return
	end

	self.IsQuery = true
	self.IsTreasureHuntRoll = false
	for i = 1,#Treasures do
		local Value = Treasures[i]
		if Value ~= nil then 
			if  not string.isnilorempty(Value.Reason) and string.match(Value.Reason,"Treasurehunt.rollAward") then
				self.IsTreasureHuntRoll = true
				break
			end
		end
	end

	self:OnTreasureAssign(true)

	table.sort(Treasures, function(a,b) 
		local aIsEmpty = table.is_nil_empty(a.AwardList)
		local bIsEmpty = table.is_nil_empty(b.AwardList)
	
		if aIsEmpty then
			return false	-- 如果a是空的 永远排在后面
		elseif bIsEmpty then
			return true		-- 如果b是空的但a不是 a排前面
		else
			return a.AwardList[1].ExpireTime > b.AwardList[1].ExpireTime
		end
	end)
	for _, value in ipairs(Treasures) do
		-- local value = Treasures[i]
		local AwardList = value.AwardList
		table.sort(AwardList, SortAwardList)
		self:AddAwardList(value.TeamID, AwardList)
		self:AddAwardRoleList(value.TeamID, value.RoleList)
		self:AddRollList(value.TeamID, value.RollList)
		self:AddAwardBelong(value.TeamID, value.BelongList, true)
		self.CurrentAwardKey = tostring(value.TeamID)

		TeamRollItemVM:UpdateAwardList(AwardList, value.TeamID)
		TeamRollItemVM:UpdateRollItemInfo(value.TeamID, nil)
		local ServerTime = TimeUtil.GetServerTime()
		if AwardList ~= nil and AwardList[1] ~= nil then
			if AwardList[1].ExpireTime > ServerTime then
				self:StartTeamRollTimer(value.TeamID)
			end
		end
		local TempAwardList = AwardList
		if TempAwardList ~= nil then
			for i = 1, #TempAwardList do
				if TempAwardList[i].ExpireTime > ServerTime then
					-- 播放宝箱进场动效
					TeamRollItemVM.IsAllOperated = false
					--- 播放动效改至处理“重要奖励”相关逻辑之后
					-- if not UIViewMgr:IsViewVisible(UIViewID.TeamRollPanel) then
					-- 	EventMgr:SendEvent(EventID.TeamRollBoxEFFEvent, true)
					-- end
					-- 通知Roll点开始
					EventMgr:SendEvent(EventID.TeamRollStartEvent)
					break
				end
			end
		end
	end
	self.BoxRollAnimationTime = 0
	
	if self.BoxRollAnimationTimerID == nil then
		self.BoxRollAnimationTimerID = self:RegisterTimer(self.OnBoxTimer, 0, 0.05, 0)
	end
	if TeamRollItemVM.IsAllOperated then
		-- 区分寻宝的时间
		if self.IsTreasureHuntRoll then 
			TeamRollItemVM.CurrentCountDownNum = 30
		else
			TeamRollItemVM.CurrentCountDownNum = 60
		end
	end
end

function RollMgr:OnNetMsgAwardNotify(MsgBody)
	local Award = MsgBody.Award
	if Award == nil then
		return
	end

	if string.match(Award.Reason,"Treasurehunt.rollAward") then
		self.IsTreasureHuntRoll = true
	else 
		self.IsTreasureHuntRoll = false
	end

	self.IsAllDemand = false

	local TeamID = Award.TeamID
	table.sort(Award.AwardList, SortAwardList)
	-- 通知展示宝箱ICON
	self.CurrentAwardKey = tostring(TeamID)
	self:OnTreasureAssign(true)
	self:AddAwardList(TeamID, Award.AwardList)
	self:AddAwardRoleList(TeamID, Award.RoleList)

	TeamRollItemVM:UpdateAwardList(Award.AwardList, TeamID)
	TeamRollItemVM:UpdateRollItemInfo(TeamID, nil)

	RollMgr:StartTeamRollTimer(TeamID)
	if TeamRollItemVM.IsAllOperated then
		if self.IsTreasureHuntRoll then
			TeamRollItemVM.CurrentCountDownNum = 30
		else
			TeamRollItemVM.CurrentCountDownNum = 60
		end
	end
	TeamRollItemVM.IsAllOperated = false
	-- if not UIViewMgr:IsViewVisible(UIViewID.TeamRollPanel) then
	-- 	-- 播放宝箱进场动效 --- 播放动效改至处理“重要奖励”相关逻辑之后
	-- 	EventMgr:SendEvent(EventID.TeamRollBoxEFFEvent, true)
	-- end
	-- 通知Roll点开始
	EventMgr:SendEvent(EventID.TeamRollStartEvent)

	self.BoxRollAnimationTime = 0
	if self.BoxRollAnimationTimerID == nil then
		self.BoxRollAnimationTimerID = self:RegisterTimer(self.OnBoxTimer, 0, 0.05, 0)
	end

	local EventParams = _G.EventMgr:GetEventParams()
	EventParams.Type = TutorialDefine.TutorialConditionType.OpenDragonTreasurebox
	_G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
end

function RollMgr:OnNetMsgRollNotify(MsgBody)
	-- print("OnNetMsgRollNotifyOnNetMsgRollNotifyOnNetMsgRollNotify")
	local Roll = MsgBody.Roll
	if Roll == nil then
		return
	end
	self:AddRollList(Roll.TeamID, Roll.RollList)

	TeamRollItemVM:UpdateRollItemInfo(Roll.TeamID)

	-- 系统提示
	local RollNum = Roll.RollList
	-- 当前只提示当前玩家
	local RoleSimple = MajorUtil.GetMajorRoleSimple()
	if RollNum.RoleID == RoleSimple.RoleID then
		local AwardResult = RollMgr:GetAwardList(Roll.TeamID)
		if AwardResult == nil or AwardResult.AwardList == nil then
			FLOG_INFO("RollMgr:OnNetMsgRollNotify AwardResult is nil")
			return
		end
		table.sort(AwardResult.AwardList, function(a,b) return a.ID < b.ID end)
		local ResID = AwardResult.AwardList[Roll.RollList.ID].ResID
		local ItemName = ItemCfg:GetItemName(ResID)
		local RollResult = self:GetPlayerAwardRollResult(RollNum.RoleID, RollNum.ID, Roll.TeamID)
		if RollResult ~= nil then
			if ItemName ~= nil and RollResult.Result ~= nil and  RollResult.Result > 0 then
				if not self.IsAllDemand then
					MsgTipsUtil.ShowTipsByID(10029, nil, ItemName, RollResult.Result)
				end
			end
		end
	end
end

function RollMgr:OnNetMsgBelongNotify(MsgBody)
	-- print("OnNetMsgBelongNotifyOnNetMsgBelongNotifyOnNetMsgBelongNotify")
	local Belong = MsgBody.Belong
	if Belong == nil then
		return
	end
	self:AddAwardBelong(Belong.TeamID, Belong.BelongList)
	TeamRollItemVM:UpdateRollItemInfo(Belong.TeamID)
	TeamRollItemVM:OnCheckAwardsIsOperated()
	-- 通知Roll点结束
	if not self:HasAssignedReward() then
		EventMgr:SendEvent(EventID.TeamRollEndEvent)
	end
end

function RollMgr:SendMsgOperateReq(TeamID, ID, Operate)
	local MsgID = CS_CMD.CS_CMD_ROLL
	local SubMsgID = CS_ROLL_CMD.OPERATE

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.Operate = {TeamID = TeamID, ID = ID, Operate = Operate }

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

-- 查询Roll请求
function RollMgr:SendMsgQueryReq(TeamID)
	local MsgID = CS_CMD.CS_CMD_ROLL
	local SubMsgID = CS_ROLL_CMD.RollQuery

	local MsgBody = {}
	MsgBody.SubCmd = SubMsgID
	MsgBody.RollQuery = {TeamID = TeamID}

	GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function RollMgr:AddAwardList(TeamID, AwardList)
	if table.is_nil_empty(AwardList) then return end

	local IsShowTips = false
	local IsShowValuablesTips = true
	local IsHaveHighValue = false
	local TempPworldCfg = PworldCfg:FindCfgByKey(_G.PWorldMgr:GetCurrPWorldResID())
	local Mode = _G.PWorldMgr:GetMode()
	if TempPworldCfg ~= nil then
		if TempPworldCfg.SubType == ProtoRes.pworld_sub_type.PWORLD_SUB_TYPE_1R or Mode == ProtoCommon.SceneMode.SceneModeStory then
			IsShowTips = true
			IsShowValuablesTips = false
		end
	end
	local HighValueList = {}
	local Key = tostring(TeamID)
	if self.AwardMap[Key] == nil then
		self.AwardMap[Key] = {}
	end
	local Max = AwardList[1]
	
	for _, value in ipairs(AwardList) do
		local Cfg = ItemCfg:FindCfgByKey(value.ResID)
		if Cfg ~= nil then
			value.IsHighValue = Cfg.IsHighValue == 1
			if Cfg.IsHighValue == 1 then
				if UIViewMgr:IsViewVisible(UIViewID.TeamRollValuablesTips) then
					UIViewMgr:HideView(UIViewID.TeamRollValuablesTips)
				end
				IsHaveHighValue = true
				if IsShowTips then
					MsgTipsUtil.ShowTipsByID(10030)
				end
				table.insert(HighValueList, {ResID = value.ResID, IsBind = value.Bind})
			end
		end
		if Max ~= nil and Max.ExpireTime ~= nil then
			if value.ExpireTime > Max.ExpireTime then
				Max = value
			end
		end
	end
	if self.AwardMap[Key].AwardList == nil then
		self.AwardMap[Key].AwardList = AwardList
	else
		for i = 1, #AwardList do
			table.insert(self.AwardMap[Key].AwardList, AwardList[i])
		end
	end
	self.AwardMap[Key].TeamID = TeamID
	if Max == nil then --目前每个奖励品过期时间相同
		self.AwardMap[Key].ExpireTime = AwardList[1].ExpireTime
	else
		self.AwardMap[Key].ExpireTime = Max.ExpireTime
	end
	if not UIViewMgr:IsViewVisible(UIViewID.TeamRollPanel) then
		EventMgr:SendEvent(EventID.RollExpireNotify)
	end
	--- 贵重物品放前面
	table.sort(self.AwardMap[Key].AwardList, function(a,b) return a.IsHighValue ~= 1 and b.IsHighValue == 1 end)

	if Max == nil then
		Max = {ExpireTime = 0}
	end
	local ExpireTime = Max.ExpireTime or 0
	if ExpireTime > TimeUtil.GetServerTime() and self:HasAssignedReward() then
		--- 贵重物品界面- 有全屏界面时   显示层级 高于全屏界面
		if IsShowValuablesTips and IsHaveHighValue then
			TeamRollItemVM.ValuablesList:UpdateByValues(HighValueList)
			local TempLayer = UIViewStateMgr:CheckFullscreen() and UILayer.AboveNormal or UILayer.BelowNormal
			UIViewMgr:ShowView(UIViewID.TeamRollValuablesTips)
			UIViewMgr:ChangeLayer(UIViewID.TeamRollValuablesTips, TempLayer)
		end
		--- 是否存在重要奖励，播放的动效强弱不一样,这里加一个参数
		EventMgr:SendEvent(EventID.TeamRollBoxEFFEvent, {IsIn = true, IsHaveHighValue = IsHaveHighValue})
	end
end

function RollMgr:AddRollList(TeamID, RollList)
	local Key = tostring(TeamID)
	if self.AwardMap[Key] == nil then
		self.AwardMap[Key] = {}
	end
	if self.AwardMap[Key].RollList == nil then
		self.AwardMap[Key].RollList = {}
	end
	local TempRollList = self.AwardMap[Key].RollList
	if table.is_array(RollList) then
		for _, value in ipairs(RollList) do
			self:UpdateRollList(TempRollList, value, Key)
		end
	else
		self:UpdateRollList(TempRollList, RollList, Key)
	end
end

function RollMgr:UpdateRollList(TempRollList, RollList, Key)
	if RollList.Result ~= 0 then
		local ResultIsNew = true
		for _, value in ipairs(TempRollList) do
			if value.RoleID == RollList.RoleID and value.ID == RollList.ID then
				value.Result = RollList.Result
				ResultIsNew = false
				break
			end
		end
		if ResultIsNew then
			table.insert(TempRollList, RollList)
		end
	end
	self.AwardMap[Key].RollList = TempRollList
end

function RollMgr:AddAwardBelong(TeamID, AwardBelong, IsQuery)
	local Key = tostring(TeamID)
	if self.AwardMap[Key] == nil then
		self.AwardMap[Key] = {}
	end
	if self.AwardMap[Key].AwardBelong == nil then
		self.AwardMap[Key].AwardBelong = {}
	end
	if table.is_array(AwardBelong) then
		for _, value in ipairs(AwardBelong) do
			if (value.Result ~= DefaultResultList.NotOperatedResult and value.Result ~= DefaultResultList.AlreadyOwnedResult) or not IsQuery then
				-- value.Result = value.Result == DefaultResultList.GiveUpResult and DefaultResultList.NotOperatedResult or value.Result
				value.ExpireTime = self.AwardMap[Key].ExpireTime
				self:PlayGetAudio(value)
				table.insert(self.AwardMap[Key].AwardBelong, value)
			end
		end
	else
		if (AwardBelong.Result ~= DefaultResultList.NotOperatedResult and AwardBelong.Result ~= DefaultResultList.AlreadyOwnedResult) or not IsQuery then
			AwardBelong.ExpireTime = self.AwardMap[Key].ExpireTime
			-- AwardBelong.Result = AwardBelong.Result == DefaultResultList.GiveUpResult and DefaultResultList.NotOperatedResult or AwardBelong.Result
			self:PlayGetAudio(AwardBelong)
			table.insert(self.AwardMap[Key].AwardBelong, AwardBelong)
		end
	end
end

--- 播放获取音效
function RollMgr:PlayGetAudio(Value)
	local RoleID = MajorUtil.GetMajorRoleID()
	if nil == RoleID or nil == Value.RoleID then
		return
	end
	if Value.RoleID == RoleID then
		if nil ~= GetAudioID then
			AudioUtil.StopAsyncAudioHandle(GetAudioID)
		end
		GetAudioID = AudioUtil.LoadAndPlayUISound(GetAudioPath)
		FLOG_INFO("TeamRoll PlayUISound  RollMgr Path ==  " .. GetAudioPath)
	end
end

function RollMgr:AddAwardRoleList(TeamID, RoleList)
	local Key = tostring(TeamID)
	if self.AwardMap[Key] == nil then
		self.AwardMap[Key] = {}
	end
	self.AwardMap[Key].RoleList = RoleList
end

--- 查看是否有资格
function RollMgr:GetAwardEligibilityRoleID(RoleID, AwardID, TeamID)
	local RollResult = self:GetPlayerAwardRollResult(RoleID, AwardID, TeamID)

	if RollResult == -2 then
		return false
	else
		return true
	end
end

function RollMgr:GetAwardBelong(AwardID, TeamID)
	local AwardKey = tostring(TeamID)
	local AwardList = self.AwardMap[AwardKey]
	if AwardList == nil then
		return
	end
	local Results = self:GetRollResult(AwardID, TeamID)
	if table.is_nil_empty(Results) then
		return nil
	end
	for _, value in ipairs(Results) do
		if value == 0 then
			return nil
		end
	end

	local IsAllOperated = false
	local ItemResultList = {}
	local RollList = AwardList.RollList
	local RoleList = AwardList.RoleList
	for _, RollListItem in ipairs(RollList) do
 		if RollListItem.ID == AwardID then
			table.insert(ItemResultList, RollListItem)
		end
	end
	--- 判断是否所有人都操作过
	if RoleList ~= nil then
		for _, RoleListItem in ipairs(RoleList) do
			local CurRoleIsOperated = false
			for _, ItemResultListItem in ipairs(ItemResultList) do
				if ItemResultListItem.RoleID == RoleListItem and ItemResultListItem.Result ~= DefaultResultList.AlreadyOwnedResult and ItemResultListItem.Result ~= DefaultResultList.NotOperatedResult then
					CurRoleIsOperated = true
					IsAllOperated = true
					break
				end
			end
			if not CurRoleIsOperated then
				IsAllOperated = false
				break
			end
		end
	end
	-- 有点数和归属了  要多遍历一次RoleID数组，看是不是每个有归属的RoleID都有点数，是的话再继续
	if not IsAllOperated and AwardList.AwardList[1].ExpireTime ~= -1 then
		return nil
	end
	if AwardList.AwardBelong ~= nil then
		for _, AwardBelong in ipairs(AwardList.AwardBelong) do
			if AwardID == AwardBelong.ID then
				return AwardBelong
			end
		end
	end
	return nil
end

function RollMgr:GetRollResult(AwardID, TeamID, RoleID)
	local RoleResults = {}
	for _, value in pairs(self.AwardMap) do
		if not table.is_nil_empty(value.RollList) and value.TeamID == TeamID then
			for _, RollResult in ipairs(value.RollList) do
				if AwardID == RollResult.ID and (RoleID == nil or RoleID == RollResult.RoleID) then
					table.insert(RoleResults, RollResult)
				end
			end
		end
	end
	return RoleResults
end

function RollMgr:GetPlayerAwardRollResult(RoleID, AwardID, TeamID)
	local RollResult = RollMgr:GetRollResult(AwardID, TeamID, RoleID)
	if #RollResult == 0 then
		return nil
	end
	for _, value in ipairs(RollResult) do
		if value.RoleID == RoleID then
			return value
		end
	end
	return {Result = 0}
end

--- 拥有唯一的物品，后台在开宝箱的时候下发了点数为-2，客户端当作0处理，放弃时设置成-1
--- AwardID == 0  所有奖励都设置为-1
function RollMgr:CheckIsNeedChangeResult(RoleID, AwardID, TeamID)
	for _, value in pairs(self.AwardMap) do
		if not table.is_nil_empty(value.RollList) and value.TeamID == TeamID then
			for _, RollResult in ipairs(value.RollList) do
				if (AwardID == RollResult.ID or AwardID == 0) and RoleID == RollResult.RoleID and RollResult.Result == DefaultResultList.AlreadyOwnedResult then
					RollResult.Result = DefaultResultList.GiveUpResult
				end
			end
		end
	end
end

--- 物品过期时把所有-2的点数改成-1，因为已拥有的物品，下发奖励的时候下发了-2点数，而时间结束不会下发归属，所以这里单独设置一次
function RollMgr:ChangeResultByTeamID(TeamID)
	local RoleList = self.AwardMap[tostring(TeamID)].RoleList
	for _, value in ipairs(RoleList) do
		self:CheckIsNeedChangeResult(value, 0, TeamID)
	end
end


function RollMgr:GetAwardList(TeamID)
	local Key = tostring(TeamID)
	local AwardList = self.AwardMap[Key]
	if AwardList == nil then
		return nil
	else
		return AwardList
	end

end

function RollMgr:GetAwardTeamID(AwardID)
	for _, value in pairs(self.AwardMap) do
		if value.AwardList == nil then return end
		for _, RollResult in ipairs(value.AwardList) do
			if AwardID == RollResult.ID then
				return value.TeamID
			end
		end
	end
end

function RollMgr:GetAwardResult(AwardID, TeamID)
	local AwardKey = tostring(TeamID)
	local AwardList = self.AwardMap[AwardKey]
	if AwardList ~= nil then
		if nil ~= AwardList.RollList then
			for _, AwardResult in ipairs(AwardList.RollList) do
				if AwardID == AwardResult.ID then
					return AwardResult
				end
			end
		end
	end
	return nil
end

function RollMgr:IsAwardListExpire(TeamID)
	local Key = tostring(TeamID)
	if self.AwardMap[Key] == nil then
		return false
	end
	local ExpireTime = self.AwardMap[Key].ExpireTime
	if ExpireTime ~= nil and ExpireTime < TimeUtil.GetServerTime() then
		return true
	end
	return false
end

function RollMgr:StartTeamRollTimer(TeamID)
	local Key = tostring(TeamID)
	self.TeamRollTimerID[Key] = self:RegisterTimer(self.OnTimerTeamRollResult, 0, 0.3, 0, {TeamID = TeamID})
	TeamRollItemVM.AwardExpireTime = 0
	-- TeamRollItemVM.IsStartRollTimer = true
	for i = 1,  TeamRollItemVM.AwardList:Length() do
		TeamRollItemVM.AwardList:Get(i).IsStartRollTimer = true
	end
end

-- 掉落物过期通知
function RollMgr:OnTimerTeamRollResult(Params)
	local TeamID = Params.TeamID
	local Key = tostring(TeamID)
	if TeamRollItemVM.AwardExpireTime == 0 then
		TeamRollItemVM.AwardExpireTime = self.AwardMap[self.CurrentAwardKey].ExpireTime
	end
	EventMgr:SendEvent(EventID.TeamRollItemUpdateTick)
	-- print("掉落物过期通知" .. tostring(ExpireTime))
	TeamRollItemVM:SetCurrentCountDownNum(TeamID)
	if RollMgr:IsAwardListExpire(TeamID) then
		self:ChangeResultByTeamID(TeamID)
		TeamRollItemVM:UpdateRollItemInfo(TeamID)
		self:UnRegisterTimer(self.TeamRollTimerID[Key])
		self.TeamRollTimerID[Key] = nil
		if not self:HasAssignedReward() then
			TeamRollItemVM.IsAllOperated = true
			EventMgr:SendEvent(EventID.TeamRollBoxEFFEvent, {IsIn = false})
		end
		if self.BoxRollAnimationTimerID ~= nil then
			self:UnRegisterTimer(self.BoxRollAnimationTimerID)
			self.BoxRollAnimationTimerID = nil
		end
	end
end

--- 是否还有待分配的奖励未进行操作
function RollMgr:HasAssignedReward()
	local Key = self.CurrentAwardKey
	if self.AwardMap[Key] == nil then
		self.AwardMap[Key] = {}
	end
	local AwardList = self.AwardMap[Key].AwardList
	if AwardList == nil then
		return false
	end
	for _, value in ipairs(AwardList) do
		if self:GetAwardBelong(value.ID, self.AwardMap[Key].TeamID) == nil then
			return true
		end
	end
	return false
end

function RollMgr:GetIsHavePermissions(RoleID, AwardID, TeamID)
	local Key = tostring(TeamID)
	if self.AwardMap[Key] == nil then
		return false
	end
	local RoleList = self.AwardMap[Key].RoleList
	if RoleList == nil then
		return false
	end
	for i = 1, #RoleList do
		if RoleList[i] == RoleID then
			return true
		end
	end
	return false
end

--- 全部需求按钮
function RollMgr:OnAllAwardDemand()
	if TeamRollItemVM.IsAllOperated then    -- 全部操作后阻止意外操作
		return
	end
	local AwardListVM = TeamRollItemVM.AwardList:GetItems()
	if AwardListVM == nil then
		return
	end
	local RoleID = MajorUtil.GetMajorRoleID()
	self.IsAllDemand = true
	local ShowCannotHoldMoreTip = false  -- 是否需要显示“无法持有更多”的提示
	local ShowIneligibleTip = false      -- 是否需要显示“存在无资格”的提示
	for _, VM in ipairs(AwardListVM) do
		if VM ~= nil then
			local TeamID = VM.TeamID
			if not VM.IsOperated then
				VM.IsGiveUp = false
				local bIsPossesses = self:CheckIsPossesses(VM)
				--- 是否无资格
				local bIsUnqualified = not VM.IsHaveEligibility
				if bIsPossesses or bIsUnqualified then
					-- 已拥有不需求   无资格不需求
					if VM.IsUnique or bIsUnqualified then --是否是唯一拥有 or 无资格
						-- 隐藏按钮并发协议放弃
						VM.IsBtnGiveUpEnable = false
						VM.IsGiveUp = true
						VM.TextDes = LSTR(480005)				--- 放弃
						VM.IsOperated = true
						self:SendMsgOperateReq(TeamID, VM.AwardID, ROLL_OPERATE.GIVE_UP)
						self:CheckIsNeedChangeResult(RoleID, VM.AwardID, VM.TeamID)
					else
						-- 发协议需求
						VM.IsWait = true
						VM.IsBtnGiveUpEnable = false
						VM.IsOperated = true
						self:SendMsgOperateReq(TeamID, VM.AwardID, ROLL_OPERATE.DEMAND)
					end
				elseif not VM.Obtained then
					-- 发协议需求
					VM.IsWait = true
					VM.IsBtnGiveUpEnable = false
					VM.IsOperated = true
					self:SendMsgOperateReq(TeamID, VM.AwardID, ROLL_OPERATE.DEMAND)
				end
				VM.IsBtnRondomEnable = false
				VM.IsQualify = false
				if not ShowCannotHoldMoreTip then
					ShowCannotHoldMoreTip = bIsPossesses and VM.IsUnique
				end
				if not ShowIneligibleTip then
					ShowIneligibleTip = bIsUnqualified
				end
			end
			VM.IsMask = true
		end
	end
	MsgTipsUtil.ShowTipsByID(10023)				--- "已需求所有战利品"
	if ShowCannotHoldMoreTip then
		MsgTipsUtil.ShowTipsByID(10025)			--- "已自动放弃无法持有更多的战利品"
	end
	if ShowIneligibleTip then
		MsgTipsUtil.ShowTipsByID(10026)			--- "已自动放弃没有资格获得的战利品"
	end
	TeamRollItemVM.IsAllOperated = true
end

function RollMgr:OnAllAwardGiveUp()

	local AwardListVM = TeamRollItemVM.AwardList:GetItems()
	if AwardListVM ~= nil then
		local IsShowTips = true
		for _, VM in ipairs(AwardListVM) do
			if VM ~= nil then
				if not VM.IsOperated then
					VM.IsGiveUp = true
					VM.TextDes = LSTR(480005)	--- 放弃
					VM.IsOperated = true
					VM.IsMask = true
					if IsShowTips then
						MsgTipsUtil.ShowTipsByID(10024)
						IsShowTips = false
					end
					-- 发协议放弃
					local TeamID = VM.TeamID
					self:SendMsgOperateReq(TeamID, VM.AwardID, ROLL_OPERATE.GIVE_UP)
					local RoleID = MajorUtil.GetMajorRoleID()
					self:CheckIsNeedChangeResult(RoleID, VM.AwardID, VM.TeamID)
					VM.IsBtnRondomEnable = false
					VM.IsBtnGiveUpEnable = false
					VM.IsQualify = false
				end
			end
		end
		TeamRollItemVM.IsAllOperated = true
	end
end

--- 检查是否已拥有
function RollMgr:CheckIsPossesses(ViewModel)
	local ResID = ViewModel.ResID
	local TempItemCfg = ItemCfg:FindCfgByKey(ResID)
	if TempItemCfg == nil then
		return false
	end
	local ItemType = TempItemCfg.ItemType
	--- 是否已拥有
	local bIsPossesses = false
	--- 类型为时装坐骑宠物 收集品时 需要判断是否使用过
	if ItemType == ITEM_TYPE_DETAIL.COLLAGE_FASHION or ItemType == ITEM_TYPE_DETAIL.COLLAGE_MOUNT or ItemType == ITEM_TYPE_DETAIL.COLLAGE_MINION then
		bIsPossesses = BagMgr:IsItemUsed(TempItemCfg)
	end
	return (bIsPossesses or self:CheckEquipList(ResID) or _G.DepotVM:GetDepotItemNum(ResID) > 0 or BagMgr:GetItemNum(ViewModel.ResID) > 0) and TempItemCfg.IsUnique == 1
end

-- 断线重连请求Roll数据
function RollMgr:OnGameEventPWorldMapEnter(Params)
	if Params.bReconnect then
		self.AwardMap = {}
		for _, value in pairs(self.TeamRollTimerID) do
			self:UnRegisterTimer(value)
		end
		local Mode = _G.PWorldMgr:GetMode()
		local TempPworldCfg = PworldCfg:FindCfgByKey(Params.CurrPWorldResID)
		if TempPworldCfg == nil then
			FLOG_ERROR("RollMgr:OnGameEventPWorldMapEnter  TempPworldCfg is nil")
			return
		end
		--- 非副本
		if TempPworldCfg.Type ~= ProtoRes.pworld_type.PWORLD_CATEGORY_DUNGEON then
			FLOG_INFO("RollMgr:OnGameEventPWorldMapEnter  TempPworldCfg.Type is not PWORLD_CATEGORY_DUNGEON")
			return
		end
		--- 剧情辅助器
		if Mode == ProtoCommon.SceneMode.SceneModeStory then
			FLOG_INFO("RollMgr:OnGameEventPWorldMapEnter  Pworld Mode is SceneModeStory")
			return
		end
		TeamRollItemVM.AwardList:Clear()
		TeamRollItemVM.HighValueAwardNum = 0
		self:SendMsgQueryReq(0)
	end
end

--- 切图清数据
function RollMgr:OnClearDataByEvent()
	FLOG_INFO("TeamRoll  OnClearDataByEvent")
	local TempPworldCfg = PworldCfg:FindCfgByKey(_G.PWorldMgr:GetCurrPWorldResID())
	if TempPworldCfg == nil then
		return
	end
	--- 收到退出副本事件时判断下是否还在副本内，特殊情况(队长退队再解散)会触发退本事件
	if TempPworldCfg.Type == ProtoRes.pworld_type.PWORLD_CATEGORY_DUNGEON then
		FLOG_INFO("RollMgr:OnClearDataByEvent  TempPworldCfg.Type is PWORLD_CATEGORY_DUNGEON")
		return
	end
	UIViewMgr:HideView(UIViewID.TeamRollPanel)
	self:OnTreasureAssign(false)
	self.AwardMap = {}
	TeamRollItemVM.AwardList:Clear()
	TeamRollItemVM.CurrentCountDownNum = 60
	TeamRollItemVM.HighValueAwardNum = 0
	for _, value in pairs(self.TeamRollTimerID) do
		self:UnRegisterTimer(value)
	end
end

function RollMgr:OnGameEventTeamInTeamChanged(IsInTeam)
	--- 退出队伍清除数据
	if not IsInTeam then
		self:OnClearDataByEvent()
	end
end

--- 宝箱是否显示
---@param IsShow boolean
function RollMgr:OnTreasureAssign(IsShow)
	if IsShow then
		UIViewMgr:ShowView(UIViewID.TeamRollTreasureBox)
	else
		UIViewMgr:HideView(UIViewID.TeamRollTreasureBox)
	end
	-- UIUtil.SetIsVisible(self.TeamRollTreasureBox, IsShow, true)
end

--- 检查装备列表有没有重复
function RollMgr:CheckEquipList(ResID)
	local EquipmentList = _G.ActorMgr:GetMajorRoleDetail().Equip.EquipList
	if EquipmentList == nil then
		return false
	end
	for _, value in pairs(EquipmentList) do
		if value.ResID == ResID then
			return true
		end
	end
	return false
end

-- 根据输入物品比较对应最高品级装备推荐
function RollMgr:RecommendEquipByProf(ItemVM)
	local Cfg = ItemVM.Cfg
	if Cfg == nil then
		FLOG_ERROR("ItemCfg:FindCfgByKey Is Nil ResID=%d", ItemVM.ResID)
		return false
	end
	local MajorID = MajorUtil.GetMajorProfID()
	if MajorID == nil then
		FLOG_ERROR("RecommendEquipByProf MajorID=nil")
		return false
	end
	local EquipmentList = _G.ActorMgr:GetMajorRoleDetail().Equip.EquipList
	if EquipmentList == nil then
		FLOG_ERROR("RecommendEquipByProf EquipmentList=nil")
		return false
	end
	--- 物品没有任何职业或类型职业限制
	if Cfg.ClassLimit == ProtoCommon.class_type.CLASS_TYPE_NULL and table.empty(Cfg.ProfLimit) then
		return false
	end
	
	--- 所有装备均仅判断当前职业
	local ProfLimit = Cfg.ProfLimit
	local ClassLimit = Cfg.ClassLimit
	local CurrentProf = MajorUtil.GetMajorProfID()
	local CurrentClass = MajorUtil.GetMajorProfClass()
	if ProfLimit ~= nil and next(ProfLimit) then
		for _, v in pairs(ProfLimit) do
			if v == CurrentProf and self:CheckAllEquipIsHighestItemLevel(Cfg, EquipmentList) then
				return true
			end
		end
	else
		if ClassLimit == nil then
			return false
		end
		-- 符合配置里职业类型
		if ClassLimit == CurrentClass then
			return self:CheckAllEquipIsHighestItemLevel(Cfg, EquipmentList)
		end
	end
	return false
end

--- 检查传入装备是否在所有装备里有提升(装备栏)
function RollMgr:CheckAllEquipIsHighestItemLevel(ParamItemCfg, EquipmentList)
	local MasterHand = nil
	local SlaveHand = nil
	local EquipItem_Ring1 = nil
	local EquipItem_Ring2 = nil
	local EquipItem = nil
	local CurrentProf = MajorUtil.GetMajorProfID()
	
	for _, value in pairs(EquipmentList) do
		if ParamItemCfg.Classify ~= ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_RING then
			local TempPart = self:ConverPartEquipToItem(value.Attr.Equip.Part)
			if ParamItemCfg.Classify == TempPart then
				EquipItem = value
				return self:CheckItemLevelByItemData(value, ParamItemCfg)
			end
			--- 主副手武器
			if value.Attr.Equip.Part == ProtoCommon.equip_part.EQUIP_PART_MASTER_HAND then
				MasterHand = value
			elseif value.Attr.Equip.Part == ProtoCommon.equip_part.EQUIP_PART_SLAVE_HAND then
				SlaveHand = value
			end
		else
			if value.Attr.Equip.Part == ProtoCommon.equip_part.EQUIP_PART_FINGER then
				if EquipItem_Ring1 == nil then
					EquipItem_Ring1 = value
				elseif EquipItem_Ring2 == nil then
					EquipItem_Ring2 = value
				end
			end
		end
	end
	--- 武具箱特殊判断
	if ParamItemCfg.ItemType == ProtoCommon.ITEM_TYPE_DETAIL.CONSUMABLES_TREASUREBOX then
		local TreasureboxCfg = RollTreasureboxCfg:FindCfgByKey(ParamItemCfg.ItemID)
		if TreasureboxCfg ~= nil then
			if CurrentProf == ProtoCommon.prof_type.PROF_TYPE_PALADIN or CurrentProf == ProtoCommon.prof_type.PROF_TYPE_GLADIATOR then
				return self:CheckItemLevelByItemData(MasterHand, TreasureboxCfg) or self:CheckItemLevelByItemData(SlaveHand, TreasureboxCfg)
			end
		end
	else
		--- 两个戒指
		if EquipItem_Ring1 ~= nil and EquipItem_Ring2 ~= nil then
			local TempRing1Cfg = ItemCfg:FindCfgByKey(EquipItem_Ring1.ResID)
			local TempRing2Cfg = ItemCfg:FindCfgByKey(EquipItem_Ring2.ResID)
			if TempRing1Cfg and TempRing2Cfg then
				if TempRing1Cfg.ItemLevel > TempRing2Cfg.ItemLevel then
					return self:CheckItemLevelByItemData(EquipItem_Ring2, ParamItemCfg)
				else
					return self:CheckItemLevelByItemData(EquipItem_Ring1, ParamItemCfg)
				end
			end
		elseif ParamItemCfg.Classify == ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_RING then
			--- 只有一个戒指
			return true
		end
		--- 装备栏没有当前部位装备
		if EquipItem == nil then
			return true
		end
	end
	

	return false
end

--- 比较品级
function RollMgr:CheckItemLevelByItemData(ItemData, Cfg)
	if nil ~= ItemData then
		local EquipItemCfg = ItemCfg:FindCfgByKey(ItemData.ResID)
		if EquipItemCfg ~= nil then
			--- 仅比较品级，不需要考虑等级限制
			return Cfg.ItemLevel > EquipItemCfg.ItemLevel
		end
	end
	return true
end

--- 物品表和装备里某些部位枚举不一致   
--- 转换装备里的部位到物品表   
--- ProtoCommon.equip_part  To  ProtoRes.ITEM_CLASSIFY_TYPE
function RollMgr:ConverPartEquipToItem(Part)
	local TempPart = 0
	--- 腕部
	if Part == ProtoCommon.equip_part.EQUIP_PART_WRIST then
		TempPart = ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_FINESSE
	--- 耳部
	elseif Part == ProtoCommon.equip_part.EQUIP_PART_EAR then
		TempPart = ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_ERR
	--- 颈部
	elseif Part == ProtoCommon.equip_part.EQUIP_PART_NECK then
		TempPart = ProtoRes.ITEM_CLASSIFY_TYPE.ITEM_CLASSIFY_EQUIP_NECK
	else
		TempPart = Part
	end

	return TempPart
end

function RollMgr:TestEquip(ResID)
	local TeamDistributeItemVM = require("Game/Team/VM/TeamDistributeItemVM")

	local ItemVM = TeamDistributeItemVM.New()
	ItemVM.ResID = ResID
	ItemVM.Cfg = ItemCfg:FindCfgByKey(ResID)
	self:RecommendEquipByProf(ItemVM)

end

function RollMgr:OnBoxTimer()
	self.BoxRollAnimationTime = (self.BoxRollAnimationTime + 0.05) % 2
end

return RollMgr