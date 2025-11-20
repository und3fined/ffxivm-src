---
--- Author: peterxie
--- DateTime: 2025-06-05 15:33
--- Description: 地图房屋土地标记tips
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local ProtoCS = require("Protocol/ProtoCS")
local MapUtil = require("Game/Map/MapUtil")
local DefaultIcon = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Btn_LandSales2_png.UI_Map_Btn_LandSales2_png'"
local HouseIcon = "PaperSprite'/Game/UI/Atlas/NewMap/Frames/UI_Map_Btn_HouseCheck_png.UI_Map_Btn_HouseCheck_png'"

---@class WorldMapMarkerTipsHouseView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClick UFButton
---@field Common_PopUpBG_UIBP CommonPopUpBGView
---@field ImgIcon UFImage
---@field PanelTips UFCanvasPanel
---@field TextName UFTextBlock
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapMarkerTipsHouseView = LuaClass(UIView, true)

function WorldMapMarkerTipsHouseView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClick = nil
	--self.Common_PopUpBG_UIBP = nil
	--self.ImgIcon = nil
	--self.PanelTips = nil
	--self.TextName = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsHouseView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_PopUpBG_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsHouseView:OnInit()

end

function WorldMapMarkerTipsHouseView:OnDestroy()

end

function WorldMapMarkerTipsHouseView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local MapMarker = Params.MapMarker
	if nil == MapMarker then
		return
	end

	self.TextName:SetText(MapMarker:GetTipsName())
	local LandInfo = MapMarker:GetLandInfo()
	local LandStatus = LandInfo and LandInfo.LandStatus
	local IconPath = LandStatus == ProtoCS.LandStatusType.LandStatusType_Built and HouseIcon or DefaultIcon
	UIUtil.ImageSetBrushFromAssetPath(self.ImgIcon, IconPath)
	
	local ScreenPosition = Params.ScreenPosition
	local _, ViewportPosition = UIUtil.AbsoluteToViewport(ScreenPosition)
	UIUtil.CanvasSlotSetPosition(self.PanelTips, ViewportPosition)

	-- 调整tips位置，确保显示在安全区内
	self:RegisterTimer(function ()
		local NeedAdjust, OffSetX, OffSetY = MapUtil.GetAdjustTipsPosition(self.PanelTips)
		if NeedAdjust then
			local FVector2D = _G.UE.FVector2D
			local OffSetVector2D = FVector2D(OffSetX, OffSetY)
			local WorldMapPanel = _G.UIViewMgr:FindVisibleView(_G.UIViewID.WorldMapPanel)
			if WorldMapPanel then
				WorldMapPanel.MapContent:MoveMapByOffect(OffSetVector2D, function (DeltaPostion)
					UIUtil.CanvasSlotSetPosition(self.PanelTips, ViewportPosition + DeltaPostion)
				end)
			end
		end
	end, 0.1)
end

function WorldMapMarkerTipsHouseView:OnHide()

end

function WorldMapMarkerTipsHouseView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClick, self.OnClickedBtnInfo)
end

function WorldMapMarkerTipsHouseView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function WorldMapMarkerTipsHouseView:OnRegisterBinder()

end

function WorldMapMarkerTipsHouseView:OnPreprocessedMouseButtonDown(MouseEvent)
	local UKismetInputLibrary = _G.UE.UKismetInputLibrary
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelTips, MousePosition) then
		_G.WorldMapVM.ClickWorldMapTipsContent = true
	else
		_G.WorldMapVM.ClickWorldMapTipsContent = false
	end
end

function WorldMapMarkerTipsHouseView:OnClickedBtnInfo()
	local Params = self.Params
	local MapMarker = Params.MapMarker
	-- 打开土地资料界面或房屋资料界面
	_G.HouseLandMgr:OpenHouseOrLandPanel(MapMarker:GetLandInfo())

	self:Hide()
end

return WorldMapMarkerTipsHouseView