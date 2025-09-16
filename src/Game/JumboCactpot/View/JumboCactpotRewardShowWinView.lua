---
--- Author: Administrator
--- DateTime: 2023-12-20 11:20
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class JumboCactpotRewardShowWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PlayStyleCommFrameM_UIBP PlayStyleCommFrameMView
---@field Text01 UFTextBlock
---@field Text02 UFTextBlock
---@field TextTitle01 UFTextBlock
---@field TextTitle02 UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local JumboCactpotRewardShowWinView = LuaClass(UIView, true)

function JumboCactpotRewardShowWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PlayStyleCommFrameM_UIBP = nil
	--self.Text01 = nil
	--self.Text02 = nil
	--self.TextTitle01 = nil
	--self.TextTitle02 = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function JumboCactpotRewardShowWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PlayStyleCommFrameM_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function JumboCactpotRewardShowWinView:OnInit()

end

function JumboCactpotRewardShowWinView:OnDestroy()

end

function JumboCactpotRewardShowWinView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end
	local PlayStyleCommFrameM_UIBP = self.PlayStyleCommFrameM_UIBP
	UIUtil.SetIsVisible(PlayStyleCommFrameM_UIBP.CommCurrency01, false)
	UIUtil.SetIsVisible(PlayStyleCommFrameM_UIBP.CommCurrency02, false)
	self.PlayStyleCommFrameM_UIBP.FText_Title:SetText(Params.Title)
	self.TextTitle01:SetText(Params.SubTitle1 ~= nil and Params.SubTitle1 or "")
	self.TextTitle02:SetText(Params.SubTitle2 ~= nil and Params.SubTitle2 or "")
	self.Text01:SetText(Params.Content1 ~= nil and Params.Content1 or "")
	self.Text02:SetText(Params.Content2 ~= nil and Params.Content2 or "")

end

function JumboCactpotRewardShowWinView:OnHide()

end

function JumboCactpotRewardShowWinView:OnRegisterUIEvent()

end

function JumboCactpotRewardShowWinView:OnRegisterGameEvent()

end

function JumboCactpotRewardShowWinView:OnRegisterBinder()

end

return JumboCactpotRewardShowWinView