---
--- Author: Administrator
--- DateTime: 2025-07-31 14:56
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class NightGiftHorTabItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnItem UFButton
---@field ImgBtnSelect UFImage
---@field ImgLock UFImage
---@field RedDot CommonRedDotView
---@field TextTabName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NightGiftHorTabItemView = LuaClass(UIView, true)

function NightGiftHorTabItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnItem = nil
	--self.ImgBtnSelect = nil
	--self.ImgLock = nil
	--self.RedDot = nil
	--self.TextTabName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NightGiftHorTabItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NightGiftHorTabItemView:OnInit()

end

function NightGiftHorTabItemView:OnDestroy()

end

function NightGiftHorTabItemView:OnShow()

end

function NightGiftHorTabItemView:OnHide()

end

function NightGiftHorTabItemView:OnRegisterUIEvent()

end

function NightGiftHorTabItemView:OnRegisterGameEvent()

end

function NightGiftHorTabItemView:OnRegisterBinder()

end

return NightGiftHorTabItemView