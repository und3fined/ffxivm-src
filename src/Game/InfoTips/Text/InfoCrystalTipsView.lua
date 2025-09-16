---
--- Author: sammrli
--- DateTime: 2024-09-09 19:30
--- Description:水晶共鸣提示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local InfoTipsBaseView = require("Game/InfoTips/InfoTipsBaseView")

---@class InfoCrystalTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextFateLoserSubTitle UFTextBlock
---@field TextFateLoserTitle UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoCrystalTipsView = LuaClass(InfoTipsBaseView, true)

function InfoCrystalTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextFateLoserSubTitle = nil
	--self.TextFateLoserTitle = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoCrystalTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoCrystalTipsView:OnInit()

end

function InfoCrystalTipsView:OnDestroy()

end

function InfoCrystalTipsView:OnShow()
	self.Super:OnShow()

	local Params = self.Params

	if Params then
		self.TextFateLoserTitle:SetText(Params.Title)
		self.TextFateLoserSubTitle:SetText(Params.SubTitle)
	end
end

function InfoCrystalTipsView:OnHide()

end

function InfoCrystalTipsView:OnRegisterUIEvent()

end

function InfoCrystalTipsView:OnRegisterGameEvent()
	self.Super:OnRegisterTimer()
end

function InfoCrystalTipsView:OnRegisterBinder()

end

return InfoCrystalTipsView