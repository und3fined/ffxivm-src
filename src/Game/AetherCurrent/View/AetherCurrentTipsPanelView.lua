---
--- Author: Alex
--- DateTime: 2023-12-27 15:09
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local AetherCurrentDefine = require("Game/AetherCurrent/AetherCurrentDefine")

---@class AetherCurrentTipsPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field TextTips01 UFTextBlock
---@field TextTips02 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local AetherCurrentTipsPanelView = LuaClass(UIView, true)

function AetherCurrentTipsPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.TextTips01 = nil
	--self.TextTips02 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function AetherCurrentTipsPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function AetherCurrentTipsPanelView:OnInit()
	self.Callback = nil
end

function AetherCurrentTipsPanelView:OnDestroy()

end

function AetherCurrentTipsPanelView:OnShow()
	local Params = self.Params
	if not Params then
		return
	end

	local bShowProcess = Params.bShowProcess
	UIUtil.SetIsVisible(self.TextTips01, bShowProcess)

	local Content = Params.Content or ""
	self.TextTips02:SetText(Content)

	self.Callback = Params.Callback

	local ShowTime = Params.ShowTime or AetherCurrentDefine.PanelTipsShowTime
	self:RegisterTimer(function()
		self:Hide()
		local Callback = self.Callback
		if Callback and type(Callback) == "function" then
			Callback()
		end
	end, ShowTime, 0, 1)

end

function AetherCurrentTipsPanelView:OnHide()

end

function AetherCurrentTipsPanelView:OnRegisterUIEvent()

end

function AetherCurrentTipsPanelView:OnRegisterGameEvent()

end

function AetherCurrentTipsPanelView:OnRegisterBinder()

end

return AetherCurrentTipsPanelView