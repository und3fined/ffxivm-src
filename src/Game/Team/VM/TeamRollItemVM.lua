
local LuaClass = require("Core/LuaClass")
local BagMgr = require("Game/Bag/BagMgr")
local ItemVM = require("Game/Item/ItemVM")
local RoleVM = require("Game/Role/RoleVM")
local MajorUtil = require("Utils/MajorUtil")
local RollMgr = require("Game/Roll/RollMgr")
local UIViewModel = require("UI/UIViewModel")
local RoleInitCfg = require("TableCfg/RoleInitCfg")
local UIBindableList = require("UI/UIBindableList")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local TeamDistributeItemVM = require("Game/Team/VM/TeamDistributeItemVM")
local ItemCfg = require("TableCfg/ItemCfg")
local TimeUtil = require("Utils/TimeUtil")

-- local ItemCfg = require("TableCfg/ItemCfg")

-- 1000000 道具已选中
local ItemStatus =
				{
					Preview = 64, --1000000
					Recommend = 32,--0100000,
					IsWait = 8,--0001000,
					IsGiveUp = 4,--0000100,
					Obtained = 2,--0000010,
					NotObtained = 1,
					AlreadyPossessed = 128,
					NotEligibility = 16,
					NoStatus = 0,
				}

---@class TeamRollItemVM : UIViewModel
local TeamRollItemVM = LuaClass(UIViewModel)

---Ctor
---@field BindableListMember UIBindableList
---@field JoinRedDotVisible boolean
---@field FunctionBarVisible boolean
---@field TextVoice string
function TeamRollItemVM:Ctor()
    -- self.AwardList = UIBindableList.New(ItemVM, {IsInitNonRecuseParams = true}) --奖励物列
	self.AwardList = UIBindableList.New(TeamDistributeItemVM) --奖励物列
	self.ValuablesList = UIBindableList.New(ItemVM) --奖励物列
	self.TeamID = 2              		-- 当前队伍ID
	self.CurrentCountDownNum = 60
	self.IsOperated = nil
	self.IsAllOperated = true
	self.IsStartRoll = false
	self.IsAwradResult = false
	self.UpdateAwardID = 0
	self.UpdateTeamID = 0
	self.IsStartRollTimer = false
	self.AwardExpireTime = 0
	self.IsShowTips = false
	self.CurrentSelectedAwardID = 0
	self.CurrentSelectedTeamID = 0
	self.HighValueAwardNum = 0

	--- 最新的宝箱里是否有贵重物品
	self.CurAwardsIsHaveHighValue = false
end

function TeamRollItemVM:OnInit()
	--self:SetMajorInfo()
end

function TeamRollItemVM:OnBegin()
end

function TeamRollItemVM:OnEnd()
end

function TeamRollItemVM:OnShutdown()
end

function TeamRollItemVM:UpdateAwardList(AwardList, TeamID)

	local Preview = ItemVM.SelectMode.Preview
	self.UpdateAwardID = 1
	self.UpdateTeamID = TeamID
	local CheckHighValueIndex = true
	for i = 1, #AwardList do
		local value = AwardList[i]
		local Value = {}
		local IsHighValue = false
		Value.ExpireTime = value.ExpireTime
		Value.TeamID = TeamID
		Value.AwardID = value.ID
		Value.Num = value.Num
		local TempItemCfg = ItemCfg:FindCfgByKey(value.ResID)
		IsHighValue = TempItemCfg.IsHighValue == 1
		Value.IsHighValue = IsHighValue
		self.HighValueAwardNum = IsHighValue and self.HighValueAwardNum + 1 or self.HighValueAwardNum
		Value.ResID = value.ResID
		Value.SelectedMode =  Preview
		Value.IsBind = value.Bind
		local InsetIndex = IsHighValue and 1 or self.HighValueAwardNum + 1
		--- 每个宝箱检查一次，为的是计算最小倒计时，因为贵重物品放在第一个，没有贵重物品的话，最晚过期的奖励下标在self.HighValueAwardNum+ 1 
		if CheckHighValueIndex then
			self.CurAwardsIsHaveHighValue = IsHighValue
			CheckHighValueIndex = false
		end
		if self.AwardList:Length() == 0 then
			self.AwardList:AddByValue(Value)
		else
			--- 高价值道具往最上面放，否则就放在最后一个高价值道具后面
			self.AwardList:InsertByValue(Value, InsetIndex)
		end
		self.AwardList:Get(InsetIndex):OnInit()
	end
end

-- AwardNotifyReslut此变量用于监听是否有下发Roll点结果
function TeamRollItemVM:UpdateRollItemInfo(TeamID, AwardNotifyReslut)
	local AwardList = RollMgr:GetAwardList(TeamID)
	FLOG_INFO("TeamRoll  UpdateRollItemInfo  TeamID ==  " .. TeamID)
	if AwardList == nil or AwardList.AwardList == nil then
		return
	end
	local AwardResult = AwardList.AwardList
	for _, value in ipairs(AwardResult) do
		local valueID = value.ID
		FLOG_INFO("TeamRoll  UpdateRollItemInfo  valueID ==  " .. valueID)
		local ExpireTime = value.ExpireTime
		local AwardVM = self:GetAwardVM(valueID, TeamID)
		local ServerTime = TimeUtil.GetServerTime()
		local RoleID = MajorUtil.GetMajorRoleID()
		if AwardVM ~= nil then
			local ItemStatusValue = 0
			local MajorRoleID = MajorUtil.GetMajorRoleID()
			local AwardBelong = RollMgr:GetAwardBelong(valueID, TeamID)
			--- 有归属了，但是还没操作 这里额外判断下过期时间或者操作状态
			if AwardBelong ~= nil then
				FLOG_INFO("TeamRoll  UpdateRollItemInfo  AwardBelong ~= nil ")
				if (ExpireTime < ServerTime or AwardVM.IsOperated) then
					FLOG_INFO("TeamRoll  UpdateRollItemInfo  Item IsOperated or Expired ")
					AwardVM.IsWait = false
					if AwardBelong.RoleID == MajorRoleID then
						FLOG_INFO("TeamRoll  UpdateRollItemInfo  Obtained ")
						ItemStatusValue = ItemStatusValue | ItemStatus.Obtained --已获得
						AwardVM.Obtained = true
					elseif not AwardVM.IsAlreadyPossessed and not AwardVM.IsGiveUp then
						FLOG_INFO("TeamRoll  UpdateRollItemInfo  not AwardVM.IsAlreadyPossessed and not AwardVM.IsGiveUp ")
						local TempResult = -1
						if AwardList.RollList ~= nil then
							for _, RollListItem in ipairs(AwardList.RollList) do
								if RollListItem.RoleID == RoleID and RollListItem.ID == valueID then
									TempResult = RollListItem.Result
									break
								end
							end
						end
						if AwardBelong.RoleID == 0 then
							FLOG_INFO("TeamRoll  UpdateRollItemInfo  IsGiveUp  1")
							ItemStatusValue = ItemStatusValue | ItemStatus.IsGiveUp -- 已放弃
						else
							if TempResult == -1 then
								FLOG_INFO("TeamRoll  UpdateRollItemInfo  IsGiveUp  2")
								ItemStatusValue = ItemStatusValue | ItemStatus.IsGiveUp -- 已放弃
								--- 这里是时间到了，但是没有自己的点数，证明是无资格玩家，后台没有下发，手动设置一下
								RollMgr:AddRollList(TeamID, {RoleID = MajorRoleID, Result = -1, ID = valueID})
							else
								FLOG_INFO("TeamRoll  UpdateRollItemInfo  NotObtained  1")
								ItemStatusValue = ItemStatusValue | ItemStatus.NotObtained --未获得
							end
						end
					elseif AwardVM.IsAlreadyPossessed then
						FLOG_INFO("TeamRoll  UpdateRollItemInfo  IsGiveUp  3")
						ItemStatusValue = ItemStatusValue | ItemStatus.IsGiveUp -- 已放弃
					end
					--队伍视图获得玩家的亮 ，其他灰
					AwardVM.IsOperated = true
					AwardVM.IsShowPanelBtn = false
					AwardVM.CountDownNum = 0
					self.IsAwradResult = true
					self.IsStartRoll = false
					AwardVM.IsBelong = true
					AwardVM.ItemName = ""
					AwardVM.IsShowPanelProbar = false
				end
				if AwardBelong.RoleID ~= 0 and AwardBelong.RoleID ~= nil then
					FLOG_INFO("TeamRoll  UpdateRollItemInfo  **获得  ")
					local Role = RoleInfoMgr:FindRoleVM(AwardBelong.RoleID, true)
					AwardVM.RichTextDescribe = string.format(LSTR(480009), Role.Name)		--- <span color=#d1ba8eFF>%s</>获得
				else
					-- if (ItemStatusValue & 4) >> 2 == 1 then
					-- 	AwardVM.ItemName = ""
						FLOG_INFO("TeamRoll  UpdateRollItemInfo  被所有人放弃 ")
						AwardVM.RichTextDescribe = LSTR(480010)											--- 被所有人放弃
					-- end
				end
			else
				FLOG_INFO("TeamRoll  UpdateRollItemInfo  AwardBelong == nil !")
			end
			if AwardVM.IsOperated and AwardBelong == nil then
				self.IsAwradResult = false
				self.IsStartRoll = true
			end
			if AwardVM.IsWait then
				ItemStatusValue = ItemStatusValue | ItemStatus.IsWait
			end
			local TempResult = 0
			if AwardList.RollList ~= nil then
				for _, RollListItem in ipairs(AwardList.RollList) do
					if RollListItem.RoleID == RoleID and RollListItem.ID == valueID then
						TempResult = RollListItem.Result
						break
					end
				end
			end
			--- 只有未操作的时候才判断显示无资格，操作过后无资格变为放弃 -2 后台状态里  暂时是  补人和已拥有，这里按照已拥有配置取反相当于补人
			if (AwardBelong == nil or AwardBelong.RoleID == 0) and (TempResult == -2 and not AwardVM.IsOperated and ExpireTime > ServerTime) then
				local bIsPossesses = RollMgr:CheckIsPossesses(AwardVM)
				if not bIsPossesses then
					ItemStatusValue = ItemStatusValue | ItemStatus.NotEligibility -- 无资格
					AwardVM.IsHaveEligibility = false
				end
			end
			if not AwardVM.IsGiveUp then	--推荐最优装备
				local IsRecommend = RollMgr:RecommendEquipByProf(AwardVM)
				if IsRecommend then
					local ProfID = MajorUtil.GetMajorProfID()
					local ProfInfo = RoleInitCfg:FindCfgByKey(ProfID)
					if ProfInfo ~= nil then
						AwardVM.FuncImg = ProfInfo.ProfIcon
						ItemStatusValue = ItemStatusValue | ItemStatus.Recommend -- 推荐
						AwardVM.CornerPos = _G.UE.FVector2D(-157, -152)			-- 装备职业提升图标位置左上角
					end
				end
			end
			if AwardVM.IsPreview then
				ItemStatusValue = ItemStatusValue | ItemStatus.Preview -- 预览
			end
			-- 设置Item状态
			self:SetItemStatus(AwardVM, ItemStatusValue)
			self:UpdateTeamRollResult(valueID)
			-- 通知Roll点结束
			if not RollMgr:HasAssignedReward() then
				_G.EventMgr:SendEvent(_G.EventID.TeamRollEndEvent)
			end
			-- 队伍奖励品Roll显示
			local AwardVMAwardID = AwardVM.AwardID
			-- 下发Roll点结果时更新奖励数字
			if self.CurrentSelectedAwardID == AwardVMAwardID then
				_G.EventMgr:SendEvent(_G.EventID.TeamRollItemSelectEvent, {AwardID = AwardVMAwardID, IsSwitch = false, AwardNotifyReslut = AwardNotifyReslut, TeamID = AwardVM.TeamID})
			end
		end
	end
end

function TeamRollItemVM:UpdateTeamRollResult(AwardID)
	self.UpdateAwardID = AwardID
	local AwardBelong = RollMgr:GetAwardBelong(AwardID)
	if AwardBelong == nil then
		-- 成员Roll动画开始滚动
		-- 当前玩家
		-- self.IsAwradResult = false
		self.IsStartRoll = true
		-- 获取结果后显示结果动画
	else
		-- 显示点数高的成功结果动画
		-- self.IsStartRoll = false
		self.IsAwradResult = true
	end

end

function TeamRollItemVM:GetAwardVM(AwardID, TeamID)
	local AwardVM
	for i = 1,  self.AwardList:Length() do
		AwardVM = self.AwardList:Get(i)
		if AwardID == AwardVM.AwardID and TeamID == AwardVM.TeamID then
			return AwardVM
		end
	end
	return nil
end

function TeamRollItemVM:SetCurrentCountDownNum(TeamID)
	-- if self.IsAllOperated then
	-- 	return
	-- end
	local MinCountDownNum = 0
	local MinCDIndex = self.CurAwardsIsHaveHighValue and 1 or self.HighValueAwardNum + 1
	for i = 1, self.AwardList:Length() do
		local AwardItemVM = self.AwardList:Get(i)
		MinCountDownNum = self.AwardList:Get(MinCDIndex).CountDownNum
		if AwardItemVM.TeamID == TeamID and AwardItemVM.CountDownNum > 1 then
			AwardItemVM.CountDownNum = AwardItemVM.CountDownNum - 0.3
			if AwardItemVM.CountDownNum < self.CurrentCountDownNum then
				self.CurrentCountDownNum = math.floor(AwardItemVM.CountDownNum)
			end
			if AwardItemVM.CountDownNum < MinCountDownNum and AwardItemVM.CountDownNum > 0 then
				MinCountDownNum = math.floor(AwardItemVM.CountDownNum)
			end
			if AwardItemVM.CountDownNum < 1 then
				AwardItemVM.IsShowPanelProbar = false
			end
		end
	end
	if self.CurrentCountDownNum < 1 and MinCountDownNum > self.CurrentCountDownNum then
		self.CurrentCountDownNum = MinCountDownNum
	end
end

--- 全部操作后AwardList所有倒计时归零
-- function TeamRollItemVM:SetAwardListCountDown()
-- 	for i = 1, self.AwardList:Length() do
-- 		local AwardItemVM = self.AwardList:Get(i)
-- 		AwardItemVM.CountDownNum = 0
-- 	end
-- end

function TeamRollItemVM:SetSelectedIndex(Index)
	for i = 1, self.AwardList:Length() do
		local AwardItemVM = self.AwardList:Get(i)
		if Index == i then
			AwardItemVM:SetIsSelected(true)
		else
			AwardItemVM:SetIsSelected(false)
		end
	end
end

function TeamRollItemVM:OnCheckAwardsIsOperated()
	for i = 1, self.AwardList:Length() do
		local AwardItemVM = self.AwardList:Get(i)
		if not AwardItemVM.IsOperated then
			return
		end
	end
	self.IsAllOperated = true
end

--- 是否还有未操作的贵重物品
function TeamRollItemVM:CheckForUnoperatedValuables()
	local HaveUnOpVa = false
	for i = 1, self.AwardList:Length() do
		local AwardItemVM = self.AwardList:Get(i)
		if not AwardItemVM.IsOperated and AwardItemVM.IsHighValue then
			HaveUnOpVa = true
			break
		end
	end
	_G.EventMgr:SendEvent(_G.EventID.TeamRollBoxEFFEvent, {IsIn = false})
	_G.EventMgr:SendEvent(_G.EventID.TeamRollBoxEFFEvent, {IsIn = true, IsHaveHighValue = HaveUnOpVa})
end

function TeamRollItemVM:SetItemStatus(TempItemVM, Status)

	if (Status & 64) >> 6 == 1 then --FImg_Preview 1000000
		TempItemVM.IsPreview = true
	else
		TempItemVM.IsPreview = false
	end

	if (Status & 32) >> 5 == 1 then --Recommend 0100000
		TempItemVM.IsRecommend = true
	else
		TempItemVM.IsRecommend = false
	end

	if (Status & 16) >> 4 == 1 then --Text_Ineligibility FImg_Mask 0010000
		TempItemVM.IsHaveEligibility = false
		TempItemVM.IsMask = true
		TempItemVM.TextDes = LSTR(480008)	--- 无资格
	else
		TempItemVM.IsHaveEligibility = true
	end

	if (Status & 8) >> 3 == 1 then --FImg_Wait FImg_Mask 0001000
		TempItemVM.IsMask = true
		TempItemVM.IsWait = true
	else
		TempItemVM.IsWait = false
	end

	if (Status & 4) >> 2 == 1 then --Text_GiveUp FImg_Mask 0000100
		TempItemVM.IsMask = true
		TempItemVM.IsGiveUp = true
		TempItemVM.TextDes = LSTR(480005)	--- 放弃
	else
		TempItemVM.IsGiveUp = false
	end
	if (Status & 2) >> 1 == 1 then ----FImg_Got  FImg_Mask 0000010
		TempItemVM.Obtained = true
		TempItemVM.HasGot = true
		TempItemVM.IsMask = true
		TempItemVM.TextDes = ""
	else
		TempItemVM.HasGot = false
		TempItemVM.Obtained = false
	end
	if (Status & 1) == 1 then ---- Text_NotObtained FImg_Mask 0000010
		TempItemVM.NotObtained = true
		TempItemVM.IsMask = true
		TempItemVM.TextDes = LSTR(480006)	--- 未获得
	else
		TempItemVM.NotObtained = false
	end

	if (Status & 128) >> 7 == 1 then --Text_AlreadyPossessed 10000010
		TempItemVM.IsAlreadyPossessed = true
		TempItemVM.IsMask = true
		TempItemVM.TextDes = LSTR(480007)	--- 已拥有
	else
		TempItemVM.IsAlreadyPossessed = false
	end
end

return TeamRollItemVM