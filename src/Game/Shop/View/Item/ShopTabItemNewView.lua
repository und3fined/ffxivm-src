---
--- Author: Administrator
--- DateTime: 2023-10-13 15:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

---@class ShopTabItemNewView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTab UFButton
---@field ImgSelect UFImage
---@field TabPanel UFCanvasPanel
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopTabItemNewView = LuaClass(UIView, true)

function ShopTabItemNewView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTab = nil
	--self.ImgSelect = nil
	--self.TabPanel = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopTabItemNewView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopTabItemNewView:OnInit()
	self.Binders = {
        {"TabName", UIBinderSetText.New(self, self.TextName)},
        {"IsSelected", UIBinderSetIsVisible.New(self, self.ImgSelect)},
    }
end

function ShopTabItemNewView:OnDestroy()

end

function ShopTabItemNewView:OnShow()

end

function ShopTabItemNewView:OnHide()

end

function ShopTabItemNewView:OnRegisterUIEvent()

end

function ShopTabItemNewView:OnRegisterGameEvent()
end

function ShopTabItemNewView:OnSelectChanged(NewValue)
	local Color = ""
	if NewValue then
		Color = "#FFF4d0FF"
	else
		Color = "#828282FF"
	end
	UIUtil.SetColorAndOpacityHex(self.TextName,Color)
	UIUtil.SetIsVisible(self.ImgSelect, NewValue)
	if NewValue then
		self:PlayAnimation(self.AnimChecked)
	else
		self:PlayAnimation(self.AnimUnchecked)
	end
end

function ShopTabItemNewView:OnRegisterBinder()
	local Params = self.Params
    if nil == Params then
        return
    end

    local ViewModel = Params.Data
    if nil == ViewModel then
        return
    end

    self:RegisterBinders(ViewModel, self.Binders)
end

return ShopTabItemNewView