---
--- Author: Administrator
--- DateTime: 2023-11-30 14:30
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetColorAndOpacityHex = require("Binder/UIBinderSetColorAndOpacityHex")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class BuddySurfaceColorItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnItem UFButton
---@field ImgCheck UFImage
---@field ImgColor UFImage
---@field ImgLock UFImage
---@field ImgSelect UFImage
---@field PanelInfo UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BuddySurfaceColorItemView = LuaClass(UIView, true)

function BuddySurfaceColorItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnItem = nil
	--self.ImgCheck = nil
	--self.ImgColor = nil
	--self.ImgLock = nil
	--self.ImgSelect = nil
	--self.PanelInfo = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BuddySurfaceColorItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BuddySurfaceColorItemView:OnInit()
	self.Binders = {
		{"ColorValue", UIBinderSetColorAndOpacityHex.New(self, self.ImgColor)},
        {"bIsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
        {"bIsDyed", UIBinderSetIsVisible.New(self, self.ImgCheck)},
        {"bIsLocked", UIBinderSetIsVisible.New(self, self.ImgLock)},
		{"IsValid",UIBinderSetIsVisible.New(self, self.PanelInfo)},
	}
end

function BuddySurfaceColorItemView:OnDestroy()

end

function BuddySurfaceColorItemView:OnShow()

end

function BuddySurfaceColorItemView:OnHide()

end

function BuddySurfaceColorItemView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnItem, self.OnClickButtonItem)
end

function BuddySurfaceColorItemView:OnRegisterGameEvent()
	
end

function BuddySurfaceColorItemView:OnRegisterBinder()
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

function BuddySurfaceColorItemView:OnClickButtonItem()
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

return BuddySurfaceColorItemView