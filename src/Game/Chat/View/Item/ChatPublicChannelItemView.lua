---
--- Author: xingcaicao
--- DateTime: 2023-09-05 19:49
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local ChatVM = require("Game/Chat/ChatVM")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local NormalColor = "#878075FF"
local SelectColor = "#FFF4D0FF"

---@class ChatPublicChannelItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ComRedDot CommonRedDotView
---@field FImgIcon UFImage
---@field Spacer USpacer
---@field TextName UFTextBlock
---@field AnimSelectIn UWidgetAnimation
---@field AnimSelectOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChatPublicChannelItemView = LuaClass(UIView, true)

function ChatPublicChannelItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ComRedDot = nil
	--self.FImgIcon = nil
	--self.Spacer = nil
	--self.TextName = nil
	--self.AnimSelectIn = nil
	--self.AnimSelectOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChatPublicChannelItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.ComRedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChatPublicChannelItemView:OnInit()
	self.ComRedDot:SetIsCustomizeRedDot(true)

	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextName) },
	}

	self.BindersChannelVM = {
		{ "IsRedDotVisible", UIBinderValueChangedCallback.New(self, nil, self.OnValueChangedRedDotVisible) },
	}

	self.BindersChatVM = {
		{ "IsWideMainWin", UIBinderSetIsVisible.New(self, self.TextName) },
		{ "IsWideMainWin", UIBinderSetIsVisible.New(self, self.Spacer, true) },
	}
end

function ChatPublicChannelItemView:OnDestroy()

end

function ChatPublicChannelItemView:OnShow()

end

function ChatPublicChannelItemView:OnHide()
end

function ChatPublicChannelItemView:OnRegisterUIEvent()

end

function ChatPublicChannelItemView:OnRegisterGameEvent()

end

function ChatPublicChannelItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Data = Params.Data
	if nil == Data then
		return
	end

	local ViewModel = Data
	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)

	local ChannelVM = ChatVM:FindChannelVM(Data.Channel, Data.ChannelID)
	if ChannelVM ~= nil then
		self:RegisterBinders(ChannelVM, self.BindersChannelVM)
	end

	self:RegisterBinders(ChatVM, self.BindersChatVM)
end

function ChatPublicChannelItemView:StopCurAnim()
	local Anim = self.CurAnim
	if Anim then
		self:StopAnimation(Anim)
	end
end

function ChatPublicChannelItemView:OnValueChangedRedDotVisible(IsVisible)
	self.ComRedDot:SetRedDotUIIsShow(IsVisible)
end

function ChatPublicChannelItemView:OnSelectChanged(IsSelected)
	local ViewModel = self.ViewModel
	if nil == ViewModel then
		return
	end

	-- 名字颜色
	local TextName = self.TextName 
	if IsSelected then
		UIUtil.SetColorAndOpacityHex(TextName, SelectColor)
		UIUtil.TextBlockSetOutlineSize(TextName, 2)

	else
		UIUtil.SetColorAndOpacityHex(TextName, NormalColor)
		UIUtil.TextBlockSetOutlineSize(TextName, 0)
	end

	-- 图标
	local Icon = IsSelected and ViewModel.IconSelect or ViewModel.Icon
	if UIUtil.ImageSetBrushFromAssetPath(self.FImgIcon, Icon, false, true, true) then
		UIUtil.SetIsVisible(self.FImgIcon, true)
	end

	-- 动效
	self:StopCurAnim()

	local Anim = IsSelected and self.AnimSelectIn or self.AnimSelectOut
	self.CurAnim = Anim 
	self:PlayAnimation(Anim)
end

return ChatPublicChannelItemView