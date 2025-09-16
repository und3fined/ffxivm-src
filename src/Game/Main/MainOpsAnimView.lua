---
--- Author: Administrator
--- DateTime: 2025-03-20 10:51
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class MainOpsAnimView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelFlowToEntrance UFCanvasPanel
---@field PanelOpsCeremony UFCanvasPanel
---@field PanelOpsHalloween UFCanvasPanel
---@field AnimHalloweenFirst UWidgetAnimation
---@field AnimOpsCeremonyFirst UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainOpsAnimView = LuaClass(UIView, true)

function MainOpsAnimView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelFlowToEntrance = nil
	--self.PanelOpsCeremony = nil
	--self.PanelOpsHalloween = nil
	--self.AnimHalloweenFirst = nil
	--self.AnimOpsCeremonyFirst = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function MainOpsAnimView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MainOpsAnimView:OnInit()

end

function MainOpsAnimView:OnDestroy()

end

function MainOpsAnimView:OnShow()
	if self.Params == nil then
		return
	end

	if self.Params.Ani == "Halloween" then
		self:PlayHalloweenFirstAni()
	elseif self.Params.Ani == "Ceremony" then
		self:PlayCeremonyFirstAni()
	end
end

function MainOpsAnimView:PlayHalloweenFirstAni()
	self:PlayAnimation(self.AnimHalloweenFirst)
	local ShowTime = 2.9
	self:RegisterTimer(function()
		self:Hide()
		if self.Params and self.Params.CallBack and type(self.Params.CallBack) == "function" then
			self.Params.CallBack()
		end
	end, ShowTime, 0, 1)

end

function MainOpsAnimView:PlayCeremonyFirstAni()
	self:PlayAnimation(self.AnimOpsCeremonyFirst)
	local ShowTime = 3.67
	self:RegisterTimer(function()
		self:Hide()
		if self.Params and self.Params.CallBack and type(self.Params.CallBack) == "function" then
			self.Params.CallBack()
		end
	end, ShowTime, 0, 1)
end
function MainOpsAnimView:OnHide()

end

function MainOpsAnimView:OnRegisterUIEvent()

end

function MainOpsAnimView:OnRegisterGameEvent()

end

function MainOpsAnimView:OnRegisterBinder()

end

return MainOpsAnimView