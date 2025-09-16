---
--- Author: peterxie
--- DateTime: 2024-03-25 18:36
--- Description: HUD浮标点击事件
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")

local UE = _G.UE
local UWidgetBlueprintLibrary = UE.UWidgetBlueprintLibrary
local UKismetInputLibrary = UE.UKismetInputLibrary


---@class HUDView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field RootPanel UCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local HUDView = LuaClass(UIView, true)

function HUDView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.RootPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function HUDView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function HUDView:OnInit()

end

function HUDView:OnDestroy()

end

function HUDView:OnShow()

end

function HUDView:OnHide()

end

function HUDView:OnRegisterUIEvent()

end

function HUDView:OnRegisterGameEvent()
	--self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonUp, self.OnPreprocessedMouseButtonUp)
end

function HUDView:OnRegisterBinder()

end

function HUDView:OnPreprocessedMouseButtonUp(MouseEvent)
	local MainPanelView = UIViewMgr:FindVisibleView(UIViewID.MainPanel)
	if MainPanelView == nil or not MainPanelView:IsVisible() then
		-- 主界面不显示的情况，不处理浮标点击判断，避免在操作其他全屏界面时误取消跟踪
		return
	end

	local ScreenSpacePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	--local SelfGeometry = _G.UE.UWidgetLayoutLibrary.GetViewportWidgetGeometry(self)
	--local LocalPosition = _G.UE.USlateBlueprintLibrary.AbsoluteToLocal(SelfGeometry, ScreenSpacePosition)
	local PixelPosition = UIUtil.AbsoluteToViewport(ScreenSpacePosition)
	--print("[HUDView:OnPreprocessedMouseButtonUp] ScreenSpacePosition", ScreenSpacePosition.X, ScreenSpacePosition.Y)
	--print("[HUDView:OnPreprocessedMouseButtonUp] PixelPosition", PixelPosition.X, PixelPosition.Y)

	--_G.BuoyMgr:ProcessBuoyClick(PixelPosition)
end

return HUDView