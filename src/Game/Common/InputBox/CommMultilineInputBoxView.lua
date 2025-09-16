---
--- Author: xingcaicao
--- DateTime: 2023-03-06 10:59
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")

local LSTR = _G.LSTR
local LIMIT_TIPS_INTERVAL = 3

---@class CommMultilineInputBoxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BgPanel UFCanvasPanel
---@field FImageBgDark UFImage
---@field FImageBgLight UFImage
---@field FMultiLineInputText UFMultiLineEditableText
---@field RichTextNumber URichTextBox
---@field MaxNum int
---@field HintText text
---@field EnableLineBreak bool
---@field NumberColor LinearColor
---@field HintTextColor SlateColor
---@field HintTextColorOpacity float
---@field PreviewHintTextColor bool
---@field InputTextColor SlateColor
---@field IsHideNumber bool
---@field IsShowImgBg bool
---@field LineSpacing float
---@field StyleType CommUIStyleType
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommMultilineInputBoxView = LuaClass(UIView, true)

function CommMultilineInputBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BgPanel = nil
	--self.FImageBgDark = nil
	--self.FImageBgLight = nil
	--self.FMultiLineInputText = nil
	--self.RichTextNumber = nil
	--self.MaxNum = nil
	--self.HintText = nil
	--self.EnableLineBreak = nil
	--self.NumberColor = nil
	--self.HintTextColor = nil
	--self.HintTextColorOpacity = nil
	--self.PreviewHintTextColor = nil
	--self.InputTextColor = nil
	--self.IsHideNumber = nil
	--self.IsShowImgBg = nil
	--self.LineSpacing = nil
	--self.StyleType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommMultilineInputBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommMultilineInputBoxView:OnInit()
	-- 给美术预览文本颜色使用，为以防其忘了取消开关，此处强制取消
	self.PreviewHintTextColor = false
	-- 默认提示文本，10001("请点击输入")
	self:SetHintText(LSTR(10001))
end

function CommMultilineInputBoxView:OnDestroy()

end

function CommMultilineInputBoxView:OnShow()
	self:RefreshTextColorAndOpacity(#self:GetText() <= 0)
	self:UpdateDescText()
end

function CommMultilineInputBoxView:OnHide()
	self.LastTextRefreshFlag = nil 
	self.LastOverLimitTipsTime = nil 
end

function CommMultilineInputBoxView:OnRegisterUIEvent()
	UIUtil.AddOnTextChangedEvent(self, self.FMultiLineInputText, self.OnTextChangedInput)
	UIUtil.AddOnTextCommittedEvent(self, self.FMultiLineInputText, self.OnTextCommitted)
end

function CommMultilineInputBoxView:OnRegisterGameEvent()

end

function CommMultilineInputBoxView:OnRegisterBinder()

end

function CommMultilineInputBoxView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, LIMIT_TIPS_INTERVAL, 0)
end

function CommMultilineInputBoxView:OnTimer()
	self:CheckTextOverLimit(nil, true)
end

function CommMultilineInputBoxView:UpdateDescText(CurLen)
	CurLen = CurLen or CommonUtil.GetStrLen(self:GetText())

	local IsOverLimit = not self.IsHideNumber and CurLen > self.MaxNum
	local Fmt = IsOverLimit and '<span color="#DC5868FF">%s</>/%s' or "%s/%s"
	local Desc = string.format(Fmt, CurLen, self.MaxNum or 0)
	self.RichTextNumber:SetText(Desc)
end

function CommMultilineInputBoxView:RefreshTextColorAndOpacity(IsHint)
	IsHint = IsHint == true

	if IsHint == self.LastTextRefreshFlag then
		return
	end

	self.LastTextRefreshFlag = IsHint

	self:SetInputTextWidgetStyle(IsHint == true)
end

function CommMultilineInputBoxView:CheckTextOverLimit(Text, IsShowTips)
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
-------------------------------------------------------------------------------------------------------
---Component CallBack

function CommMultilineInputBoxView:OnTextChangedInput(_, Text)
	local NewText = CommonUtil.RemoveSpecialChars(Text)
	if NewText ~= Text then
		self:SetText(NewText)
		return
	end

	--if self.EnableLineBreak then -- 去除换行
	local TempText, Num = string.gsub(Text, "[\n\r\t]", "")
	if Num > 0 then
		self:SetText(TempText)
		return
	end
	--end

	local CurLen = CommonUtil.GetStrLen(Text)

	self:UpdateDescText(CurLen)
	self:RefreshTextColorAndOpacity(CurLen <= 0)
	self:CheckTextOverLimit(Text, true)
	
	if nil ~= self.ChangeCallback then
		self.ChangeCallback(self.View, Text)
	end
end

function CommMultilineInputBoxView:OnTextCommitted(_, Text, CommitMethod)
	if self:CheckTextOverLimit() then
		Text = CommonUtil.SubStr(Text, 1, self.MaxNum)
		self:SetText(Text)
	end

	if nil ~= self.CommittedCallback then
		self.CommittedCallback(self.View, Text, CommitMethod)
	end
end

-------------------------------------------------------------------------------------------------------
---Public Interface 

function CommMultilineInputBoxView:SetCallback(View, ChangeCallback, CommittedCallback)
	self.View = View
	self.ChangeCallback = ChangeCallback
	self.CommittedCallback = CommittedCallback
end

--- 设置输入框文字
---@param Text string @设置输入框的文字
function CommMultilineInputBoxView:SetText(Text)
	if nil == Text then
		return
	end

	self.FMultiLineInputText:SetText(Text)
end

--- 获取输入框的文字
---@return string @输入框的文字
function CommMultilineInputBoxView:GetText()
	return self.FMultiLineInputText:GetText()
end

-- 更新最大字符数量
---@param Num number @最大字符数量
function CommMultilineInputBoxView:SetMaxNum(num)
	if nil == num or num < 0 then
		num = 0
	end

	self.MaxNum = num 
	self:UpdateDescText()
end

---是否显示字数统计
---@param Value Bool 
function CommMultilineInputBoxView:SetIsHideNumber(Value)
	self.IsHideNumber = Value
	UIUtil.SetIsVisible(self.RichTextNumber, not Value)
end

---设置输入文本是否为只读
function CommMultilineInputBoxView:SetIsReadOnly(b)
	self.FMultiLineInputText:SetIsReadOnly(b)
end

--- 是否可用
function CommMultilineInputBoxView:SetIsEnabled(Enabled)
	self.FMultiLineInputText:SetIsEnabled(Enabled)
end

--- 是否去除换行
function CommMultilineInputBoxView:SetIsEnableLineBreak(b)
	self.EnableLineBreak = b == true
end

return CommMultilineInputBoxView