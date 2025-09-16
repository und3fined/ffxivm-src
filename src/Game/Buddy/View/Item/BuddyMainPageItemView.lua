---
--- Author: Administrator
--- DateTime: 2023-11-13 16:35
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")
local UIBinderSetCheckedState = require("Binder/UIBinderSetCheckedState")
local BuddyMainVM = require("Game/Buddy/VM/BuddyMainVM")
local RedDotDefine = require("Game/CommonRedDot/RedDotDefine")

---@class BuddyMainPageItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgIconOff UFImage
---@field ImgIconOn UFImage
---@field ImgSelect UFImage
---@field RedDot2 CommonRedDot2View
---@field TabItem UToggleButton
---@field AnimSelect UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddyMainPageItemView = LuaClass(UIView, true)

function BuddyMainPageItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgIconOff = nil
	--self.ImgIconOn = nil
	--self.ImgSelect = nil
	--self.RedDot2 = nil
	--self.TabItem = nil
	--self.AnimSelect = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddyMainPageItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot2)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddyMainPageItemView:OnInit()
	self.Binders = {
		{ "OffIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIconOff) },
		{ "OnIcon", UIBinderSetBrushFromAssetPath.New(self, self.ImgIconOn) },
		{ "IconState", UIBinderSetCheckedState.New(self, self.TabItem) },
	}
end

function BuddyMainPageItemView:OnDestroy()

end

function BuddyMainPageItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = Params.Data

	if ViewModel.Index == BuddyMainVM.MenuType.Ability then
		self.RedDot2:SetRedDotNameByString(_G.BuddyMgr:GetBuddyUpLevelRedDotName())
	end

end

function BuddyMainPageItemView:OnHide()

end

function BuddyMainPageItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.TabItem, self.OnClickButtonItem)
end

function BuddyMainPageItemView:OnRegisterGameEvent()

end

function BuddyMainPageItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	local ViewModel = self.Params.Data
	if nil == ViewModel then
		return
	end

	self:RegisterBinders(ViewModel, self.Binders)
end

function BuddyMainPageItemView:OnClickButtonItem()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Adapter = Params.Adapter
	if nil == Adapter then
		return
	end

	Adapter:OnItemClicked(self, Params.Index)
end

return BuddyMainPageItemView