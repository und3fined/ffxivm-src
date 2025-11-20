---
--- Author: Administrator
--- DateTime: 2025-07-03 10:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local PVPCrystallineRankRewardVM = require ("Game/PVP/Info/VM/PVPCrystallineRankRewardVM")
local PVPInfoVM = require ("Game/PVP/Info/VM/PVPInfoVM")

local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")

local PVPInfoMgr = _G.PVPInfoMgr
local LSTR = _G.LSTR

---@class PVPCrystallineRankRewardPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommTabs CommTabsView
---@field RichTextDesc URichTextBox
---@field TableViewReward UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPCrystallineRankRewardPanelView = LuaClass(UIView, true)

function PVPCrystallineRankRewardPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommTabs = nil
	--self.RichTextDesc = nil
	--self.TableViewReward = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPCrystallineRankRewardPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommTabs)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPCrystallineRankRewardPanelView:OnInit()
	self.ViewModel = PVPCrystallineRankRewardVM.New()
	self.CommTabs:SetCallBack(self, self.OnTabsChanged)
	self.RewardList = UIAdapterTableView.CreateAdapter(self, self.TableViewReward)
	self.InfoBinders = {
		{ "IsSeriesOpening", UIBinderValueChangedCallback.New(self, nil, self.OnIsSeriesOpeningChanged) },
	}
end

function PVPCrystallineRankRewardPanelView:OnDestroy()

end

function PVPCrystallineRankRewardPanelView:OnShow()
	local SelectedIndex = self.CommTabs:GetSelectedIndex() or 1
	self.CommTabs:SetSelectedIndex(SelectedIndex, true)
end

function PVPCrystallineRankRewardPanelView:OnHide()

end

function PVPCrystallineRankRewardPanelView:OnRegisterUIEvent()

end

function PVPCrystallineRankRewardPanelView:OnRegisterGameEvent()

end

function PVPCrystallineRankRewardPanelView:OnRegisterBinder()
	if PVPInfoVM then
		self:RegisterBinders(PVPInfoVM, self.InfoBinders)
	end
end

function PVPCrystallineRankRewardPanelView:OnTabsChanged(Index)
	local VMList = nil
	if Index == 1 then
		VMList = self.ViewModel.RankingVMList
	elseif Index == 2 then
		VMList = self.ViewModel.RankVMList
	end

	if VMList then
		self.RewardList:UpdateAll(VMList)
	end
end

function PVPCrystallineRankRewardPanelView:OnIsSeriesOpeningChanged(NewValue, OldValue)
	local CurVersionCfg = PVPInfoMgr:GetCurVersionSeriesMalmstoneCfg()
	if CurVersionCfg then
		local Text = string.format(LSTR(130091), CurVersionCfg.Season)
		self.RichTextDesc:SetText(Text)
	end
end

return PVPCrystallineRankRewardPanelView