---
--- Author: Administrator
--- DateTime: 2025-06-23 15:18
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PerformanceAideBtnView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field Button UFButton
---@field Img UFImage
---@field ImgInstruIcon UFImage
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PerformanceAideBtnView = LuaClass(UIView, true)

function PerformanceAideBtnView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.Button = nil
	--self.Img = nil
	--self.ImgInstruIcon = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PerformanceAideBtnView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PerformanceAideBtnView:OnInit()

end

function PerformanceAideBtnView:OnDestroy()

end

function PerformanceAideBtnView:OnShow()

end

function PerformanceAideBtnView:OnHide()

end

function PerformanceAideBtnView:OnRegisterUIEvent()

end

function PerformanceAideBtnView:OnRegisterGameEvent()

end

function PerformanceAideBtnView:OnRegisterBinder()

end

function  PerformanceAideBtnView:SetBtnName(Name)
	self.TextContent:SetText(Name or "")
end

return PerformanceAideBtnView