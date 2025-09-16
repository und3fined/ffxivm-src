---
--- Author: v_zanchang
--- DateTime: 2023-04-17 14:17
--- Description:
---
--- 已弃用
local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
-- local UIUtil = require("Utils/UIUtil")
local UIBinderSetText = require("Binder/UIBinderSetText")

---@class EquipmentCurrencyTitleItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextCurrencyTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local EquipmentCurrencyTitleItemView = LuaClass(UIView, true)

function EquipmentCurrencyTitleItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextCurrencyTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function EquipmentCurrencyTitleItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function EquipmentCurrencyTitleItemView:OnInit()

end

function EquipmentCurrencyTitleItemView:OnDestroy()

end

function EquipmentCurrencyTitleItemView:OnShow()

end

function EquipmentCurrencyTitleItemView:OnHide()

end

function EquipmentCurrencyTitleItemView:OnRegisterUIEvent()

end

function EquipmentCurrencyTitleItemView:OnRegisterGameEvent()

end

function EquipmentCurrencyTitleItemView:OnRegisterBinder()
	local Params = self.Params
	if nil == Params then
	   return
	end

	local Data = Params.Data
	if nil == Data then
	   return
	end

	local ViewModel = Params.Data

	self.ViewModel = ViewModel

    local Binders = {
        { "CurrencyTitle", UIBinderSetText.New(self, self.TextCurrencyTitle) },
    }

    self:RegisterBinders(self.ViewModel, Binders)

end

return EquipmentCurrencyTitleItemView