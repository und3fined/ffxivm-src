---
--- Author: erreetrtr
--- DateTime: 2023-02-02 14:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
--local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class ShopSaleTagItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextTagContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopSaleTagItemView = LuaClass(UIView, true)

function ShopSaleTagItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextTagContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopSaleTagItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopSaleTagItemView:OnInit()
	self.Binders =  {
		{"Content", UIBinderSetText.New(self, self.TextTagContent)},
	}
end

function ShopSaleTagItemView:OnDestroy()

end

function ShopSaleTagItemView:OnShow()

end

function ShopSaleTagItemView:OnHide()

end

function ShopSaleTagItemView:OnRegisterUIEvent()

end

function ShopSaleTagItemView:OnRegisterGameEvent()

end

function ShopSaleTagItemView:OnRegisterBinder()
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

return ShopSaleTagItemView