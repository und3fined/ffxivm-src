---
--- Author: chunfengluo
--- DateTime: 2023-04-06 14:25
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class WorldMapMarkerFateStageInfoView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelPopup CommonPopUpBGView
---@field PanelStageInfo FateStageMapItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapMarkerFateStageInfoView = LuaClass(UIView, true)

function WorldMapMarkerFateStageInfoView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelPopup = nil
	--self.PanelStageInfo = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerFateStageInfoView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PanelPopup)
	self:AddSubView(self.PanelStageInfo)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerFateStageInfoView:OnInit()

end

function WorldMapMarkerFateStageInfoView:OnDestroy()

end

function WorldMapMarkerFateStageInfoView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end

	local _, ViewportPosition = UIUtil.AbsoluteToViewport(Params.ScreenPosition)
	if ViewportPosition then
		UIUtil.CanvasSlotSetPosition(self.PanelStageInfo, ViewportPosition)
	end
end

function WorldMapMarkerFateStageInfoView:OnHide()

end

function WorldMapMarkerFateStageInfoView:OnRegisterUIEvent()

end

function WorldMapMarkerFateStageInfoView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function WorldMapMarkerFateStageInfoView:OnRegisterBinder()

end

function WorldMapMarkerFateStageInfoView:OnPreprocessedMouseButtonDown(MouseEvent)
	local UKismetInputLibrary = _G.UE.UKismetInputLibrary
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelStageInfo, MousePosition) then
		_G.WorldMapVM.ClickWorldMapTipsContent = true
	else
		_G.WorldMapVM.ClickWorldMapTipsContent = false
	end
end

return WorldMapMarkerFateStageInfoView