---
--- Author: Administrator
--- DateTime: 2024-04-28 14:36
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")

---@class WorldMapMarkerPlayStyleStageInfoView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field PanelPopup CommonPopUpBGView
---@field PanelStageInfo PlayStyleStageMapItemView
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapMarkerPlayStyleStageInfoView = LuaClass(UIView, true)

function WorldMapMarkerPlayStyleStageInfoView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.PanelPopup = nil
	--self.PanelStageInfo = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerPlayStyleStageInfoView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PanelPopup)
	self:AddSubView(self.PanelStageInfo)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerPlayStyleStageInfoView:OnInit()

end

function WorldMapMarkerPlayStyleStageInfoView:OnDestroy()

end

function WorldMapMarkerPlayStyleStageInfoView:OnShow()
	local Params = self.Params
	if Params == nil then
		return
	end

	local _, ViewportPosition = UIUtil.AbsoluteToViewport(Params.ScreenPosition)
	if ViewportPosition then
		UIUtil.CanvasSlotSetPosition(self.PanelStageInfo, ViewportPosition)
	end
end

function WorldMapMarkerPlayStyleStageInfoView:OnHide()

end

function WorldMapMarkerPlayStyleStageInfoView:OnRegisterUIEvent()

end

function WorldMapMarkerPlayStyleStageInfoView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function WorldMapMarkerPlayStyleStageInfoView:OnRegisterBinder()

end

function WorldMapMarkerPlayStyleStageInfoView:OnPreprocessedMouseButtonDown(MouseEvent)
	local UKismetInputLibrary = _G.UE.UKismetInputLibrary
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelStageInfo, MousePosition) then
		_G.WorldMapVM.ClickWorldMapTipsContent = true
	else
		_G.WorldMapVM.ClickWorldMapTipsContent = false
	end
end

return WorldMapMarkerPlayStyleStageInfoView