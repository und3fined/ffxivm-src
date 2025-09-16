---
--- Author: Administrator
--- DateTime: 2023-09-15 20:10
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local ResStartPath = "Texture2D'/Game/UI/Texture/Localized/chs/UI_Gate_Img_Start.UI_Gate_Img_Start'"

---@class GateCountDownItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgCountDown1 UFImage
---@field ImgCountDown2 UFImage
---@field ImgCountDown3 UFImage
---@field ImgStart UFImage
---@field AnimCountdown UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GateCountDownItemView = LuaClass(UIView, true)

function GateCountDownItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgCountDown1 = nil
	--self.ImgCountDown2 = nil
	--self.ImgCountDown3 = nil
	--self.ImgStart = nil
	--self.AnimCountdown = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GateCountDownItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GateCountDownItemView:OnInit()
	local FinalPath = LocalizationUtil.GetLocalizedAssetPath(ResStartPath)
    UIUtil.ImageSetBrushFromAssetPath(self.ImgStart, FinalPath)
end

function GateCountDownItemView:OnDestroy()

end

function GateCountDownItemView:OnShow()

end

function GateCountDownItemView:OnHide()

end

function GateCountDownItemView:OnRegisterUIEvent()

end

function GateCountDownItemView:OnRegisterGameEvent()

end

function GateCountDownItemView:OnRegisterBinder()

end

function GateCountDownItemView:PlayAnim()
	self:PlayAnimation(self.AnimCountdown)
end

return GateCountDownItemView