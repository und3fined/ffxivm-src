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
---@field PanelOpsCeremony UFCanvasPanel
---@field PanelOpsHalloween UFCanvasPanel
---@field PanelStarlightCelebration UFCanvasPanel
---@field AnimHalloweenFirst UWidgetAnimation
---@field AnimOpsCeremonyFirst UWidgetAnimation
---@field AnimStarlightCelebrationFirst UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MainOpsAnimView = LuaClass(UIView, true)

local AniDataMap = {
	["Halloween"] = {
		AniVar = "AnimHalloweenFirst",
		ShowTime = 2.9
	},
	["Ceremony"] = {
		AniVar = "AnimOpsCeremonyFirst",
		ShowTime = 3.67
	},
	["Starlight"] = {
		AniVar = "AnimStarlightCelebrationFirst",
		ShowTime = 2.27
	},
	
}

function MainOpsAnimView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelOpsCeremony = nil
	--self.PanelOpsHalloween = nil
	--self.PanelStarlightCelebration = nil
	--self.AnimHalloweenFirst = nil
	--self.AnimOpsCeremonyFirst = nil
	--self.AnimStarlightCelebrationFirst = nil
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

	self:PlayActivityFirstAni()

end

function MainOpsAnimView:PlayActivityFirstAni()
	if self.Params.Ani == nil then
		return
	end
	local AniData = AniDataMap[self.Params.Ani]
	if AniData == nil then
		return
	end
	local AniVar = AniData.AniVar
	if AniData == nil then
		return
	end
	self:PlayAnimation(self[AniVar])

	self:RegisterTimer(function()
		self:Hide()
		if self.Params and self.Params.CallBack and type(self.Params.CallBack) == "function" then
			self.Params.CallBack()
		end
	end, AniData.ShowTime, 0, 1)

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