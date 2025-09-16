---
--- Author: wallencai
--- DateTime: 2022-08-09 15:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local EventID = require("Define/EventID")

local LSTR = _G.LSTR
local LIMIT_TIPS_INTERVAL = 3

local TextCommitOnEnter = _G.UE.ETextCommit.OnEnter
local TextLocationEndOfDocument = _G.UE.ETextLocation.EndOfDocument

---@class CommInputBoxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BgPanel UFCanvasPanel
---@field FImageBgDark UFImage
---@field FImageBgLight UFImage
---@field InputText UEditableText
---@field RichTextNumber URichTextBox
---@field MaxNum int
---@field HintText text
---@field NumberColor LinearColor
---@field HintTextColor SlateColor
---@field HintTextColorOpacity float
---@field PreviewHintTextColor bool
---@field InputTextColor SlateColor
---@field IsHideNumber bool
---@field IsShowImgBg bool
---@field StyleType CommUIStyleType
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommInputBoxView = LuaClass(UIView, true)

function CommInputBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BgPanel = nil
	--self.FImageBgDark = nil
	--self.FImageBgLight = nil
	--self.InputText = nil
	--self.RichTextNumber = nil
	--self.MaxNum = nil
	--self.HintText = nil
	--self.NumberColor = nil
	--self.HintTextColor = nil
	--self.HintTextColorOpacity = nil
	--self.PreviewHintTextColor = nil
	--self.InputTextColor = nil
	--self.IsHideNumber = nil
	--self.IsShowImgBg = nil
	--self.StyleType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommInputBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommInputBoxView:OnInit()
	-- 给美术预览文本颜色使用，为以防其忘了取消开关，此处强制取消
	self.PreviewHintTextColor = false

	-- 默认提示文本，10001("请点击输入")
	self:SetHintText(LSTR(10001))
end

function CommInputBoxView:OnDestroy()

end

function CommInputBoxView:OnShow()
	self.IsFocusReceived = false
	self:RefreshTextColorAndOpacity(#self:GetText() <= 0)
	self:UpdateDescText()
end

function CommInputBoxView:OnHide()
	self.LastTextRefreshFlag = nil 
	self.LastOverLimitTipsTime = nil 
end

function CommInputBoxView:OnRegisterUIEvent()
	UIUtil.AddOnTextChangedEvent(self, self.InputText, self.OnTextChangedInput)
	UIUtil.AddOnTextCommittedEvent(self, self.InputText, self.OnTextCommitted)
	UIUtil.AddOnFocusReceivedEvent(self, self.InputText, self.OnTextFocusReceived)
	UIUtil.AddOnFocusLostEvent(self, self.InputText, self.OnTextFocusLost)
end

function CommInputBoxView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.VirtualKeyboardReturn, self.OnEventVirtualKeyboardReturn)

	if CommonUtil.IsIOSPlatform() then
		self:RegisterGameEvent(EventID.VirtualKeyboardHidden, self.OnEventVirtualKeyboardHidden)
	end
end

function CommInputBoxView:OnRegisterBinder()

end

function CommInputBoxView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, LIMIT_TIPS_INTERVAL, 0)
end

function CommInputBoxView:OnTimer()
	self:CheckTextOverLimit(nil, true)
end

function CommInputBoxView:UpdateDescText(CurLen)
	CurLen = CurLen or CommonUtil.GetStrLen(self:GetText())

	local IsOverLimit = not self.IsHideNumber and CurLen > self.MaxNum
	local Fmt = IsOverLimit and '<span color="#DC5868FF">%s</>/%s' or "%s/%s"
	local Desc = string.format(Fmt, CurLen, self.MaxNum or 0)
	self.RichTextNumber:SetText(Desc)
end

function CommInputBoxView:RefreshTextColorAndOpacity(IsHint)
	IsHint = IsHint == true

	if IsHint == self.LastTextRefreshFlag then
		return
	end

	self.LastTextRefreshFlag = IsHint
	self:SetInputTextWidgetStyle(IsHint == true)
end

function CommInputBoxView:CheckTextOverLimit(Text, IsShowTips)
	if self.IsHideNumber then
		return false
	end

	Text = Text or self:GetText()
	local CurLen = CommonUtil.GetStrLen(Text)
	if CurLen <= self.MaxNum then
		return false
	end

	if IsShowTips then
		local CurTime = os.time() 
		local LastTime = self.LastOverLimitTipsTime or 0
		if CurTime - LastTime > LIMIT_TIPS_INTERVAL then
			self.LastOverLimitTipsTime = CurTime

			MsgTipsUtil.ShowErrorTips(LSTR(10045)) -- "超出字数限制"
		end
	end

	return true
end

function CommInputBoxView:SetCursorToEnd( )
	self.InputText:GoTo(TextLocationEndOfDocument)
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function CommInputBoxView:OnTextChangedInput(_, Text)
	local NewText = CommonUtil.RemoveSpecialChars(Text)
	if NewText ~= Text then
		self:SetText(NewText)
		return
	end
	-- 去除换行
	local TempText, Num = string.gsub(Text, "[\n\r\t]", "")
	if Num > 0 then
		self:SetText(TempText)
		return
	end

	local CurLen = CommonUtil.GetStrLen(Text)

	self:UpdateDescText(CurLen)
	self:RefreshTextColorAndOpacity(CurLen <= 0)
	self:CheckTextOverLimit(Text, true)

	if nil ~= self.ChangeCallback then
		self.ChangeCallback(self.View, Text, CurLen)
	end
end

function CommInputBoxView:OnTextCommitted(_, Text, CommitMethod)
	if self:CheckTextOverLimit() then
		Text = CommonUtil.SubStr(Text, 1, self.MaxNum)
		self:SetText(Text)
	end

	if nil ~= self.CommittedCallback then
		self.CommittedCallback(self.View, Text, CommitMethod)
	end
end

function CommInputBoxView:OnTextFocusReceived()
	self.IsFocusReceived = true
end

function CommInputBoxView:OnTextFocusLost()
	self.IsFocusReceived = false 
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 

function CommInputBoxView:OnEventVirtualKeyboardReturn()
	if not CommonUtil.IsIOSPlatform() or not self.IsFocusReceived then
		return
	end

	self:OnTextCommitted(nil, self:GetText(), TextCommitOnEnter)
end

function CommInputBoxView:OnEventVirtualKeyboardHidden()
	self:SetCursorToEnd()
end

-------------------------------------------------------------------------------------------------------
---Public Interface 

function CommInputBoxView:SetCallback(View, ChangeCallback, CommittedCallback)
	self.View = View
	self.ChangeCallback = ChangeCallback
	self.CommittedCallback = CommittedCallback
end

---设置输入框文字
---@param Text string @设置输入框的文字
function CommInputBoxView:SetText(Text)
	if nil == Text then
		return
	end

	self.InputText:SetText(Text)
end

---获取输入框文字
---@return string
function CommInputBoxView:GetText()
	return self.InputText:GetText()
end

---更新最大字符数量
---@param Num number @最大字符数量
function CommInputBoxView:SetMaxNum(num)
	if nil == num or num < 0 then
		num = 0
	end

	self.MaxNum = num 
	self:UpdateDescText()
end

---是否显示字数统计
---@param Value Bool 
function CommInputBoxView:SetIsHideNumber(Value)
	self.IsHideNumber = Value
	UIUtil.SetIsVisible(self.RichTextNumber, not Value)
end

---设置输入文本为只读
function CommInputBoxView:SetIsReadOnly(b)
	self.InputText:SetIsReadOnly(b)
end

--- 提交当前内容(用于自动化测试) 
function CommInputBoxView:TriggerOnEnterCommit()
	self:OnTextCommitted(nil, self:GetText(), TextCommitOnEnter)
end

--- 是否可用
function CommInputBoxView:SetIsEnabled(Enabled)
	self.InputText:SetIsEnabled(Enabled)
end

function CommInputBoxView:SetFocus()
	self.InputText:SetFocus()
end

return CommInputBoxView