---
--- Author: yutingzhan
--- DateTime: 2025-05-27 15:22
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class BagTidyConsumptionItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommInforBtn_UIBP CommInforBtnView
---@field IconMoney1 UFImage
---@field IconMoney2 UFImage
---@field PanelMoney1 UFHorizontalBox
---@field PanelMoney2 UFHorizontalBox
---@field Text UFTextBlock
---@field TextMoney1 UFTextBlock
---@field TextMoney2 UFTextBlock
---@field TextUpperLimit UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local BagTidyConsumptionItemView = LuaClass(UIView, true)

function BagTidyConsumptionItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommInforBtn_UIBP = nil
	--self.IconMoney1 = nil
	--self.IconMoney2 = nil
	--self.PanelMoney1 = nil
	--self.PanelMoney2 = nil
	--self.Text = nil
	--self.TextMoney1 = nil
	--self.TextMoney2 = nil
	--self.TextUpperLimit = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function BagTidyConsumptionItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommInforBtn_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function BagTidyConsumptionItemView:OnInit()

end

function BagTidyConsumptionItemView:OnDestroy()

end

function BagTidyConsumptionItemView:OnShow()

end

function BagTidyConsumptionItemView:OnHide()

end

function BagTidyConsumptionItemView:OnRegisterUIEvent()

end

function BagTidyConsumptionItemView:OnRegisterGameEvent()

end

function BagTidyConsumptionItemView:OnRegisterBinder()

end

return BagTidyConsumptionItemView