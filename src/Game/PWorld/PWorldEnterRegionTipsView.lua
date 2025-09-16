---
--- Author: haialexzhou
--- DateTime: 2022-01-17 20:05
--- Description: 已废弃，统一用InfoAreaTipsView
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

local AnimInDelayTime = 2
local ShowDuration = 3

---@class PWorldEnterRegionTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PWorldName UFTextBlock
---@field P_EFF_Particle_001_C_3_a UUIParticleEmitter
---@field P_EFF_Particle_001_C_3_b UUIParticleEmitter
---@field RegionName UFTextBlock
---@field Root UCanvasPanel
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PWorldEnterRegionTipsView = LuaClass(UIView, true)

function PWorldEnterRegionTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PWorldName = nil
	--self.P_EFF_Particle_001_C_3_a = nil
	--self.P_EFF_Particle_001_C_3_b = nil
	--self.RegionName = nil
	--self.Root = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PWorldEnterRegionTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PWorldEnterRegionTipsView:OnInit()

end

function PWorldEnterRegionTipsView:OnDestroy()
	--print("PWorldEnterRegionTipsView:OnDestroy!!!!!!!!!!!!!!!!!!!!!!!")
end

function PWorldEnterRegionTipsView:OnShow()
	--print("PWorldEnterRegionTipsView:OnShow!!!!!!!!!!!!!!!!!!!!!!!")
	local Params = self.Params
	--print("PWorldEnterRegionTipsView OnShow Params=" .. table_to_string(Params))
	if (Params ~= nil) then
		if (Params.AnimInDelayTime ~= nil) then
			AnimInDelayTime = Params.AnimInDelayTime
		end
		if (Params.ShowDuration ~= nil and Params.ShowDuration > 0) then
			ShowDuration = Params.ShowDuration
		end
	end

	local MapCfgData = nil
	local PWorldCfgData = nil
	if (Params ~= nil and Params.MapResID ~= nil) then
		MapCfgData = _G.PWorldMgr:GetMapTableCfg(Params.MapResID)
	else
		MapCfgData = _G.PWorldMgr:GetCurrMapTableCfg()
	end

	if (Params ~= nil and Params.PWorldResID ~= nil) then
		PWorldCfgData = _G.PWorldMgr:GetPWorldTableCfg(Params.PWorldResID)
	else
		PWorldCfgData = _G.PWorldMgr:GetCurrPWorldTableCfg()
	end

	local RegionNameStr = ""
	local PWorldNameStr = ""
	if (MapCfgData ~= nil) then
		RegionNameStr = MapCfgData.RegionName
		self.RegionName:SetText(RegionNameStr)
	end

	if (PWorldCfgData ~= nil) then
		PWorldNameStr = PWorldCfgData.PWorldName
		self.PWorldName:SetText(PWorldNameStr)
	end

	UIUtil.SetIsVisible(self.Root, false)

	local bShowRegionNameStr = not (RegionNameStr == "")
	local bShowPWorldNameStr = not (PWorldNameStr == "")
	UIUtil.SetIsVisible(self.RegionName,bShowRegionNameStr)
	UIUtil.SetIsVisible(self.ImgLine,bShowRegionNameStr)
	UIUtil.SetIsVisible(self.PWorldName,bShowPWorldNameStr)

	local function DelayPlayAnimIn()
		UIUtil.SetIsVisible(self.Root, true)
		-- 动效
		if self.AnimIn ~= nil then
			self:PlayAnimation(self.AnimIn)
		end
	end
	
	self.AnimInTimer = _G.TimerMgr:AddTimer(nil, DelayPlayAnimIn, AnimInDelayTime)

	if (RegionNameStr == "" and PWorldNameStr == "") then
		self:Hide()
	end
end

function PWorldEnterRegionTipsView:OnHide()
	--print("PWorldEnterRegionTipsView:OnHide!!!!!!!!!!!!!!!!!!!!!!!")
	if (self.AnimInTimer) then
		_G.TimerMgr:CancelTimer(self.AnimInTimer)
		self.AnimInTimer = nil
	end
	if self.AnimOutTimer then
        _G.TimerMgr:CancelTimer(self.AnimOutTimer)
		self.AnimOutTimer = nil
    end
	if self.HideTimer then
        _G.TimerMgr:CancelTimer(self.HideTimer)
		self.HideTimer = nil
    end
end

function PWorldEnterRegionTipsView:OnRegisterUIEvent()

end

function PWorldEnterRegionTipsView:OnRegisterGameEvent()

end

function PWorldEnterRegionTipsView:OnRegisterBinder()

end

function PWorldEnterRegionTipsView:OnRegisterTimer()
	self.AnimOutTimer = self:RegisterTimer(self.OnTimer, AnimInDelayTime + ShowDuration)
end

function PWorldEnterRegionTipsView:OnTimer()
	--隐藏动画表现有问题，有点跳，先屏蔽
	-- if self.AnimOut ~= nil then
	-- 	self:PlayAnimation(self.AnimOut)
	-- end

	-- local function OnPlayAnimOut()
	-- 	self:Hide()
	-- end
	-- self.HideTimer = _G.TimerMgr:AddTimer(nil, OnPlayAnimOut, 0.1)
	self:Hide()
end

return PWorldEnterRegionTipsView