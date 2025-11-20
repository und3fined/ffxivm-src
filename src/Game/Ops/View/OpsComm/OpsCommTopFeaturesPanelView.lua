local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class OpsCommTopFeaturesPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnVideo UFButton
---@field OpsMoneySlot OpsCommMoneySlotView
---@field ShareTips OpsActivityShareTipsItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local OpsCommTopFeaturesPanelView = LuaClass(UIView, true)

function OpsCommTopFeaturesPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnVideo = nil
	--self.OpsMoneySlot = nil
	--self.ShareTips = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function OpsCommTopFeaturesPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.OpsMoneySlot)
	self:AddSubView(self.ShareTips)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function OpsCommTopFeaturesPanelView:OnInit()

end

function OpsCommTopFeaturesPanelView:OnDestroy()

end

function OpsCommTopFeaturesPanelView:OnShow()

end

function OpsCommTopFeaturesPanelView:OnHide()

end

function OpsCommTopFeaturesPanelView:OnRegisterUIEvent()

end

function OpsCommTopFeaturesPanelView:OnRegisterGameEvent()

end

function OpsCommTopFeaturesPanelView:OnRegisterBinder()

end

return OpsCommTopFeaturesPanelView