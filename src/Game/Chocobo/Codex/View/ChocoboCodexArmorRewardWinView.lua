---
--- Author: Administrator
--- DateTime: 2023-12-25 11:28
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetPercent = require("Binder/UIBinderSetPercent")
local UIBinderSetSlider = require("Binder/UIBinderSetSlider")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")

---@class ChocoboCodexArmorRewardWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field PopUpBG CommonPopUpBGView
---@field ProgressBarFull UProgressBar
---@field RichTextCollect URichTextBox
---@field SliderFull UFSlider
---@field TableViewAward UTableView
---@field TableViewNode UTableView
---@field TextCollect UFTextBlock
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboCodexArmorRewardWinView = LuaClass(UIView, true)

function ChocoboCodexArmorRewardWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.PopUpBG = nil
	--self.ProgressBarFull = nil
	--self.RichTextCollect = nil
	--self.SliderFull = nil
	--self.TableViewAward = nil
	--self.TableViewNode = nil
	--self.TextCollect = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboCodexArmorRewardWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboCodexArmorRewardWinView:OnInit()
	self.AwardTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewAward, self.OnAwardSelectChange, true)
	self.AwardTableView:SetScrollbarIsVisible(false)

	self.NodeTableView = UIAdapterTableView.CreateAdapter(self, self.TableViewNode, nil, true)
	self.NodeTableView:SetScrollbarIsVisible(false)
end

function ChocoboCodexArmorRewardWinView:OnDestroy()

end

function ChocoboCodexArmorRewardWinView:OnShow()
	-- LSTR string: 装甲收集奖励
	self.TextTitle:SetText(_G.LSTR(670015))
	-- LSTR string: 已收集：
	self.TextCollect:SetText(_G.LSTR(670016))

	self.ViewModel:UpdatePartRewardWin()
end

function ChocoboCodexArmorRewardWinView:OnHide()

end

function ChocoboCodexArmorRewardWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnClickedBtnClose)
end

function ChocoboCodexArmorRewardWinView:OnRegisterGameEvent()

end

function ChocoboCodexArmorRewardWinView:OnRegisterBinder()
	self.Binders = {
		{"Collect", UIBinderSetText.New(self, self.RichTextCollect)},
		{"NodeList", UIBinderUpdateBindableList.New(self, self.NodeTableView) },
		{"AwardList", UIBinderUpdateBindableList.New(self, self.AwardTableView) },
		{"ProgressBarFull", UIBinderSetPercent.New(self, self.ProgressBarFull) },
		{"SliderFull", UIBinderSetSlider.New(self, self.SliderFull) },
	}

	self.ViewModel = _G.ChocoboCodexArmorPanelVM:GetRewardWinVM() 
	self:RegisterBinders(self.ViewModel, self.Binders)
end

function ChocoboCodexArmorRewardWinView:OnClickedBtnClose()
	self:Hide()
end

function ChocoboCodexArmorRewardWinView:OnAwardSelectChange(Index, ItemData, ItemView)
	if ItemData.CollectedState == 2 then
		_G.ChocoboCodexArmorMgr:ChocoboGetPartProscessAwardReq(Index)
		ItemView:PlayAnimDone() 
	end
end

return ChocoboCodexArmorRewardWinView