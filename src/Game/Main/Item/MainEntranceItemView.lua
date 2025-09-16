---
--- Author: loiafeng
--- DateTime: 2025-01-23 17:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MajorUtil = require("Utils/MajorUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local LevelExpCfg = require("TableCfg/LevelExpCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local MainPanelConfig = require("Game/Main/MainPanelConfig")
local EntranceType = MainPanelConfig.LifeProfEntranceType
local CollectablesDefine = require("Game/Collectables/CollectablesDefine")
local CommonUtil = require("Utils/CommonUtil")

---@class MainEntranceItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewEntrance UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainEntranceItemView = LuaClass(UIView, true)

function MainEntranceItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewEntrance = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainEntranceItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainEntranceItemView:OnInit()
	self.AdapterEntranceTable = UIAdapterTableView.CreateAdapter(self, self.TableViewEntrance)  ---@type UIAdapterTableView
end

function MainEntranceItemView:OnDestroy()

end

function MainEntranceItemView:OnShow()
	self:UpdateEntranceTable()
end

function MainEntranceItemView:OnHide()

end

function MainEntranceItemView:OnRegisterUIEvent()

end

function MainEntranceItemView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.ModuleOpenNotify, self.OnModuleOpenNotify)
	self:RegisterGameEvent(_G.EventID.MajorProfSwitch, self.UpdateEntranceTable)
	self:RegisterGameEvent(_G.EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)
end

function MainEntranceItemView:OnRegisterBinder()

end

function MainEntranceItemView:OnModuleOpenNotify(ModuleID)
	if ProtoCommon.ModuleID.ModuleIDLeveQuest == ModuleID or
			ProtoCommon.ModuleID.ModuleIDCollection == ModuleID then
		self:UpdateEntranceTable()
	end
end

function MainEntranceItemView:OnMajorLevelUpdate(Params)
	local Level = Params.RoleDetail.Simple.Level
	local OldLevel = Params.OldLevel or 0
	local MaxLevel = LevelExpCfg:GetMaxLevel()
	local MinUnLockLevel = CollectablesDefine.MinUnLockLevel
	if (OldLevel < MinUnLockLevel and Level >= MinUnLockLevel)
			or (OldLevel < MaxLevel and Level >= MaxLevel) then
		self:UpdateEntranceTable()
	end
end

function MainEntranceItemView:UpdateEntranceTable()
	local _ <close> = CommonUtil.MakeProfileTag("MainEntranceItemView:UpdateEntranceTable")

	if not MajorUtil.IsCrafterProf() and
			not MajorUtil.IsGatherProf() and
			not MajorUtil.IsFishingProf() then
		UIUtil.SetIsVisible(self.TableViewEntrance, false)
		return
	end

	UIUtil.SetIsVisible(self.TableViewEntrance, true)
	-- 倒序
	local EntranceList = {}
	local CurrLevel = MajorUtil.GetTrueMajorLevel()

	-- 3. 收藏品交易。需要满足等级要求
	if _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDCollection) and CurrLevel >= CollectablesDefine.MinUnLockLevel then
		table.insert(EntranceList, { Type = EntranceType.Collection })
	end

	-- 2. 理符。已解锁且未满级时显示
	if (CurrLevel < LevelExpCfg:GetMaxLevel()) and _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDLeveQuest) then
		table.insert(EntranceList, { Type = EntranceType.LeveQuest })
	end

	-- 1. 各职业笔记
	if MajorUtil.IsCrafterProf() then
		table.insert(EntranceList, { Type = EntranceType.CraftingLog })
	elseif MajorUtil.IsGatherProf() then
		table.insert(EntranceList, { Type = EntranceType.GatheringLog })
	elseif MajorUtil.IsFishingProf() then
		table.insert(EntranceList, { Type = EntranceType.FishNotes })
	end

	self.AdapterEntranceTable:UpdateAll(EntranceList)
end

return MainEntranceItemView