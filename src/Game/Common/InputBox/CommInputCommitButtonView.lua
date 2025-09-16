---
--- Author: xingcaicao
--- DateTime: 2024-03-11 14:23
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local CommonUtil = require("Utils/CommonUtil")

local UCommonUtil = _G.UE.UCommonUtil
local ESystemTheme = _G.UE.ESystemTheme
local FVector2D = _G.UE.FVector2D
local LSTR = _G.LSTR

---@class CommInputCommitButtonView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field FBtnFinish UFButton
---@field FBtnMask UFButton
---@field ImgBg UFImage
---@field PanelContent UFCanvasPanel
---@field TextFinish UFTextBlock
---@field StyleType CommUIStyleType
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommInputCommitButtonView = LuaClass(UIView, true)

function CommInputCommitButtonView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BorderInput = nil
	--self.FBtnFinish = nil
	--self.FBtnMask = nil
	--self.ImgBg = nil
	--self.PanelContent = nil
	--self.TextFinish = nil
	--self.TextInput = nil
	--self.StyleType = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommInputCommitButtonView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommInputCommitButtonView:OnInit()

end

function CommInputCommitButtonView:OnDestroy()

end

function CommInputCommitButtonView:OnShow()
	self:RefreshUIStyle()
	self:AdjustContentPosition(128)
	self.TextFinish:SetText(LSTR(10002))
	self.IsAdjust = false
	local Params = self.Params
	if nil == Params then
		return
	end

	local TextInputInvoker = Params.TextInput
	if nil == TextInputInvoker then
		return
	end

	self.View = Params.View
	self.TextInputInvoker = TextInputInvoker
end

function CommInputCommitButtonView:OnHide()
	self.View = nil
	self.IsAdjust = false
end

function CommInputCommitButtonView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.FBtnMask, self.OnClickButtonMask)
	UIUtil.AddOnClickedEvent(self, self.FBtnFinish, self.OnClickButtonFinish)
end

function CommInputCommitButtonView:OnRegisterGameEvent()
	if CommonUtil.IsAndroidPlatform() then
		self:RegisterGameEvent(EventID.VirtualKeyboardShown, self.OnEventShowVirtualKeyboard)
		self:RegisterGameEvent(EventID.AppEnterBackground, self.OnEventAppEnterBackground)
	end
end

function CommInputCommitButtonView:OnRegisterBinder()

end

function CommInputCommitButtonView:OnRegisterTimer()

end

function CommInputCommitButtonView:AdjustContentPosition(KeyboardHeight)
	KeyboardHeight = (KeyboardHeight or 0) * -1

	local LocalPos = UIUtil.CanvasSlotGetPosition(self.PanelContent)
	local NewPos = FVector2D(LocalPos.X, KeyboardHeight)
	UIUtil.CanvasSlotSetPosition(self.PanelContent, NewPos)
end

function CommInputCommitButtonView:RefreshUIStyle()
	self:UpdateStyle(UCommonUtil.GetSystemTheme() ~= ESystemTheme.Dark)
end

-------------------------------------------------------------------------------------------------------
---Client Event CallBack 
function CommInputCommitButtonView:OnEventShowVirtualKeyboard(KeyboardHeight)
	if KeyboardHeight <= 0 and not self.IsAdjust then
		return
	end
	if KeyboardHeight > 0 then
		self.IsAdjust = true
	else
		--android 有个默认白条高128
		KeyboardHeight = 128
	end
	-- 调整内容高度
	self:AdjustContentPosition(KeyboardHeight)
	
end

function CommInputCommitButtonView:OnEventAppEnterBackground()
	self.IsAdjust = false
	-- Fixed: 安卓机切换后台后，虚拟键盘会关闭
	self:Hide()
end

-------------------------------------------------------------------------------------------------------
---Component CallBack

function CommInputCommitButtonView:OnClickButtonMask()
	--self:OnClickButtonFinish()
	self.IsAdjust = false
	self:Hide()
end

function CommInputCommitButtonView:OnClickButtonFinish()
	local View = self.View
	if View and View.OnTextCommitted and self.TextInputInvoker then
		local Text = self.TextInputInvoker:GetText()
		View:OnTextCommitted(nil, Text, _G.UE.ETextCommit.OnEnter)
	end
	self.IsAdjust = false
	self:Hide()
end

return CommInputCommitButtonView