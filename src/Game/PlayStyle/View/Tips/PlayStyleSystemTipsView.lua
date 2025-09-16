---
--- Author: Administrator
--- DateTime: 2023-10-08 10:03
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class PlayStyleSystemTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelSystemTips UFCanvasPanel
---@field TextContent UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PlayStyleSystemTipsView = LuaClass(UIView, true)

function PlayStyleSystemTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelSystemTips = nil
	--self.TextContent = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PlayStyleSystemTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PlayStyleSystemTipsView:OnInit()

end

function PlayStyleSystemTipsView:OnDestroy()

end

function PlayStyleSystemTipsView:OnShow()
	UIUtil.SetIsVisible(self.PanelSystemTips, true)

	local Params = self.Params
	if Params == nil then
		return
	end
	local Content = Params.Content
	self.TextContent:SetText(Content)

	local function Hide()
		self:Hide()
	end
	_G.TimerMgr:AddTimer(self, Hide, 3, 0, 1, nil)
end

function PlayStyleSystemTipsView:OnHide()

end

function PlayStyleSystemTipsView:OnRegisterUIEvent()

end

function PlayStyleSystemTipsView:OnRegisterGameEvent()

end

function PlayStyleSystemTipsView:OnRegisterBinder()

end

return PlayStyleSystemTipsView