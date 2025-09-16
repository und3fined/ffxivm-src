---
--- Author: v_vvxinchen
--- DateTime: 2025-01-17 17:16
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommLight126SlotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Btn UFButton
---@field Icon UFImage
---@field ImgBg UFImage
---@field ImgSelect UFImage
---@field RedDot CommonRedDotView
---@field RichTextNum URichTextBox
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommLight126SlotView = LuaClass(UIView, true)

function CommLight126SlotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Btn = nil
	--self.Icon = nil
	--self.ImgBg = nil
	--self.ImgSelect = nil
	--self.RedDot = nil
	--self.RichTextNum = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommLight126SlotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.RedDot)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommLight126SlotView:OnInit()

end

function CommLight126SlotView:OnDestroy()

end

function CommLight126SlotView:OnShow()

end

function CommLight126SlotView:OnHide()

end

function CommLight126SlotView:OnRegisterUIEvent()

end

function CommLight126SlotView:OnRegisterGameEvent()

end

function CommLight126SlotView:OnRegisterBinder()

end

return CommLight126SlotView