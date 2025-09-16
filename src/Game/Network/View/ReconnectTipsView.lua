---
--- Author: anypkvcai
--- DateTime: 2023-05-29 09:48
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class ReconnectTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PopUpBG CommonPopUpBGView
---@field TextTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---@field AnimLoop UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local ReconnectTipsView = LuaClass(UIView, true)

function ReconnectTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PopUpBG = nil
	--self.TextTitle = nil
	--self.AnimIn = nil
	--self.AnimLoop = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function ReconnectTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function ReconnectTipsView:OnInit()

end

function ReconnectTipsView:OnDestroy()

end

function ReconnectTipsView:OnShow()
	self:PlayAnimation(self.AnimLoop, 0, 0)
	self.TextTitle:SetText(_G.LSTR(1260050))  -- 断线重连中
end

function ReconnectTipsView:OnHide()

end

function ReconnectTipsView:OnRegisterUIEvent()

end

function ReconnectTipsView:OnRegisterGameEvent()

end

function ReconnectTipsView:OnRegisterBinder()

end

return ReconnectTipsView