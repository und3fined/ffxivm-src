---
--- Author: Administrator
--- DateTime: 2023-12-05 11:05
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class NewWeatherTimeItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextTime UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NewWeatherTimeItemView = LuaClass(UIView, true)

function NewWeatherTimeItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextTime = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NewWeatherTimeItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NewWeatherTimeItemView:OnInit()

end

function NewWeatherTimeItemView:OnDestroy()

end

function NewWeatherTimeItemView:OnShow()

end

function NewWeatherTimeItemView:OnHide()

end

function NewWeatherTimeItemView:OnRegisterUIEvent()

end

function NewWeatherTimeItemView:OnRegisterGameEvent()

end

function NewWeatherTimeItemView:OnRegisterBinder()

end

function NewWeatherTimeItemView:SetTime(V)
	self.TextTime:SetText(V)
end

return NewWeatherTimeItemView