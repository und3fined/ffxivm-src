---
--- Author: Administrator
--- DateTime: 2024-01-30 10:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsChecked = require("Binder/UIBinderSetIsChecked")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class PhotoRoleSettingItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnInfo UFButton
---@field PanelCheck UFCanvasPanel
---@field PanelTitle UFCanvasPanel
---@field SingleBox CommSingleBoxView
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PhotoRoleSettingItemView = LuaClass(UIView, true)

function PhotoRoleSettingItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnInfo = nil
	--self.PanelCheck = nil
	--self.PanelTitle = nil
	--self.SingleBox = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PhotoRoleSettingItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.SingleBox)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PhotoRoleSettingItemView:OnInit()
	self.Binder = 
	{
		{ "EnableAll", 			UIBinderSetIsChecked.New(self, self.SingleBox) },
		{ "Name", 				UIBinderSetText.New(self, self.SingleBox) },
		{ "IsShowCheckBox", 	UIBinderSetIsVisible.New(self, self.SingleBox.ToggleButton, nil, true) },
	}
end

function PhotoRoleSettingItemView:OnDestroy()

end

function PhotoRoleSettingItemView:OnShow()

end

function PhotoRoleSettingItemView:OnHide()

end

function PhotoRoleSettingItemView:OnRegisterUIEvent()
	UIUtil.AddOnStateChangedEvent(self, self.SingleBox, self.OnTogCheck)
end

function PhotoRoleSettingItemView:OnRegisterGameEvent()

end

function PhotoRoleSettingItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end
	
	local VM = Params.Data
	if nil == VM then
		return
	end
	self.ViewModel = VM

	self:RegisterBinders(VM, 				self.Binder)
end

function PhotoRoleSettingItemView:OnTogCheck(Tog, Stat)
	local IsChecked = UIUtil.IsToggleButtonChecked(Stat)
	self.ViewModel:SetEnableAll(IsChecked)
end


return PhotoRoleSettingItemView