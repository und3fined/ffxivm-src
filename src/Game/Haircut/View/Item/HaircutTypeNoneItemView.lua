---
--- Author: jamiyang
--- DateTime: 2024-01-23 10:00
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class HaircutTypeNoneItemView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnText UFButton
---@field ImgFocus UFImage
---@field ImgNormal UFImage
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HaircutTypeNoneItemView = LuaClass(UIView, true)

function HaircutTypeNoneItemView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnText = nil
	--self.ImgFocus = nil
	--self.ImgNormal = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HaircutTypeNoneItemView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HaircutTypeNoneItemView:OnInit()

end

function HaircutTypeNoneItemView:OnDestroy()

end

function HaircutTypeNoneItemView:OnShow()
	self.TextContent:SetText(_G.LSTR(1250040)) --"无"
end

function HaircutTypeNoneItemView:OnHide()

end

function HaircutTypeNoneItemView:OnRegisterUIEvent()

end

function HaircutTypeNoneItemView:OnRegisterGameEvent()

end

function HaircutTypeNoneItemView:OnRegisterBinder()

end

return HaircutTypeNoneItemView