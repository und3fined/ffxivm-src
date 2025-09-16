---
--- Author: Administrator
--- DateTime: 2023-09-25 21:15
--- Description: 地图标记名称tips
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class WorldMapMarkerTipsTargetView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelTips UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field TextName UFTextBlock
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapMarkerTipsTargetView = LuaClass(UIView, true)

function WorldMapMarkerTipsTargetView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelTips = nil
	--self.PopUpBG = nil
	--self.TextName = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsTargetView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsTargetView:OnInit()

end

function WorldMapMarkerTipsTargetView:OnDestroy()

end

function WorldMapMarkerTipsTargetView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local Name = Params.Name
	self.TextName:SetText(Name)

	local ScreenPosition = Params.ScreenPosition
	local _, ViewportPosition = UIUtil.AbsoluteToViewport(ScreenPosition)
	ViewportPosition.Y = ViewportPosition.Y - 100
	UIUtil.CanvasSlotSetPosition(self.PanelTips, ViewportPosition)
end

function WorldMapMarkerTipsTargetView:OnHide()

end

function WorldMapMarkerTipsTargetView:OnRegisterUIEvent()

end

function WorldMapMarkerTipsTargetView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function WorldMapMarkerTipsTargetView:OnRegisterBinder()

end

function WorldMapMarkerTipsTargetView:OnPreprocessedMouseButtonDown(MouseEvent)
	local UKismetInputLibrary = _G.UE.UKismetInputLibrary
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelTips, MousePosition) then
		_G.WorldMapVM.ClickWorldMapTipsContent = true
	else
		_G.WorldMapVM.ClickWorldMapTipsContent = false
	end
end

return WorldMapMarkerTipsTargetView