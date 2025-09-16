---
--- Author: Administrator
--- DateTime: 2024-06-20 15:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIBinderSetBrushFromAssetPath = require("Binder/UIBinderSetBrushFromAssetPath")

---@class MysterMerchantSlotItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Icon UFImage
---@field ImgEmpty UFImage
---@field ImgQuanlity UFImage
---@field ImgSelect UFImage
---@field PanelInfo UFCanvasPanel
---@field RichTextQuantity URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MysterMerchantSlotItemView = LuaClass(UIView, true)

function MysterMerchantSlotItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Icon = nil
	--self.ImgEmpty = nil
	--self.ImgQuanlity = nil
	--self.ImgSelect = nil
	--self.PanelInfo = nil
	--self.RichTextQuantity = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MysterMerchantSlotItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MysterMerchantSlotItemView:OnInit()
    self.Binders = {
        {"ItemIcon", UIBinderSetBrushFromAssetPath.New(self, self.Icon)},
	}
end

function MysterMerchantSlotItemView:OnDestroy()

end

function MysterMerchantSlotItemView:OnShow()

end

function MysterMerchantSlotItemView:OnHide()

end

function MysterMerchantSlotItemView:OnRegisterUIEvent()

end

function MysterMerchantSlotItemView:OnRegisterGameEvent()

end

function MysterMerchantSlotItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
		return
	end

	self.ViewModel = Params.Data
	if nil == self.ViewModel then
		return
	end
	self:RegisterBinders(self.ViewModel, self.Binders)
end

return MysterMerchantSlotItemView