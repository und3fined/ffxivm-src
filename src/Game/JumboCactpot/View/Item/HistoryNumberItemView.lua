---
--- Author: Administrator
--- DateTime: 2023-09-18 09:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local JumboCactpotVM = require("Game/JumboCactpot/JumboCactpotVM")
local ProtoRes = require("Protocol/ProtoRes")
local ItemTipsUtil = require("Utils/ItemTipsUtil")
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr

---@class HistoryNumberItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnMore UFButton
---@field PanelContent UFCanvasPanel
---@field PanelDate UFCanvasPanel
---@field PanelEmpty UFCanvasPanel
---@field PanelMore UFCanvasPanel
---@field PanelReward01 UFCanvasPanel
---@field PanelReward02 UFCanvasPanel
---@field RichTextDate01 URichTextBox
---@field RichTextDate02 URichTextBox
---@field Slot01 CommBackpack126SlotView
---@field Slot02 CommBackpack126SlotView
---@field TableViewName UTableView
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field Text03 UFTextBlock
---@field Text04 UFTextBlock
---@field TextEmpty UFTextBlock
---@field TextMore UFTextBlock
---@field TextNumber UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HistoryNumberItemView = LuaClass(UIView, true)

function HistoryNumberItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnMore = nil
	--self.PanelContent = nil
	--self.PanelDate = nil
	--self.PanelEmpty = nil
	--self.PanelMore = nil
	--self.PanelReward01 = nil
	--self.PanelReward02 = nil
	--self.RichTextDate01 = nil
	--self.RichTextDate02 = nil
	--self.Slot01 = nil
	--self.Slot02 = nil
	--self.TableViewName = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.Text03 = nil
	--self.Text04 = nil
	--self.TextEmpty = nil
	--self.TextMore = nil
	--self.TextNumber = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HistoryNumberItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Slot01)
	self:AddSubView(self.Slot02)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HistoryNumberItemView:OnInit()
	self.NameListAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewName, nil, true)


	self.Binders = {
		{ "Term", UIBinderSetText.New(self, self.RichTextDate01)},--
		{ "OpenTime", UIBinderSetText.New(self, self.RichTextDate02)},
		{ "FirstNum", UIBinderSetText.New(self, self.Text01)},
		{ "SecondNum", UIBinderSetText.New(self, self.Text02)},
		{ "ThirdNum", UIBinderSetText.New(self, self.Text03)},
		{ "ForthNum", UIBinderSetText.New(self, self.Text04)},
		{ "RewardNum", UIBinderSetText.New(self, self.Slot01.RichTextQuantity)},
		{ "ItemCount", UIBinderSetText.New(self, self.Slot02.RichTextQuantity)},
		{ "JDIcon", UIBinderSetBrushFromAssetPath.New(self, self.Slot01.Icon) },
		{ "ItemIcon", UIBinderSetBrushFromAssetPath.New(self, self.Slot02.Icon) },
		{ "NameList", UIBinderUpdateBindableList.New(self, self.NameListAdapter)},
		{ "bContentVisible", UIBinderSetIsVisible.New(self, self.PanelContent)},
		{ "bEmptyVisible", UIBinderSetIsVisible.New(self, self.PanelEmpty)},
		{ "bContentVisible", UIBinderSetIsVisible.New(self, self.PanelDate)},
	}
end

function HistoryNumberItemView:OnDestroy()

end

function HistoryNumberItemView:OnShow()
	UIUtil.SetIsVisible(self.Slot01.RichTextQuantity, true)
	UIUtil.SetIsVisible(self.Slot02.RichTextQuantity, true)

	self.Slot01:SetItemLevel("")
	self.Slot02:SetItemLevel("")

	self.Slot01:SetIconChooseVisible(false)
	self.Slot02:SetIconChooseVisible(false)

	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end

	UIUtil.SetIsVisible(self.PanelMore, #ViewModel.RoleList > 4)

	self.Slot01:SetClickButtonCallback(self.Slot01, function(TargetItemView)
		ItemTipsUtil.CurrencyTips(ProtoRes.SCORE_TYPE.SCORE_TYPE_KING_DEE, false, TargetItemView)
	end)

	self.Slot02:SetClickButtonCallback(self.Slot02, function(TargetItemView)
		ItemTipsUtil.ShowTipsByResID(ViewModel.ItemResID, self.Slot02)
	end)

	self:InitLSTRText()
end

function HistoryNumberItemView:InitLSTRText()
	local LSTR = _G.LSTR
	self.TextNumber:SetText(LSTR(240093)) -- 中奖号码
	self.TextMore:SetText(LSTR(240094)) -- 查看更多
	self.TextEmpty:SetText(LSTR(240095)) -- 敬请期待...
end

function HistoryNumberItemView:OnHide()

end

function HistoryNumberItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMore, self.OnBtnMoreClick)
end

function HistoryNumberItemView:OnRegisterGameEvent()

end

function HistoryNumberItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
    self:RegisterBinders(ViewModel, self.Binders)
end

function HistoryNumberItemView:OnBtnMoreClick()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
		return
	end
	local RoleList = ViewModel.RoleList
	--ViewModel.RoleList = JumboCactpotMgr:GetNameColorAndSortID(RoleList)

	local TempParams = { Term = ViewModel.Term, OpenTime = ViewModel.OpenTime }

	JumboCactpotVM:UpdateList(JumboCactpotVM.LottoryNameList, RoleList)
	UIViewMgr:ShowView(UIViewID.JumboCactpotHistorylottery, TempParams)
end

return HistoryNumberItemView