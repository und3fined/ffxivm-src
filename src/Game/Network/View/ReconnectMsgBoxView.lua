---
--- Author: anypkvcai
--- DateTime: 2024-05-02 11:46
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")

---@class ReconnectMsgBoxView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnLeft CommBtnLView
---@field BtnRight CommBtnLView
---@field PopUpBG CommonPopUpBGView
---@field RichTextBoxTitle URichTextBox
---@field RichTextContent URichTextBox
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ReconnectMsgBoxView = LuaClass(UIView, true)

function ReconnectMsgBoxView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnLeft = nil
	--self.BtnRight = nil
	--self.PopUpBG = nil
	--self.RichTextBoxTitle = nil
	--self.RichTextContent = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ReconnectMsgBoxView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.BtnLeft)
	self:AddSubView(self.BtnRight)
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ReconnectMsgBoxView:OnInit()

end

function ReconnectMsgBoxView:OnDestroy()

end

function ReconnectMsgBoxView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Title = Params.Tile
	if nil ~= Title then
		self.RichTextBoxTitle:SetText(Title)
	else
		self.RichTextBoxTitle:SetText(_G.LSTR(1260049))  -- 提示
	end

	local Content = Params.Content
	if nil ~= Content then
		self.RichTextContent:SetText(Content)
	end

	local LeftText = Params.LeftText
	if nil ~= LeftText then
		self.BtnLeft:SetText(LeftText)
		UIUtil.SetIsVisible(self.BtnLeft, true, true)
	else
		UIUtil.SetIsVisible(self.BtnLeft, false)
	end

	local RightText = Params.RightText
	if nil ~= RightText then
		self.BtnRight:SetText(RightText)
		UIUtil.SetIsVisible(self.BtnRight, true, true)
	else
		UIUtil.SetIsVisible(self.BtnRight, false)
	end
end

function ReconnectMsgBoxView:OnHide(InParams)
	if InParams then
		return
	end

	-- 其他异常情况的关闭的回调
	local Params = self.Params
	if nil == Params then
		return
	end

	local Callback = Params.DefaultCallback

	if nil ~= Callback then
		CommonUtil.XPCall(Params.View, Callback)
	end
end

function ReconnectMsgBoxView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnLeft, self.OnClickBtnLeft)
	UIUtil.AddOnClickedEvent(self, self.BtnRight, self.OnClickBtnRight)
end

function ReconnectMsgBoxView:OnRegisterGameEvent()

end

function ReconnectMsgBoxView:OnRegisterBinder()

end

function ReconnectMsgBoxView:OnClickBtnLeft()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Callback = Params.LeftCallback

	if nil ~= Callback then
		CommonUtil.XPCall(Params.View, Callback)
	end

	_G.UIViewMgr:HideView(self.ViewID, false, true)
end

function ReconnectMsgBoxView:OnClickBtnRight()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Callback = Params.RightCallback

	if nil ~= Callback then
		CommonUtil.XPCall(Params.View, Callback)
	end

	_G.UIViewMgr:HideView(self.ViewID, false, true)
end

return ReconnectMsgBoxView