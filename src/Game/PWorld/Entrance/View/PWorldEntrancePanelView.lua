---
--- Author: v_hggzhang
--- DateTime: 2023-04-19 10:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView =  require("UI/Adapter/UIAdapterTableView")
local UIBinderSetVisibility = require("Binder/UIBinderSetVisibility")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class PWorldEntrancePanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTeach UFButton
---@field CloseBtn CommonCloseBtnView
---@field EntranceChocobo PWorldEntranceChocoboItemView
---@field EntranceMagicCard PWorldEntranceMagicCardItemView
---@field MatchSelection PWorldMatchSelectionPanelView
---@field PanelBGGoldSaucer UFCanvasPanel
---@field PanelBGPVP UFCanvasPanel
---@field PanelBGPWorld UFCanvasPanel
---@field PanelGoldSaucer UFCanvasPanel
---@field PanelPVP UFCanvasPanel
---@field PanelPWorld UFCanvasPanel
---@field TableViewEntrance UTableView
---@field TableViewPVP UTableView
---@field TextTeach UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimEntranceIn UWidgetAnimation
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldEntrancePanelView = LuaClass(UIView, true)

function PWorldEntrancePanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTeach = nil
	--self.CloseBtn = nil
	--self.EntranceChocobo = nil
	--self.EntranceMagicCard = nil
	--self.MatchSelection = nil
	--self.PanelBGGoldSaucer = nil
	--self.PanelBGPVP = nil
	--self.PanelBGPWorld = nil
	--self.PanelGoldSaucer = nil
	--self.PanelPVP = nil
	--self.PanelPWorld = nil
	--self.TableViewEntrance = nil
	--self.TableViewPVP = nil
	--self.TextTeach = nil
	--self.TextTitle = nil
	--self.AnimEntranceIn = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldEntrancePanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CloseBtn)
	self:AddSubView(self.EntranceChocobo)
	self:AddSubView(self.EntranceMagicCard)
	self:AddSubView(self.MatchSelection)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

-- Item Idx to SneceCfgID

function PWorldEntrancePanelView:OnInit()
	self.PWorldEntIndex = 1
	self.AdpTablePWorld = UIAdapterTableView.CreateAdapter(self, self.TableViewEntrance, function(_, Idx, VM)
		if not VM then
			return
		end
		PWorldEntUtil.ShowPWorldEntView(VM.TypeID)
	end, true, false)

	self.AdpTablePVP = UIAdapterTableView.CreateAdapter(self, self.TableViewPVP, self.OnTableViewPVPSelectChange, true)
	
    self.Binders = {
		{ "PWorldTypes",    UIBinderUpdateBindableList.New(self, self.AdpTablePWorld) },
		{ "PVPTypes",    UIBinderUpdateBindableList.New(self, self.AdpTablePVP) },
		{ "MatchSelectionVisibility",    UIBinderSetVisibility.New(self, self.MatchSelection) },
		{"bUnlockTeach", UIBinderSetIsVisible.New(self, self.BtnTeach, false, true)},
		{"TextTeach", UIBinderSetText.New(self, self.TextTeach)},
	}
end

function PWorldEntrancePanelView:OnShow()
	require("Game/PWorld/Entrance/PWorldEntVM"):UpdPWorldTypes()
	self.TextTitle:SetText(_G.LSTR(130066)) -- 玩法
	---- 跳转选中其他页签
	self.PWorldEntIndex = 1
	if self.Params and self.Params.JumpData and next(self.Params.JumpData) then
		self.PWorldEntIndex = self.Params.JumpData[1] or 1
		self.MatchSelection:SetDefaultSelected(self.PWorldEntIndex)
		self.Params.JumpData = nil
	else
		self.MatchSelection:SetDefaultSelected(self.PWorldEntIndex)
	end
	UIUtil.SetIsVisible(self.PanelBGPWorld, self.PWorldEntIndex == 1)
	UIUtil.SetIsVisible(self.PanelPWorld, self.PWorldEntIndex == 1)
	UIUtil.SetIsVisible(self.PanelBGGoldSaucer, self.PWorldEntIndex == 2)
	UIUtil.SetIsVisible(self.PanelGoldSaucer, self.PWorldEntIndex == 2)
	UIUtil.SetIsVisible(self.PanelBGPVP, self.PWorldEntIndex == 3)
	UIUtil.SetIsVisible(self.PanelPVP, self.PWorldEntIndex == 3)
end

function PWorldEntrancePanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTeach, function()
		_G.TeachingMgr:OnShowMainWindow()
	end)
end

function PWorldEntrancePanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PWorldEntSwitch, self.OnPWorldEntSwitch)
end

function PWorldEntrancePanelView:OnRegisterBinder()
	self:RegisterBinders(_G.PWorldEntVM, self.Binders)
end

function PWorldEntrancePanelView:OnPWorldEntSwitch(Index)
	if _G.PWorldEntVM == nil then
		return
	end

	if self.PWorldEntIndex == Index then
		return
	end

	self.PWorldEntIndex = Index
	UIUtil.SetIsVisible(self.PanelBGPWorld, Index == 1)
	UIUtil.SetIsVisible(self.PanelPWorld, Index == 1)
	UIUtil.SetIsVisible(self.PanelBGGoldSaucer, Index == 2)
	UIUtil.SetIsVisible(self.PanelGoldSaucer, Index == 2)
	UIUtil.SetIsVisible(self.PanelBGPVP, Index == 3)
	UIUtil.SetIsVisible(self.PanelPVP, Index == 3)
	self:PlayAnimation(self.AnimEntranceIn)
end

function PWorldEntrancePanelView:OnTableViewPVPSelectChange(Index, VM)
	if not VM then return end
	
	PWorldEntUtil.ShowPWorldEntView(VM.TypeID)
end

return PWorldEntrancePanelView