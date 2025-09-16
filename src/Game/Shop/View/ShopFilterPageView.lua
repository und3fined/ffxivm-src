---
--- Author: erreetrtr
--- DateTime: 2023-02-02 14:26
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
--local UIUtil = require("Utils/UIUtil")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
--local ShopVM = require("Game/Shop/ShopVM")

---@class ShopFilterPageView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TableViewConditions UTableView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShopFilterPageView = LuaClass(UIView, true)

function ShopFilterPageView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TableViewConditions = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShopFilterPageView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShopFilterPageView:OnInit()
	self.TableViewConditionsAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewConditions, nil, true)
	self.Binders =  {
		{"ShopFilterListVMs", UIBinderUpdateBindableList.New(self, self.TableViewConditionsAdapter)},
	}
end

function ShopFilterPageView:OnDestroy()

end

function ShopFilterPageView:OnShow()

end

function ShopFilterPageView:OnHide()

end

function ShopFilterPageView:OnRegisterUIEvent()

end

function ShopFilterPageView:OnRegisterGameEvent()

end

function ShopFilterPageView:OnRegisterBinder()
	if self.ViewModel == nil then
		return
	end


	self:RegisterBinders(self.ViewModel, self.Binders)
end

return ShopFilterPageView