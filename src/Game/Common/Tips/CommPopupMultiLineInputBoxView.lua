---
--- Author: xingcaicao
--- DateTime: 2023-03-06 20:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local LSTR = _G.LSTR

---@class CommPopupMultiLineInputBoxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Anonymous CommSingleBoxView
---@field BtnCancel CommBtnLView
---@field BtnSure CommBtnLView
---@field CommMsgTips_UIBP CommMsgTipsView
---@field GroupInput CommMultilineInputBoxView
---@field RichTextBox_Desc URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
---@field Params table @通过外部参数传入
---@field Params.Title string @标题
---@field Params.HintText string @提示文字
---@field Params.EnableLineBreak boolean @是否去除换行
---@field Params.CancelButtonText string @取消按钮文字
---@field Params.MaxTextLength integer @允许输入文本的最大长度
---@field Params.SureCallback(FText) function @点击确认按钮的回调函数
---@field Params.IsShowAnonymous bool @是否显示匿名勾选框
---@field Params.GetAnonymousCallback(IsChecked) function @点击匿名勾选框的回调函数
local CommPopupMultiLineInputBoxView = LuaClass(UIView, true)

function CommPopupMultiLineInputBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Anonymous = nil
	--self.BtnCancel = nil
	--self.BtnSure = nil
	--self.CommMsgTips_UIBP = nil
	--self.GroupInput = nil
	--self.RichTextBox_Desc = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommPopupMultiLineInputBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Anonymous)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSure)
	self:AddSubView(self.CommMsgTips_UIBP)
	self:AddSubView(self.GroupInput)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommPopupMultiLineInputBoxView:OnInit()

end

function CommPopupMultiLineInputBoxView:OnDestroy()

end

function CommPopupMultiLineInputBoxView:OnShow()
	if nil == self.Params then
		return
	end

	if self.Params.Title and string.len(self.Params.Title) > 0 then
		self.CommMsgTips_UIBP.RichTextBox_Title:SetText(self.Params.Title)
	end

	self.RichTextBox_Desc:SetText(self.Params.Desc)
	self.GroupInput:SetHintText(self.Params.HintText)
	self.GroupInput:SetIsEnableLineBreak(self.Params.EnableLineBreak)
	self.GroupInput:SetMaxNum(self.Params.MaxTextLength)
	self.GroupInput:SetText(self.Params.Content or "")

	if not string.isnilorempty(self.Params.ConfirmButtonText) then
		self.BtnSure:SetText(self.Params.ConfirmButtonText)
	else
		self.BtnSure:SetText(LSTR(10002)) -- "确  认"
	end

	if not string.isnilorempty(self.Params.CancelButtonText) then
		self.BtnCancel:SetText(self.Params.CancelButtonText)
	else
		self.BtnCancel:SetText(LSTR(10003)) -- "取  消"
	end

	-- 是否显示匿名勾选框
	if (self.Params.IsShowAnonymous == true) then
		UIUtil.SetIsVisible(self.Anonymous, true)
	else
		UIUtil.SetIsVisible(self.Anonymous, false)
	end
end

function CommPopupMultiLineInputBoxView:OnHide()

end

function CommPopupMultiLineInputBoxView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSure.Button, self.OnSureBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnCancelBtnClick)

end

function CommPopupMultiLineInputBoxView:OnRegisterGameEvent()
	UIUtil.AddOnStateChangedEvent(self, self.Anonymous, self.OnSingleBoxClick)
end

function CommPopupMultiLineInputBoxView:OnRegisterBinder()

end

function CommPopupMultiLineInputBoxView:OnSingleBoxClick(ToggleButton, ButtonState)
	local IsAnonymous = ButtonState == _G.UE.EToggleButtonState.Checked
	if self.Params.GetAnonymousCallback ~= nil then
		self.Params.GetAnonymousCallback(IsAnonymous)
	end
end

function CommPopupMultiLineInputBoxView:OnCancelBtnClick()
	UIViewMgr:HideView(UIViewID.CommonPopupMultiLineInput)
end

function CommPopupMultiLineInputBoxView:OnSureBtnClick()
	local InputText = self.GroupInput:GetText()
	if self.Params.SureCallback ~= nil then
		self.Params.SureCallback(InputText)
	end
	UIViewMgr:HideView(UIViewID.CommonPopupMultiLineInput)
end

return CommPopupMultiLineInputBoxView