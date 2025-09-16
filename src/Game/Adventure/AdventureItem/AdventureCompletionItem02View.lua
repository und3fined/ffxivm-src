---
--- Author: sammrli
--- DateTime: 2023-05-12 20:47
--- Description:冒险系统公共Item
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetImageBrush = require("Binder/UIBinderSetImageBrush")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")

local LSTR = _G.LSTR

---@class AdventureCompletionItem02View : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnGet CommBtnSView
---@field BtnGo CommBtnSView
---@field ImgIconJob UFImage
---@field ImgTextIcon UFImage
---@field PanelJob UFCanvasPanel
---@field PanelUnFinishAlreadyGet UFCanvasPanel
---@field RedDot CommonRedDot2View
---@field RichTextDescription URichTextBox
---@field SpacerMainPanel USpacer
---@field TextContent UFTextBlock
---@field TextUnFinishAlreadyGet UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
---@field ViewModel AdventureItemVM
local AdventureCompletionItem02View = LuaClass(UIView, true)

function AdventureCompletionItem02View:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnGet = nil
	--self.BtnGo = nil
	--self.ImgIconJob = nil
	--self.ImgTextIcon = nil
	--self.PanelJob = nil
	--self.PanelUnFinishAlreadyGet = nil
	--self.RedDot = nil
	--self.RichTextDescription = nil
	--self.SpacerMainPanel = nil
	--self.TextContent = nil
	--self.TextUnFinishAlreadyGet = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.ViewModel = nil

end

function AdventureCompletionItem02View:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnGet)
	self:AddSubView(self.BtnGo)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AdventureCompletionItem02View:OnInit()
	self.AdapterRewardList = UIAdapterTableView.CreateAdapter(self, self.TableViewReward)
end

function AdventureCompletionItem02View:OnDestroy()
end

function AdventureCompletionItem02View:OnShow()
	self.BtnGet.TextContent:SetText(LSTR(520055))
	self.BtnGo.TextContent:SetText(LSTR(520008))
	self.BtnGet:SetIsEnabled(true)
	self.RedDot.TextNewYellow1:SetText(LSTR(520030))
	--self.BtnUnFinish.TextContent:SetText(LSTR(520036))
end

function AdventureCompletionItem02View:OnHide()
	if self.LockTimerID then
		self.LockTimerID = nil
		self:UnRegisterTimer(self.LockTimerID)
	end
end

function AdventureCompletionItem02View:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnGet, self.OnClickedGetHandle)
	UIUtil.AddOnClickedEvent(self, self.BtnGo, self.OnClickedGoHandle)
end

function AdventureCompletionItem02View:OnRegisterGameEvent()

end

function AdventureCompletionItem02View:OnRegisterBinder()
	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	---@type AdventureItemVM
	self.ViewModel = ViewModel

	local Binders = {
		{ "RewardList", UIBinderUpdateBindableList.New(self, self.AdapterRewardList)},
		{ "MainIconPath", UIBinderSetImageBrush.New(self, self.ImgTextIcon)},
		{ "ContentText", UIBinderSetText.New(self, self.TextContent)},
		{ "DescriptionText", UIBinderSetText.New(self, self.RichTextDescription)},
		{ "IsDescriptionVisible", UIBinderSetIsVisible.New(self, self.RichTextDescription)},
		{ "JobIconPath",UIBinderSetImageBrush.New(self, self.ImgIconJob)},
		{ "IsBtnGoVisible",UIBinderSetIsVisible.New(self, self.BtnGo)},
		{ "IsBtnGetVisible",UIBinderSetIsVisible.New(self, self.BtnGet)},
		{ "BtnGoText",UIBinderSetText.New(self, self.BtnGo.TextContent)},
		{ "BtnGetText",UIBinderSetText.New(self, self.BtnGet.TextContent)},
		{ "IsUnFinishVisible",UIBinderSetIsVisible.New(self, self.PanelUnFinishAlreadyGet)},
		{ "UnFinishText",UIBinderSetText.New(self, self.TextUnFinishAlreadyGet)},
		--{ "IsJobVisible", UIBinderSetIsVisible.New(self, self.ImgIconJob:GetParent())},
		{ "IsNewRedVisible", UIBinderSetIsVisible.New(self, self.RedDot)},
	}

	self:RegisterBinders(self.ViewModel, Binders)
end

function AdventureCompletionItem02View:OnClickedGetHandle()
	if self.ViewModel and self.ViewModel.OnClickGet then
		self.ViewModel:OnClickGet(self.ViewModel.ID)
	end
	self.BtnGet:SetIsEnabled(false)
	self.LockTimerID = self:RegisterTimer(self.OnUnlockBtnGet, 0, 1, 0)
end

function AdventureCompletionItem02View:OnClickedGoHandle()
	if self.ViewModel and self.ViewModel.OnClickGo then
		self.ViewModel:OnClickGo(self.ViewModel.ID)
	end
end

function AdventureCompletionItem02View:OnUnlockBtnGet()
	self.BtnGet:SetIsEnabled(true)
	self.LockTimerID = nil
end

return AdventureCompletionItem02View