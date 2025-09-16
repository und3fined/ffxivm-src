---
--- Author: jususchen
--- DateTime: 2024-12-13 19:19
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ShareInfoPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommPlayerHeadSlot_UIBP CommPlayerHeadSlotView
---@field IconJob UFImage
---@field ImgBG UFImage
---@field ImgQRCode UFImage
---@field TextLevel UFTextBlock
---@field TextName UFTextBlock
---@field TextPlatform UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ShareInfoPanelView = LuaClass(UIView, true)

function ShareInfoPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommPlayerHeadSlot_UIBP = nil
	--self.IconJob = nil
	--self.ImgBG = nil
	--self.ImgQRCode = nil
	--self.TextLevel = nil
	--self.TextName = nil
	--self.TextPlatform = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ShareInfoPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommPlayerHeadSlot_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ShareInfoPanelView:OnInit()

end

function ShareInfoPanelView:OnDestroy()

end

function ShareInfoPanelView:OnShow()

end

function ShareInfoPanelView:OnHide()

end

function ShareInfoPanelView:OnRegisterUIEvent()

end

function ShareInfoPanelView:OnRegisterGameEvent()

end

function ShareInfoPanelView:OnRegisterBinder()

end

return ShareInfoPanelView