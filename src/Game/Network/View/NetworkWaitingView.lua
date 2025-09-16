---
--- Author: anypkvcai
--- DateTime: 2024-06-03 11:32
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")

---@class NetworkWaitingView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMask UFImage
---@field ImgWaiting UFImage
---@field PanelRoot UCanvasPanel
---@field AniWaiting UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local NetworkWaitingView = LuaClass(UIView, true)

function NetworkWaitingView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgMask = nil
	--self.ImgWaiting = nil
	--self.PanelRoot = nil
	--self.AniWaiting = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function NetworkWaitingView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function NetworkWaitingView:OnInit()
	UIUtil.SetIsVisible(self.PanelRoot, false)
end

function NetworkWaitingView:OnDestroy()
end

function NetworkWaitingView:OnShow()
end

function NetworkWaitingView:OnHide()
end

function NetworkWaitingView:OnRegisterUIEvent()
end

function NetworkWaitingView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.NetworkStartWaiting, self.OnGameEventNetworkStartWaiting)
	self:RegisterGameEvent(EventID.NetworkStopWaiting, self.OnGameEventNetworkStopWaiting)
end

function NetworkWaitingView:OnRegisterBinder()
end

function NetworkWaitingView:OnRegisterTimer()
end

function NetworkWaitingView:OnTimer()
	--local bLoading = _G.PWorldMgr:IsLoadingWorld() or _G.LoadingMgr:IsLoadingView()
	--if bLoading then
	--	return
	--end

	UIUtil.SetIsVisible(self.ImgMask, true)
	UIUtil.SetIsVisible(self.ImgWaiting, true)
	self:PlayAnimation(self.AniWaiting, 0, 0)
end

function NetworkWaitingView:OnGameEventNetworkStartWaiting()
	UIUtil.SetIsVisible(self.PanelRoot, true)
	UIUtil.SetIsVisible(self.ImgMask, false)
	UIUtil.SetIsVisible(self.ImgWaiting, false)

	self:RegisterTimer(self.OnTimer, 0.8)
end

function NetworkWaitingView:OnGameEventNetworkStopWaiting()
	UIUtil.SetIsVisible(self.PanelRoot, false)
	self:UnRegisterAllTimer()
end

return NetworkWaitingView