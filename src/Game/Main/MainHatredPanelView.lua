---
--- Author: loiafeng
--- DateTime: 2025-01-23 17:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

local MajorUtil = require("Utils/MajorUtil")
local ActorUtil = require("Utils/ActorUtil")
local CommonUtil = require("Utils/CommonUtil")
local SelectTargetBase = require("Game/Skill/SelectTarget/SelectTargetBase")
local ProtoRes = require("Protocol/ProtoRes")
local MonsterCfg = require("TableCfg/MonsterCfg")
local MainEnmityPanelVM = require("Game/Main/EnmityPanel/MainEnmityPanelVM")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local TargetMgr = _G.TargetMgr ---@type TargetMgr
local EventID = _G.EventID

local DisplayCount = 4 -- 最多显示4个
local MaxRank = 99999

---@class MainHatredPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewHatred UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainHatredPanelView = LuaClass(UIView, true)

function MainHatredPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewHatred = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainHatredPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

---@class MonsterEnmityInfo
---@field EntityID number
---@field RankInEnmityList number @主角在怪物仇恨列表中的排名

function MainHatredPanelView:OnInit()
	self.MonsterList = {}  ---@type table<MonsterEnmityInfo> @副本内的怪物列表
	self.DisplayEntityIDSet = {}  ---@type table<number, boolean> @实际显示的怪物

	self.AdapterEnmityList = UIAdapterTableView.CreateAdapter(self, self.TableViewHatred)  ---@type UIAdapterTableView
	self.Binders = {
		{ "EnmityDisplayList", UIBinderUpdateBindableList.New(self, self.AdapterEnmityList) },
	}
end

function MainHatredPanelView:OnDestroy()

end

function MainHatredPanelView:OnShow()
	self:InitMonsterList()
	self:UpdateEnmityView()
end

function MainHatredPanelView:OnHide()

end

function MainHatredPanelView:OnRegisterUIEvent()

end

function MainHatredPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
	self:RegisterGameEvent(EventID.CombatGetEnmityList, self.OnGameEventCombatGetEnmityList)
end

function MainHatredPanelView:OnRegisterBinder()
	self:RegisterBinders(MainEnmityPanelVM, self.Binders)
end

function MainHatredPanelView:OnRegisterTimer()
end

function MainHatredPanelView:OnGameEventLoginRes(Param)
    if Param and Param.bReconnect then
		self:InitMonsterList()
		self:UpdateEnmityView()
    end
end

function MainHatredPanelView:OnGameEventVisionLeave(Params)
	if nil == Params then
		return
	end

	local EntityID = Params.ULongParam1

	-- if not ActorUtil.IsMonster(Params.EntityID) then
	-- 	return
	-- end

	-- local Relation = SelectTargetBase:GetCampRelationByEntityID(EntityID)
	-- if ProtoRes.camp_relation.camp_relation_enemy ~= Relation then
	-- 	return
	-- end

	local bRemove = table.array_remove_item_pred(self.MonsterList, function(Item) return Item.EntityID == EntityID end)
	if bRemove then
		self:UpdateEnmityView()
	end
end

---@param Lhs MonsterEnmityInfo
---@param Rhs MonsterEnmityInfo
local function SortMonsterListPredicate(Lhs, Rhs)
	if Lhs.RankInEnmityList ~= Rhs.RankInEnmityList then
		-- 非一仇优先显示
		return Lhs.RankInEnmityList > Rhs.RankInEnmityList
	end

	return Lhs.EntityID < Rhs.EntityID
end

local function IsExpectedMonster(EntityID)
	if not ActorUtil.IsMonster(EntityID) then
		return false
	end

	local Relation = SelectTargetBase:GetCampRelationByEntityID(EntityID)
	if ProtoRes.camp_relation.camp_relation_enemy ~= Relation then
		return false
	end

	local ResID = ActorUtil.GetActorResID(EntityID)
	local HideInEnmityList = MonsterCfg:FindValue(ResID, "HideInEnmityList")
	if HideInEnmityList ~= 0 then
		return false
	end

	return true
end

function MainHatredPanelView:OnGameEventCombatGetEnmityList(Params)
	local _ <close> = CommonUtil.MakeProfileTag("MainHatredPanelView:OnGameEventCombatGetEnmityList")

	local EntityID = Params.EntityID
	if not IsExpectedMonster(EntityID) then
		return
	end

	-- 怪物没有仇恨时，不需要在仇恨列表中显示
	if 0 == #Params.List then
		local bOK = table.array_remove_item_pred(self.MonsterList, function(Item) return Item.EntityID == EntityID end)
		if bOK then
			self:UpdateEnmityView()
		end
	else
		local Rank = MaxRank
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		for Num, Enmity in ipairs(Params.List) do
			if Enmity.ID == MajorEntityID then
				Rank = Num
				break
			end
		end

		local EnmityInfo = table.find_by_predicate(self.MonsterList, function(Item) return Item.EntityID == EntityID end)
		if nil == EnmityInfo then
			table.insert(self.MonsterList, { EntityID = EntityID, RankInEnmityList = Rank, })
			self:UpdateEnmityView()
		elseif EnmityInfo.RankInEnmityList ~= Rank then
			EnmityInfo.RankInEnmityList = Rank
			self:UpdateEnmityView()
		end
	end
end

function MainHatredPanelView:InitMonsterList()
	local _ <close> = CommonUtil.MakeProfileTag("MainHatredPanelView:InitMonsterList")

	self.MonsterList = {}
	self.DisplayEntityIDSet = {}

	local ActorManager = _G.UE.UActorManager.Get()
	local AllMonsters = ActorManager:GetAllMonsters()
	local Length = AllMonsters:Length()
	local MajorEntityID = MajorUtil.GetMajorEntityID()
	for i = 1, Length do
		local Monster = AllMonsters:GetRef(i)
		local EntityID = Monster:GetActorEntityID()
		if IsExpectedMonster(EntityID) then
			local FirstTarget = TargetMgr:GetFirstTargetOfMonster(EntityID)
			-- 有仇恨才需要显示
			if 0 ~= FirstTarget then
				table.insert(self.MonsterList, { EntityID = EntityID,
					RankInEnmityList = (FirstTarget == MajorEntityID) and 1 or MaxRank, })  -- loiafeng: 目前初始化时只处理一仇
			end
		end
	end
end

function MainHatredPanelView:UpdateEnmityView()
	local _ <close> = CommonUtil.MakeProfileTag("MainHatredPanelView:UpdateEnmityView")

	table.sort(self.MonsterList, SortMonsterListPredicate)

	local OldDisplaySet = self.DisplayEntityIDSet
	self.DisplayEntityIDSet = {}

	local ItemVMParamsList = {}
	for i = DisplayCount, 1, -1 do -- 倒序排布

		local EnmityInfo = self.MonsterList[i]
		if nil ~= EnmityInfo then
			self.DisplayEntityIDSet[EnmityInfo.EntityID] = true

			table.insert(ItemVMParamsList, {
				EntityID = EnmityInfo.EntityID,
				RankInMonsterEnmityList = EnmityInfo.RankInEnmityList,
				bLastIsDisplay = OldDisplaySet[EnmityInfo.EntityID],
			})
		else
			table.insert(ItemVMParamsList, {
				EntityID = 0,
				RankInMonsterEnmityList = MaxRank,
				bLastIsDisplay = true,
			})
		end
	end

	MainEnmityPanelVM.EnmityDisplayList:UpdateByValues(ItemVMParamsList)
end

return MainHatredPanelView