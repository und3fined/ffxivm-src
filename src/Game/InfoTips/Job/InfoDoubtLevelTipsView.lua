---
--- Author: sammrli
--- DateTime: 2025-02-24 14:14
--- Description:邮递员升级提示
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")

local LSTR = _G.LSTR

---@class InfoDoubtLevelTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgJob UFImage
---@field ImgMask UFImage
---@field TextJob UFTextBlock
---@field TextJobPostman UFTextBlock
---@field TextLevel UFTextBlock
---@field TextQuestionMark UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local InfoDoubtLevelTipsView = LuaClass(UIView, true)

function InfoDoubtLevelTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgJob = nil
	--self.ImgMask = nil
	--self.TextJob = nil
	--self.TextJobPostman = nil
	--self.TextLevel = nil
	--self.TextQuestionMark = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function InfoDoubtLevelTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function InfoDoubtLevelTipsView:OnInit()

end

function InfoDoubtLevelTipsView:OnDestroy()

end

function InfoDoubtLevelTipsView:OnShow()
	local Params = self.Params
	if Params then
		local Level = Params[1]
		self.TextLevel:SetText(Level)
	end
	self.TextJobPostman:SetText(LSTR(930004)) --930004("邮递员职业等级提升")
	self.TextQuestionMark:SetText("?")
end

function InfoDoubtLevelTipsView:OnHide()

end

function InfoDoubtLevelTipsView:OnRegisterUIEvent()

end

function InfoDoubtLevelTipsView:OnRegisterGameEvent()

end

function InfoDoubtLevelTipsView:OnRegisterBinder()

end

return InfoDoubtLevelTipsView