---
--- Author: ZhengJianChuan
--- DateTime: 2023-04-20 20:07
--- Description:金碟通用成功结算界面
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class GateRewardWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field IconGold UFImage
---@field ImgCountdown UFImage
---@field PopUpBG CommonPopUpBGView
---@field TextNumber UFTextBlock
---@field TextTitle UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local GateRewardWinView = LuaClass(UIView, true)

function GateRewardWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.IconGold = nil
	--self.ImgCountdown = nil
	--self.PopUpBG = nil
	--self.TextNumber = nil
	--self.TextTitle = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function GateRewardWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function GateRewardWinView:OnInit()
end

function GateRewardWinView:OnDestroy()
end

function GateRewardWinView:OnShow()
	if self.Params == nil then
		return
	end

	self.TextTitle:SetText(self.Params.Name)
	self.TextNumber:SetText(self.Params.AwardCoins)
end

function GateRewardWinView:OnHide()

end

function GateRewardWinView:OnRegisterUIEvent()
end

function GateRewardWinView:OnRegisterGameEvent()
	local ShowTime = self.Params.ShowTime
	
	if (ShowTime ~= nil and tonumber(ShowTime) ~= nil) then
		self:RegisterTimer(self.OnTimer, ShowTime)
	end
end

function GateRewardWinView:OnRegisterBinder()
end

function GateRewardWinView:OnRegisterTimer()
end

function GateRewardWinView:OnTimer()
	self:Hide()
end

return GateRewardWinView