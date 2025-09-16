---
--- Author: v_zanchang
--- DateTime: 2022-08-26 15:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class Main2ndBarItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BarItem UFButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local Main2ndBarItemView = LuaClass(UIView, true)

function Main2ndBarItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BarItem = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function Main2ndBarItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function Main2ndBarItemView:OnInit()

end

function Main2ndBarItemView:OnDestroy()

end

function Main2ndBarItemView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end
	local Item = Params.Data
	-- self.BarItem:Set
	UIUtil.ButtonSetBrush(self.BarItem, Item.BarItem)
end

function Main2ndBarItemView:OnHide()

end

function Main2ndBarItemView:OnRegisterUIEvent()

end

function Main2ndBarItemView:OnRegisterGameEvent()

end

function Main2ndBarItemView:OnRegisterBinder()

end

return Main2ndBarItemView