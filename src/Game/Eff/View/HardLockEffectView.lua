---
--- Author: henghaoli
--- DateTime: 2024-09-24 17:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class HardLockEffectView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Anchor UFCanvasPanel
---@field ImgHardLock1 UFImage
---@field ImgHardLock2 UFImage
---@field ImgHardLockLight1 UFImage
---@field ImgHardLockLight2 UFImage
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HardLockEffectView = LuaClass(UIView, true)

function HardLockEffectView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Anchor = nil
	--self.ImgHardLock1 = nil
	--self.ImgHardLock2 = nil
	--self.ImgHardLockLight1 = nil
	--self.ImgHardLockLight2 = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HardLockEffectView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HardLockEffectView:OnInit()
	self.bIsPlaying = false
	self.bHasMask = false
end

function HardLockEffectView:OnDestroy()

end

function HardLockEffectView:OnShow()
	UIUtil.SetIsVisible(self.Anchor, false)
end

function HardLockEffectView:OnHide()

end

function HardLockEffectView:OnRegisterUIEvent()

end

function HardLockEffectView:OnRegisterGameEvent()

end

function HardLockEffectView:OnRegisterBinder()

end

function HardLockEffectView:UpdateVisibility()
	UIUtil.SetIsVisible(self.Anchor, self.bIsPlaying and not self.bHasMask)
end

function HardLockEffectView:StartHardLockEffect()
	self.bIsPlaying = true
	self:UpdateVisibility()
	self:PlayAnimation(self.AnimLoop, 0, 0)
	return self.Anchor
end

function HardLockEffectView:EndHardLockEffect()
	self.bIsPlaying = false
	self:UpdateVisibility()
	self:StopAnimation(self.AnimLoop)
end

local ImagesToSetColor = { "ImgHardLockLight1", "ImgHardLockLight2" }
local FLinearColor = _G.UE.FLinearColor

function HardLockEffectView:SetColor(Color)
	local LinearColor = FLinearColor.FromHex(Color)
	for _, Img in pairs(ImagesToSetColor) do
		self[Img]:SetColorAndOpacity(LinearColor)
	end
end

function HardLockEffectView:UpdateMask(bHasMask)
	self.bHasMask = bHasMask
	self:UpdateVisibility()
end

function HardLockEffectView:GetAnimLoop()
end

return HardLockEffectView