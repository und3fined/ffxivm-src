---
--- Author: xingcaicao
--- DateTime: 2023-03-06 10:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local EventID = require("Define/EventID")

local FLOG_WARNING = _G.FLOG_WARNING
local FLOG_INFO = _G.FLOG_INFO
local TextCommitOnEnter = _G.UE.ETextCommit.OnEnter
local TextLocationEndOfDocument = _G.UE.ETextLocation.EndOfDocument

---@class CommSearchBarView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnCancel UFButton
---@field BtnCancelNode UFCanvasPanel
---@field FImageBgDark UFImage
---@field FImageBgLight UFImage
---@field FImageSearchDark UFImage
---@field FImageSearchLight UFImage
---@field FImgCancelDark UFImage
---@field FImgCancelLight UFImage
---@field TextInput UEditableText
---@field AnimIn UWidgetAnimation
---@field MaxTextLength int
---@field BtnCancelAlwaysVisible bool
---@field HintText text
---@field HintTextColor SlateColor
---@field HintTextColorOpacity float
---@field PreviewHintTextColor bool
---@field InputTextColor SlateColor
---@field SytleType CommUIStyleType
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommSearchBarView = LuaClass(UIView, true)

function CommSearchBarView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnCancel = nil
	--self.BtnCancelNode = nil
	--self.FImageBgDark = nil
	--self.FImageBgLight = nil
	--self.FImageSearchDark = nil
	--self.FImageSearchLight = nil
	--self.FImgCancelDark = nil
	--self.FImgCancelLight = nil
	--self.TextInput = nil
	--self.AnimIn = nil
	--self.MaxTextLength = nil
	--self.BtnCancelAlwaysVisible = nil
	--self.HintText = nil
	--self.HintTextColor = nil
	--self.HintTextColorOpacity = nil
	--self.PreviewHintTextColor = nil
	--self.InputTextColor = nil
	--self.SytleType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommSearchBarView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommSearchBarView:OnInit()

end

function CommSearchBarView:OnDestroy()

end

function CommSearchBarView:OnShow()
	self.IsFocusReceived = false
	self:UpdateCancelBtnVisible()

	self:RefreshTextColorAndOpacity(#self:GetText() <= 0)
	self.IsShowVirtualKeyboardExUI = false
end

function CommSearchBarView:OnHide()
	self.LastTextRefreshFlag = nil 
end

function CommSearchBarView:OnRegisterUIEvent()
	UIUtil.AddOnTextChangedEvent(self, self.TextInput, self.OnTextChange)
	UIUtil.AddOnTextCommittedEvent(self, self.TextInput, self.OnTextCommitted)
	UIUtil.AddOnFocusReceivedEvent(self, self.TextInput, self.OnTextFocusReceived)
	UIUtil.AddOnFocusLostEvent(self, self.TextInput, self.OnTextFocusLost)
	UIUtil.AddOnClickedEvent(self, self.BtnCancel, self.OnClickButtonCancel)
end

function CommSearchBarView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.VirtualKeyboardReturn, self.OnEventVirtualKeyboardReturn)

	if CommonUtil.IsAndroidPlatform() then
		self:RegisterGameEvent(EventID.VirtualKeyboardShown, self.OnEventShowVirtualKeyboard)
		self:RegisterGameEvent(EventID.VirtualKeyboardHidden, self.OnEventVirtualKeyboardHidden)
	end
	if CommonUtil.IsIOSPlatform() then
		self:RegisterGameEvent(EventID.VirtualKeyboardHidden, self.OnEventVirtualKeyboardHidden)
	end
end

function CommSearchBarView:OnRegisterBinder()

end

function CommSearchBarView:RefreshTextColorAndOpacity(IsHint)
	IsHint = IsHint == true

	if IsHint == self.LastTextRefreshFlag then
		return
	end

	self.LastTextRefreshFlag = IsHint

	self:SetInputTextWidgetStyle(IsHint == true)
end

function CommSearchBarView:UpdateCancelBtnVisible(bVisible)
	if nil == bVisible then
		bVisible = self.BtnCancelAlwaysVisible or self.IsFocusReceived or  (#self:GetText() > 0)
	end

	UIUtil.SetIsVisible(self.BtnCancelNode, bVisible)
end

function CommSearchBarView:SetCursorToEnd( )
	self.TextInput:GoTo(TextLocationEndOfDocument)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

---@param Text string
function CommSearchBarView:OnTextChange(_, Text)
	local CurLen = CommonUtil.GetStrLen(Text)

	if self.MaxTextLength > 0 and CurLen > self.MaxTextLength then
		Text = CommonUtil.SubStr(Text, 1, self.MaxTextLength)

		self.TextInput:SetText(Text)
		return
	end

	if nil ~= self.ChangeCallback then
		self.ChangeCallback(self.View, Text, CurLen)
	end

	self:RefreshTextColorAndOpacity(CurLen <= 0)

	if not self.BtnCancelAlwaysVisible then
		self:UpdateCancelBtnVisible()
	end
end

---@param Text string
---@param CommitMethod ETextCommit
function CommSearchBarView:OnTextCommitted(_, Text, CommitMethod)
	FLOG_INFO("CommSearchBarView:OnTextCommitted, CommitMethod is %d.", CommitMethod)
	if CommitMethod ~= TextCommitOnEnter then
		return
	end
	
	if nil == self.CommittedCallback then
		FLOG_WARNING("CommSearchBarView:OnTextCommitted, CommittedCallback is nil")
		return
	end

	---查询文本是否合法（敏感词）
	_G.JudgeSearchMgr:QueryTextIsLegal(Text, function( IsLegal )
		if IsLegal then
			if nil ~= self.CommittedCallback then
				self.CommittedCallback(self.View, Text, CommitMethod)
			end
		else
			self:SetText("")
		end
	end, true, self.IllegalTipsText)

	---隐藏虚拟键盘扩展UI
	self:HideVirtualKeyboardExUI()
end

function CommSearchBarView:OnTextFocusReceived()
	self.IsFocusReceived = true
	self:UpdateCancelBtnVisible()

	---获取焦点时直接显示虚拟键盘扩展UI，无论是否已经显示
	_G.UIViewMgr:ShowVirtualKeyboardExUI(self,self.TextInput)
	self.IsShowVirtualKeyboardExUI = true
end

function CommSearchBarView:OnTextFocusLost()
	self.IsFocusReceived = false 
	self:UpdateCancelBtnVisible()

	---隐藏虚拟键盘扩展UI
	--self:HideVirtualKeyboardExUI()
end

function CommSearchBarView:OnClickButtonCancel( )
	self.TextInput:SetText("")

	if self.ClickCancelBtnCallback then
		self.ClickCancelBtnCallback(self.View)
	end

	self:UpdateCancelBtnVisible()
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack
function CommSearchBarView:OnEventShowVirtualKeyboard()
	if self.IsFocusReceived then
		---显示虚拟键盘扩展UI
		self:ShowVirtualKeyboardExUI()
	end
end

function CommSearchBarView:OnEventVirtualKeyboardReturn()
	if not CommonUtil.IsIOSPlatform() or not self.IsFocusReceived then
		return
	end

	self:OnTextCommitted(nil, self:GetText(), TextCommitOnEnter)
end

function CommSearchBarView:OnEventVirtualKeyboardHidden()
	self:SetCursorToEnd()
end

function CommSearchBarView:ShowVirtualKeyboardExUI()
	---显示虚拟键盘扩展UI
	if not self.IsShowVirtualKeyboardExUI then
		_G.UIViewMgr:ShowVirtualKeyboardExUI(self,self.TextInput)
		self.IsShowVirtualKeyboardExUI = true
	end
end
function CommSearchBarView:HideVirtualKeyboardExUI()
	---隐藏虚拟键盘扩展UI
	if self.IsShowVirtualKeyboardExUI then
		self.IsShowVirtualKeyboardExUI = false
		_G.UIViewMgr:HideVirtualKeyboardExUI()
	end
end
-------------------------------------------------------------------------------------------------------
---Public Interface 

function CommSearchBarView:SetTextMaxLength(Length)
	self.MaxTextLength = Length 
end

function CommSearchBarView:SetText(Text)
	if nil == Text then
		return
	end

	self.TextInput:SetText(Text)
end

function CommSearchBarView:GetText()
	return self.TextInput:GetText()
end

---设置搜索非法内容提示内容
function CommSearchBarView:SetIllegalTipsText(Text)
	self.IllegalTipsText = Text
end

function CommSearchBarView:SetCallback(View, ChangeCallback, CommittedCallback, ClickCancelBtnCallback)
	self.View = View
	self.ChangeCallback = ChangeCallback
	self.CommittedCallback = CommittedCallback
	self.ClickCancelBtnCallback = ClickCancelBtnCallback
end

function CommSearchBarView:SetFocus()
	self.TextInput:SetFocus()
end

--- 提交当前内容(用于自动化测试) 
function CommSearchBarView:TriggerOnEnterCommit()
	self:OnTextCommitted(nil, self:GetText(), TextCommitOnEnter)
end

return CommSearchBarView