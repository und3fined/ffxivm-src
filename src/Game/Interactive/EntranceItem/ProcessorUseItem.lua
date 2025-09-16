---
--- Author: lydianwang
--- DateTime: 2022-04-11
---

local LuaClass = require("Core/LuaClass")
local BagMgr = require("Game/Bag/BagMgr")
local MajorUtil = require("Utils/MajorUtil")
local TimerMgr = require("Timer/TimerMgr")
local ActorUtil = require("Utils/ActorUtil")
local QuestHelper = require("Game/Quest/QuestHelper")

local ProtoRes = require("Protocol/ProtoRes")
local FuncType = ProtoRes.FuncType

local EActorType = _G.UE.EActorType
local QuestMgr = nil
local InteractiveMgr = nil
local SelectTargetMgr = nil

local CheckResultCode = {
	Success = 0,
	ItemNotExist = 1,
	ItemCondFailed = 2,
	SkillSelectFailed = 3,
	QuestCondFailed = 4,
	Others = 9,
}

local BtnDebugMsg = {
	[CheckResultCode.Success] = "Success",
	[CheckResultCode.ItemNotExist] = "ItemNotExist",
	[CheckResultCode.ItemCondFailed] = "ItemCondFailed",
	[CheckResultCode.SkillSelectFailed] = "SkillSelectFailed",
	[CheckResultCode.QuestCondFailed] = "QuestCondFailed",
	[CheckResultCode.Others] = "Others",
}

local function DistSortComp(a, b) return a.Dist < b.Dist end

---每个实例对应一种物品
---@class PUnitUseItem
local PUnitUseItem = LuaClass()

function PUnitUseItem:Ctor(ItemID)
	self.ItemID = ItemID
	self.CurrItemData = nil
	self.BtnSkillID = 0

	---被静态物品条件筛掉的ActorResID
	self.ExeptionResID = {}
	---动态筛掉的ActorEntityID
	self.PreExeptionEntityID = {}
	self.ExeptionEntityID = {}
	---有可能可以显示交互的Actor信息
	self.CandidateActorInfoList = {}
	---可显示交互的最近Actor索引
	self.IndexToShow = 0

	self.QuestTargetIDList = {}

	self.CurrItemData = BagMgr:GetItemByResID(self.ItemID)
	if self.CurrItemData == nil then
		_G.FLOG_ERROR("failed to create PUnitUseItem, ItemID=%d", self.ItemID or 0)
		return
	end

	local FuncCfg = BagMgr:GetItemFuncCfg(self.ItemID)
	if FuncCfg then
		for _, Func in pairs(FuncCfg.Func)do
			if Func.Type == FuncType.Skill then
				self.BtnSkillID = Func.Value[1]
				break
			end
		end
	end
end

---@return CheckResultCode
function PUnitUseItem:CanShowInteraction(ResID, ActorType, InEntityID)
	if self.CurrItemData == nil then return CheckResultCode.ItemNotExist end

	if not BagMgr:ItemUseCondition(self.CurrItemData, ResID, InEntityID, true) then
		return CheckResultCode.ItemCondFailed
	end

	local RetQuestParams = nil
	local Result = false

	local bQuestTargetRegistered = (nil == next(self.QuestTargetIDList)) -- QuestTargetIDList为空时视为与任务目标无关
	for _, QuestTargetID in ipairs(self.QuestTargetIDList) do		
		Result, RetQuestParams = QuestMgr:IsTargetRegisteredOnActor(QuestTargetID, ActorType, ResID)
		if Result then
			bQuestTargetRegistered = true
			break
		end
	end
	if not bQuestTargetRegistered then
		return CheckResultCode.QuestCondFailed
	end

	--检查对应的任务是否可继续
	if (RetQuestParams ~= nil and RetQuestParams.QuestID ~= nil) then
		if (not QuestHelper.CheckCanProceed(RetQuestParams.QuestID)) then
			return CheckResultCode.QuestCondFailed
		end
	end

	if (self.BtnSkillID == nil) or (self.BtnSkillID == 0) then
		return CheckResultCode.Success
	end

	local TargetList = SelectTargetMgr:CheckTaskUseItemTargets({ InEntityID }, self.BtnSkillID, MajorUtil.GetMajor())
	if (TargetList == nil) or (#TargetList == 0) then
		return CheckResultCode.SkillSelectFailed
	end

	for _, TargetActor in ipairs(TargetList) do
		local AttrCmp = TargetActor:GetAttributeComponent()
		if (AttrCmp ~= nil) and (InEntityID == AttrCmp.EntityID) then
			return CheckResultCode.Success
		end
	end

	return CheckResultCode.Others
end

function PUnitUseItem:OnEnterRange(Params)
    local ActorType = Params.IntParam1
    local EntityID = Params.ULongParam1
    local ResID = Params.ULongParam2

	-- 物品检查带有距离检查，不再是静态检查，不适用ExeptionResID了
	-- if self.ExeptionResID[ResID] then return end

	self.CurrItemData = BagMgr:GetItemByResID(self.ItemID)

	local CheckResult = self:CanShowInteraction(ResID, ActorType, EntityID)

	local ItemID = self.CurrItemData and self.CurrItemData.ResID or 0
	print("debug OnEnterRange", ResID, ItemID, self.BtnSkillID, BtnDebugMsg[CheckResult])

	if CheckResult == CheckResultCode.ItemCondFailed then
		-- self.ExeptionResID[ResID] = true -- 简单筛选优化
		return
	end

	for _, ActorInfo in ipairs(self.CandidateActorInfoList) do
		if EntityID == ActorInfo.EntityID then
			return
		end
	end

	local Actor = ActorUtil.GetActorByEntityID(EntityID)
	if Actor then
		table.insert(self.CandidateActorInfoList, {
			ActorType = ActorType,
			EntityID = EntityID,
			ResID = ResID,
			Dist = Actor:GetDistanceToMajor(),
			CheckResult = CheckResult,
		})
		if CheckResult == CheckResultCode.Success then
			self.IndexToShow = #self.CandidateActorInfoList
		end
	end
end

function PUnitUseItem:OnLeaveRange(Params)
    -- local ActorType = Params.IntParam1
    local EntityID = Params.ULongParam1
    -- local ResID = Params.ULongParam2

	self.PreExeptionEntityID[EntityID] = nil
	self.ExeptionEntityID[EntityID] = nil
	-- if self.ExeptionResID[ResID] then return end

	-- print("PUnitUseItem:OnLeaveRange start", #self.CandidateActorInfoList)
	for i, ActorInfo in ipairs(self.CandidateActorInfoList) do
		if EntityID == ActorInfo.EntityID then
			table.remove(self.CandidateActorInfoList, i)
			-- print("remove", i)

			if self.IndexToShow > i then
				self.IndexToShow = self.IndexToShow - 1
			end

			break
		end
	end
	-- print("PUnitUseItem:OnLeaveRange end", #self.CandidateActorInfoList)
end

function PUnitUseItem:OnProcessorTick()
	for i = #self.CandidateActorInfoList, 1, -1 do
		local ActorInfo = self.CandidateActorInfoList[i]
		local Actor = ActorUtil.GetActorByEntityID(ActorInfo.EntityID)

		if (not Actor) or self.ExeptionEntityID[ActorInfo.EntityID] then
			table.remove(self.CandidateActorInfoList, i)
			-- if self.ExeptionEntityID[ActorInfo.EntityID] then
			-- 	print("PUnitUseItem meet ExeptionEntityID", self.ItemID, ActorInfo.EntityID)
			-- end

		else
			ActorInfo.Dist = Actor:GetDistanceToMajor()
			ActorInfo.CheckResult = self:CanShowInteraction(ActorInfo.ResID, ActorInfo.ActorType, ActorInfo.EntityID)

			-- print("debug OnProcessorTick", ActorInfo.ResID, self.CurrItemData.ResID,
			-- 	self.BtnSkillID, BtnDebugMsg[ActorInfo.CheckResult])

			if ActorInfo.CheckResult == CheckResultCode.ItemCondFailed then
				-- self.ExeptionResID[ActorInfo.ResID] = true
				table.remove(self.CandidateActorInfoList, i)
			end
		end
	end

	if 0 == #self.CandidateActorInfoList then
		self.IndexToShow = 0
		return
	end

	--默认
	self.IndexToShow = 0

	table.sort(self.CandidateActorInfoList, DistSortComp)

	for i, ActorInfo in ipairs(self.CandidateActorInfoList) do
		if ActorInfo.CheckResult == CheckResultCode.Success then
			self.IndexToShow = i
			break
		end
	end
end

function PUnitUseItem:AllowTick()
	return #self.CandidateActorInfoList ~= 0
end

function PUnitUseItem:GetActorInfoToShow()
	if self.IndexToShow > 0 then
		return self.CandidateActorInfoList[self.IndexToShow]
	else
		return nil
	end
end

function PUnitUseItem:AddQuestTargetID(QuestTargetID)
	for _, ID in ipairs(self.QuestTargetIDList) do
		if ID == QuestTargetID then
			return
		end
	end
	table.insert(self.QuestTargetIDList, QuestTargetID)
end

function PUnitUseItem:RemoveQuestTargetID(QuestTargetID)
	for i, ID in ipairs(self.QuestTargetIDList) do
		if ID == QuestTargetID then
			table.remove(self.QuestTargetIDList, i)
			return
		end
	end
end

-------------------------------------------------------------------------

---管理所有PUnitUseItem
---@class ProcessorUseItem
local ProcessorUseItem = LuaClass()

function ProcessorUseItem:Ctor()
	self.ProcessorUnitList = {}
	self.TimerID = nil

	self.InRangeActors = {}

	QuestMgr = _G.QuestMgr
	InteractiveMgr = _G.InteractiveMgr
	SelectTargetMgr = _G.SelectTargetMgr
end

function ProcessorUseItem:AddProcessorUnit(ItemID, QuestTargetID)
	local NewPUnit = nil
	for _, PUnit in ipairs(self.ProcessorUnitList) do
		if PUnit.ItemID == ItemID then
			NewPUnit = PUnit
			break
		end
	end

	if not NewPUnit then
		NewPUnit = PUnitUseItem.New(ItemID)
		if NewPUnit.CurrItemData == nil then return end
		table.insert(self.ProcessorUnitList, NewPUnit)
	end

	if QuestTargetID then
		NewPUnit:AddQuestTargetID(QuestTargetID)
	end
	
	for _, Params in pairs(self.InRangeActors) do
		NewPUnit:OnEnterRange(Params)
		if NewPUnit:AllowTick() then
			self:ProcessorTick(true)
			self:AddTimer()
		end
	end
end

function ProcessorUseItem:RemoveProcessorUnit(ItemID, QuestTargetID)
	local OldPUnit = nil
	local Index = nil
	for i, PUnit in ipairs(self.ProcessorUnitList) do
		if PUnit.ItemID == ItemID then
			OldPUnit = PUnit
			Index = i
			break
		end
	end
	if not OldPUnit then return end

	if QuestTargetID then
		OldPUnit:RemoveQuestTargetID(QuestTargetID)
		if next(OldPUnit.QuestTargetIDList) then return end
	end

	table.remove(self.ProcessorUnitList, Index)
end

function ProcessorUseItem:OnEnterRange(Params)
    local ActorType = Params.IntParam1
    -- local EntityID = Params.ULongParam1
    -- local ResID = Params.ULongParam2

	if (ActorType ~= EActorType.Npc)
	and (ActorType ~= EActorType.Monster)
	and (ActorType ~= EActorType.EObj)
	then return end

	self.InRangeActors[Params.ULongParam1] = {
		IntParam1 = Params.IntParam1,
		ULongParam1 = Params.ULongParam1,
		ULongParam2 = Params.ULongParam2,
	}

	local bAllowTick = false
	for _, PUnit in ipairs(self.ProcessorUnitList) do
		PUnit:OnEnterRange(Params)
		if PUnit:AllowTick() then
			bAllowTick = true
		end
	end

	if not bAllowTick then return end

	self:ProcessorTick(true)
	self:AddTimer()
end

function ProcessorUseItem:OnLeaveRange(Params)
    local ActorType = Params.IntParam1
    -- local EntityID = Params.ULongParam1
    -- local ResID = Params.ULongParam2

	if (ActorType ~= EActorType.Npc)
	and (ActorType ~= EActorType.Monster)
	and (ActorType ~= EActorType.EObj)
	then return end

	self.InRangeActors[Params.ULongParam1] = nil

	local bAllowTick = false
	for _, PUnit in ipairs(self.ProcessorUnitList) do
		PUnit:OnLeaveRange(Params)
		if PUnit:AllowTick() then
			bAllowTick = true
		end
	end

	if not bAllowTick then
		self:ClearTimer()
	end
	self:ProcessorTick(true)
end

function ProcessorUseItem:OnPWorldExit(_)
	self:ClearTimer()
end

function ProcessorUseItem:OnEnd()
	self:ClearTimer()
end


local function SendEventShowInteraction(PUnit, ActorInfo, bIntendedCall)
	local ViewParams = {
		CurrItemData = PUnit.CurrItemData,
		TargetEntityID = ActorInfo.EntityID,
		LimitValue = ActorInfo.ResID,
	}
	local EntranceParams = {
        IntParam1 = ActorInfo.ActorType,
        ULongParam1 = ActorInfo.EntityID,
        ULongParam2 = ActorInfo.ResID,
		ViewParams = ViewParams,
	}
	InteractiveMgr:ShowEntranceUseItem(EntranceParams, bIntendedCall)
end

local function SendEventHideInteraction()
	InteractiveMgr:HideEntranceUseItem()
end

---@param bIntendedCall boolean 主动（非定时器）调用
function ProcessorUseItem:ProcessorTick(bIntendedCall)
	if InteractiveMgr.bMainPanelClosedByOtherUI then
		return
	end

	local PreparedPUnitList = {}
	for _, PUnit in ipairs(self.ProcessorUnitList) do
		PUnit:OnProcessorTick()
		local ActorInfoToShow = PUnit:GetActorInfoToShow()
		if ActorInfoToShow then
			table.insert(PreparedPUnitList, {
				PUnit = PUnit,
				ActorInfo = ActorInfoToShow,
				Dist = ActorInfoToShow.Dist, -- 用于排序
			})
		end
	end

	if 0 == #PreparedPUnitList then
		SendEventHideInteraction()
		return
	end

	table.sort(PreparedPUnitList, DistSortComp)

	local PUnit = PreparedPUnitList[1].PUnit
	local ActorInfo = PreparedPUnitList[1].ActorInfo
	SendEventShowInteraction(PUnit, ActorInfo, bIntendedCall)
end

function ProcessorUseItem:AddTimer()
	if self.TimerID == nil then
		local TimerID = TimerMgr:AddTimer(self, self.ProcessorTick, 1, 1, 0)
		self.TimerID = TimerID
	end
end

function ProcessorUseItem:ClearTimer()
	if self.TimerID then
		TimerMgr:CancelTimer(self.TimerID)
		self.TimerID = nil
	end
	SendEventHideInteraction()
end

function ProcessorUseItem:ClearAllException()
	for _, PUnit in ipairs(self.ProcessorUnitList) do
		PUnit.ExeptionResID = {}
		PUnit.PreExeptionEntityID = {}
		PUnit.ExeptionEntityID = {}
	end
end

---开始使用物品时预先准备ExeptionEntityID
function ProcessorUseItem:SetPreExeptionEntityID(ItemID, EntityID)
	for _, PUnit in ipairs(self.ProcessorUnitList) do
		if PUnit.ItemID == ItemID then
			PUnit.PreExeptionEntityID[EntityID] = true
		end
	end
end

---成功使用物品后应用ExeptionEntityID
function ProcessorUseItem:ApplyExeptionEntityID()
	for _, PUnit in ipairs(self.ProcessorUnitList) do
		if next(PUnit.PreExeptionEntityID) ~= nil then
			for EntityID, _ in pairs(PUnit.PreExeptionEntityID) do
				PUnit.ExeptionEntityID[EntityID] = true
			end
			PUnit.PreExeptionEntityID = {}
		end
	end
end

return ProcessorUseItem