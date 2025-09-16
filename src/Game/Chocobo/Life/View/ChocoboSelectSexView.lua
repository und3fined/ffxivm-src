---
--- Author: Administrator
--- DateTime: 2025-03-31 21:02
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ChocoboDefine = require("Game/Chocobo/ChocoboDefine")

---@class ChocoboSelectSexView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose CommonCloseBtnView
---@field CheckBoxFemale UToggleButton
---@field CheckBoxMale UToggleButton
---@field FImg_Box UFImage
---@field FImg_Box_1 UFImage
---@field FImg_Check UFImage
---@field FImg_Check_1 UFImage
---@field LeftBtnOp CommBtnLView
---@field Panel2Btns UFHorizontalBox
---@field PopUpBG CommonPopUpBGView
---@field RichTextBoxDesc URichTextBox
---@field RichTextBoxTitle URichTextBox
---@field RightBtnOp CommBtnLView
---@field SpacerMid USpacer
---@field ToggleGroupCheck UToggleGroup
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboSelectSexView = LuaClass(UIView, true)

function ChocoboSelectSexView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.CheckBoxFemale = nil
	--self.CheckBoxMale = nil
	--self.FImg_Box = nil
	--self.FImg_Box_1 = nil
	--self.FImg_Check = nil
	--self.FImg_Check_1 = nil
	--self.LeftBtnOp = nil
	--self.Panel2Btns = nil
	--self.PopUpBG = nil
	--self.RichTextBoxDesc = nil
	--self.RichTextBoxTitle = nil
	--self.RightBtnOp = nil
	--self.SpacerMid = nil
	--self.ToggleGroupCheck = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.Gender = 0 -- Boy
end

function ChocoboSelectSexView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnClose)
	self:AddSubView(self.LeftBtnOp)
	self:AddSubView(self.PopUpBG)
	self:AddSubView(self.RightBtnOp)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboSelectSexView:OnInit()
	self.IsSuc = false
end

function ChocoboSelectSexView:OnDestroy()

end

function ChocoboSelectSexView:OnShow()
	self.IsSuc = false
	self.ToggleGroupCheck:SetCheckedIndex(self.Gender, true)
	self.LeftBtnOp:SetButtonText(_G.LSTR(10003))
	self.RightBtnOp:SetButtonText(_G.LSTR(10002))
	self.RichTextBoxTitle:SetText(_G.LSTR(420174))
	self.RichTextBoxDesc:SetText(_G.LSTR(420175))
end

function ChocoboSelectSexView:OnHide()
	if not self.Params or not self.Params.Source then
		return
	end

	if self.IsSuc then
		return
	end

	if self.Params.Source ~= ChocoboDefine.SOURCE.TASK then
		return
	end

	_G.EventMgr:SendEvent(_G.EventID.ChocoboNameTaskRevert)
end

function ChocoboSelectSexView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.LeftBtnOp, self.OnClickedCancelBtn)
	UIUtil.AddOnClickedEvent(self, self.RightBtnOp, self.OnClickedConfirmBtn)
	UIUtil.AddOnStateChangedEvent(self, self.ToggleGroupCheck, self.OnToggleGroupCheckChanged)
end

function ChocoboSelectSexView:OnRegisterGameEvent()
end

function ChocoboSelectSexView:OnRegisterBinder()

end

function ChocoboSelectSexView:OnToggleGroupCheckChanged(ToggleGroup, ToggleButton, Index, State)
	self.Gender = Index
end

function ChocoboSelectSexView:OnClickedCancelBtn()
	self:Hide()
end

function ChocoboSelectSexView:OnClickedConfirmBtn()
	local Source = ChocoboDefine.SOURCE.ADOPT
	if self.Params ~= nil and self.Params.Source ~= nil then
		Source = self.Params.Source
	end
	_G.UIViewMgr:ShowView(_G.UIViewID.ChocoboNameWinView, {Source = Source, Gender = self.Gender})
	self.IsSuc = true
	self:Hide()
end

return ChocoboSelectSexView