---
--- Author: loiafeng
--- DateTime: 2023-03-28 09:37
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderValueChangedCallback = require("Binder/UIBinderValueChangedCallback")
local OnlineStatusUtil = require("Game/OnlineStatus/OnlineStatusUtil")

local ProtoRes = require("Protocol/ProtoRes")
local OnlineStatusIdentify = ProtoRes.OnlineStatusIdentify 

---@class OnlineStatusSettingItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgStatusAble UFImage
---@field TextContent UFTextBlock
---@field ToggleButtonItem UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OnlineStatusSettingItemView = LuaClass(UIView, true)

function OnlineStatusSettingItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgStatusAble = nil
	--self.TextContent = nil
	--self.ToggleButtonItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OnlineStatusSettingItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OnlineStatusSettingItemView:OnInit()
	self.Binders = {
		{ "Name", UIBinderSetText.New(self, self.TextContent) },
		{ "Icon", UIBinderSetBrushFromAssetPath.New(self, self.ImgStatusAble) },
		{ "IsSelected", UIBinderValueChangedCallback.New(self, nil, self.OnItemStyleChanged) },
		{ "IdentityID", UIBinderValueChangedCallback.New(self, nil, self.OnItemStyleChanged) },
	}
end

function OnlineStatusSettingItemView:OnDestroy()

end

function OnlineStatusSettingItemView:OnShow()
	-- 不需要ToggleButton来响应点击事件
	UIUtil.SetIsVisible(self.ToggleButtonItem, true, false)
end

function OnlineStatusSettingItemView:OnHide()

end

function OnlineStatusSettingItemView:OnRegisterUIEvent()

end

function OnlineStatusSettingItemView:OnRegisterGameEvent()

end

function OnlineStatusSettingItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
	   return
	end

	local ViewModel = Params.Data
	if nil == ViewModel then
	   return
	end

	self.ViewModel = ViewModel
	self:RegisterBinders(ViewModel, self.Binders)
end

function OnlineStatusSettingItemView:OnItemStyleChanged()
	if self.ViewModel == nil then
		self.ToggleButtonItem:SetChecked(false)
		UIUtil.SetColorAndOpacityHex(self.TextContent, "FFFFFFFF")
	end

	-- 对未认证的状态进行锁定
	local IdentityID = self.ViewModel.IdentityID
	if ( IdentityID == OnlineStatusIdentify.OnlineStatusIdentifyUnverifiedMentor
	 or IdentityID == OnlineStatusIdentify.OnlineStatusIdentifyUnverifiedBattleMentor
	 or IdentityID == OnlineStatusIdentify.OnlineStatusIdentifyUnverifiedMakeMentor ) then
		self.ToggleButtonItem:SetCheckedState(_G.UE.EToggleButtonState.Locked)
		UIUtil.SetColorAndOpacityHex(self.TextContent, "828282FF")
	else
		self.ToggleButtonItem:SetChecked(self.ViewModel.IsSelected)
		UIUtil.SetColorAndOpacityHex(self.TextContent, "FFFFFFFF")
	end
end

return OnlineStatusSettingItemView