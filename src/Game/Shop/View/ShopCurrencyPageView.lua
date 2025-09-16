---
--- Author: erreetrtr
--- DateTime: 2023-02-02 14:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
--local UIUtil = require("Utils/UIUtil")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")


---@class ShopCurrencyPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewCurrency UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopCurrencyPageView = LuaClass(UIView, true)

function ShopCurrencyPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewCurrency = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopCurrencyPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopCurrencyPageView:OnInit()
	self.TableViewCurrencyAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewCurrency, nil, true)
	self.Binders =  {
		{"ShopCostItemVMs", UIBinderUpdateBindableList.New(self, self.TableViewCurrencyAdapter)},
	}
end

function ShopCurrencyPageView:OnDestroy()

end

function ShopCurrencyPageView:OnShow()

end

function ShopCurrencyPageView:OnHide()

end

function ShopCurrencyPageView:OnRegisterUIEvent()

end

function ShopCurrencyPageView:OnRegisterGameEvent()

end

function ShopCurrencyPageView:OnRegisterBinder()
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

return ShopCurrencyPageView