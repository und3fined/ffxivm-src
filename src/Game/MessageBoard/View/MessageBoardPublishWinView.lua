---
--- Author: jamiyang
--- DateTime: 2023-08-24 19:55
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")

---@class MessageBoardPublishWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Anonymous CommSingleBoxView
---@field BtnCancel CommBtnLView
---@field BtnSure CommBtnLView
---@field GroupInput CommMultilineInputBoxView
---@field LeaveMessageWin CommMsgTipsView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
---@field Params table @通过外部参数传入
---@field Params.HintText string @提示文字
---@field Params.MaxTextLength integer @允许输入文本的最大长度
---@field Params.SureCallback(FText) function @点击确认按钮的回调函数
---@field Params.GetAnonymousCallback(IsChecked) function @点击匿名勾选框的回调函数
local MessageBoardPublishWinView = LuaClass(UIView, true)

function MessageBoardPublishWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Anonymous = nil
	--self.BtnCancel = nil
	--self.BtnSure = nil
	--self.GroupInput = nil
	--self.LeaveMessageWin = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MessageBoardPublishWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Anonymous)
	self:AddSubView(self.BtnCancel)
	self:AddSubView(self.BtnSure)
	self:AddSubView(self.GroupInput)
	self:AddSubView(self.LeaveMessageWin)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MessageBoardPublishWinView:OnInit()

end

function MessageBoardPublishWinView:OnDestroy()

end

function MessageBoardPublishWinView:OnShow()
	if nil == self.Params then
		return
	end
	self.GroupInput:SetHintText(self.Params.HintText)
	self.GroupInput:SetMaxNum(self.Params.MaxTextLength)
	self.GroupInput:SetText(self.Params.Content or "")
end

function MessageBoardPublishWinView:OnHide()

end

function MessageBoardPublishWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnSure.Button, self.OnSureBtnClick)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel.Button, self.OnCancelBtnClick)
end

function MessageBoardPublishWinView:OnRegisterGameEvent()
	UIUtil.AddOnStateChangedEvent(self, self.Anonymous, self.OnSingleBoxClick)
end

function MessageBoardPublishWinView:OnRegisterBinder()

end

function MessageBoardPublishWinView:OnSingleBoxClick(ToggleButton, ButtonState)
	local IsAnonymous = ButtonState == _G.UE.EToggleButtonState.Checked
	if self.Params.GetAnonymousCallback ~= nil then
		self.Params.GetAnonymousCallback(IsAnonymous)
	end
end

function MessageBoardPublishWinView:OnCancelBtnClick()
	UIViewMgr:HideView(UIViewID.MessageBoardPublishWin)
end

function MessageBoardPublishWinView:OnSureBtnClick()
	local InputText = self.GroupInput:GetText()
	if self.Params.SureCallback ~= nil then
		self.Params.SureCallback(InputText)
	end
	UIViewMgr:HideView(UIViewID.MessageBoardPublishWin)
end


return MessageBoardPublishWinView