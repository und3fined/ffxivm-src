---
--- Author: Administrator
--- DateTime: 2024-10-12 14:43
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class CommonSecondRedDotView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelRedDot UFCanvasPanel
---@field TextNewYellow1 UFTextBlock
---@field RedDotID int
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local CommonSecondRedDotView = LuaClass(UIView, true)

function CommonSecondRedDotView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelRedDot = nil
	--self.TextNewYellow1 = nil
	--self.RedDotID = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function CommonSecondRedDotView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function CommonSecondRedDotView:OnInit()
	-- 在OnInit设置，防止覆盖SetText进来的文本
	-- LSTR string:新
	self.TextNewYellow1:SetText(LSTR(1220001))
end

function CommonSecondRedDotView:OnDestroy()

end

function CommonSecondRedDotView:OnShow()

end

function CommonSecondRedDotView:OnHide()

end

function CommonSecondRedDotView:OnRegisterUIEvent()

end

function CommonSecondRedDotView:OnRegisterGameEvent()

end

function CommonSecondRedDotView:OnRegisterBinder()

end

function CommonSecondRedDotView:SetRedDotText(InText)
	self.TextNewYellow1:SetText(InText)
end

return CommonSecondRedDotView