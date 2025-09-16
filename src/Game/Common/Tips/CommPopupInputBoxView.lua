---
--- Author: wallencai
--- DateTime: 2022-08-29 14:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

local LSTR = _G.LSTR

---@class CommPopupInputBoxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel CommBtnLView
---@field BtnSure CommBtnLView
---@field CommMsgTips_UIBP CommMsgTipsView
---@field GroupInput CommInputBoxView
---@field RichTextBox_Desc URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
---@field Params table @通过外部参数传入
---@field Params.Title string @标题
---@field Params.HintText string @提示文字
---@field Params.ConfirmButtonText string @确认按钮文字
---@field Params.CancelButtonText string @取消按钮文字
---@field Params.MaxTextLength integer @允许输入文本的最大长度
---@field Params.SureCallback(FText) function @点击确认按钮的回调函数
local CommPopupInputBoxView = LuaClass(UIView, true)

function CommPopupInputBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnSure = nil
	--self.CommMsgTips_UIBP = nil
	--self.GroupInput = nil
	--self.RichTextBox_Desc = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommPopupInputBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSure)
	self:AddSubView(self.CommMsgTips_UIBP)
	self:AddSubView(self.GroupInput)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommPopupInputBoxView:OnInit()

end

function CommPopupInputBoxView:OnDestroy()

end

function CommPopupInputBoxView:OnShow()
	if nil == self.Params then
		return
	end

	if self.Params.HideCancelBtn then
		UIUtil.SetIsVisible(self.BtnCancel, false)
	else
		UIUtil.SetIsVisible(self.BtnCancel, true, true)
	end

	if self.Params.Title and string.len(self.Params.Title) > 0 then
		self.CommMsgTips_UIBP.RichTextBox_Title:SetText(self.Params.Title)
	end

	self.RichTextBox_Desc:SetText(self.Params.Desc)
	self.GroupInput:SetHintText(self.Params.HintText)
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
end

function CommPopupInputBoxView:OnHide()

end

function CommPopupInputBoxView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSure.Button, self.OnSureBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnCancelBtnClick)
end

function CommPopupInputBoxView:OnRegisterGameEvent()

end

function CommPopupInputBoxView:OnRegisterBinder()

end

function CommPopupInputBoxView:OnCancelBtnClick()
	UIViewMgr:HideView(UIViewID.CommonPopupInput)
end

function CommPopupInputBoxView:OnSureBtnClick()
	if self.Params.SureCallback ~= nil then
		local InputText = self.GroupInput:GetText()
		self.Params.SureCallback(InputText)
	end

	UIViewMgr:HideView(UIViewID.CommonPopupInput)
end

return CommPopupInputBoxView