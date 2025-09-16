---
--- Author: peterxie
--- DateTime: 2024-03-29 18:39
--- Description: 地图追踪tips
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MapUtil = require("Game/Map/MapUtil")


---@class WorldMapMarkerTipsFollowView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field Common_PopUpBG_UIBP CommonPopUpBGView
---@field ImgIcon UFImage
---@field PanelRoot UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field TextName UFTextBlock
---@field ToggleBtnFavor UToggleButton
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapMarkerTipsFollowView = LuaClass(UIView, true)

function WorldMapMarkerTipsFollowView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.Common_PopUpBG_UIBP = nil
	--self.ImgIcon = nil
	--self.PanelRoot = nil
	--self.PanelTips = nil
	--self.TextName = nil
	--self.ToggleBtnFavor = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsFollowView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_PopUpBG_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsFollowView:OnInit()

end

function WorldMapMarkerTipsFollowView:OnDestroy()

end

function WorldMapMarkerTipsFollowView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local MapMarker = Params.MapMarker

	local IconPath = MapUtil.GetMapMarkerStateIconPath(MapMarker)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)

	self.TextName:SetText(MapMarker:GetTipsName())

	local ScreenPosition = Params.ScreenPosition
	local _, ViewportPosition = UIUtil.AbsoluteToViewport(ScreenPosition)
	UIUtil.CanvasSlotSetPosition(self.PanelTips, ViewportPosition)

	-- 调整tips位置，确保显示在安全区内
	self:RegisterTimer(function ()
		local NeedAdjust, OffSetX, OffSetY = MapUtil.GetAdjustTipsPosition(self.PanelTips)
		if NeedAdjust then
			local FVector2D = _G.UE.FVector2D
			local OffSetVector2D = FVector2D(OffSetX, OffSetY)
			local WorldMapPanel = _G.UIViewMgr:FindVisibleView(UIViewID.WorldMapPanel)
			if WorldMapPanel then
				WorldMapPanel.MapContent:MoveMapByOffect(OffSetVector2D, function (DeltaPostion)
					UIUtil.CanvasSlotSetPosition(self.PanelTips, ViewportPosition + DeltaPostion)
				end)
			end
		end
	end, self.AnimIn:GetEndTime())
end

function WorldMapMarkerTipsFollowView:OnHide()

end

function WorldMapMarkerTipsFollowView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickedFollow)
end

function WorldMapMarkerTipsFollowView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function WorldMapMarkerTipsFollowView:OnRegisterBinder()

end

function WorldMapMarkerTipsFollowView:OnPreprocessedMouseButtonDown(MouseEvent)
	local UKismetInputLibrary = _G.UE.UKismetInputLibrary
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelTips, MousePosition) then
		_G.WorldMapVM.ClickWorldMapTipsContent = true
	else
		_G.WorldMapVM.ClickWorldMapTipsContent = false
	end
end

function WorldMapMarkerTipsFollowView:OnClickedFollow()
	local Params = self.Params
	local MapMarker = Params.MapMarker
	local Result = MapMarker:ToggleFollow()
	--采集笔记追踪体验调整(职业不符弹切换职业弹窗时，追踪的tips保持不关闭状态，切换后可直接交互)
	if Result ~= nil and Result == false then
		return
	end
	self:Hide()
end

return WorldMapMarkerTipsFollowView