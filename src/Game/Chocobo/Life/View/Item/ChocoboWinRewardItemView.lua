---
--- Author: Administrator
--- DateTime: 2024-01-10 19:07
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

---@class ChocoboWinRewardItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field CommSlot CommBackpackSlotView
---@field ImgGet UFImage
---@field ImgMask UFImage
---@field PanelMask UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ChocoboWinRewardItemView = LuaClass(UIView, true)

function ChocoboWinRewardItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.CommSlot = nil
	--self.ImgGet = nil
	--self.ImgMask = nil
	--self.PanelMask = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ChocoboWinRewardItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.CommSlot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ChocoboWinRewardItemView:OnInit()

end

function ChocoboWinRewardItemView:OnDestroy()

end

function ChocoboWinRewardItemView:OnShow()

end

function ChocoboWinRewardItemView:OnHide()

end

function ChocoboWinRewardItemView:OnRegisterUIEvent()

end

function ChocoboWinRewardItemView:OnRegisterGameEvent()

end

function ChocoboWinRewardItemView:OnRegisterBinder()

end

return ChocoboWinRewardItemView