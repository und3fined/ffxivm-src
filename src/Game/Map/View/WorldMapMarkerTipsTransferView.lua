---
--- Author: anypkvcai
--- DateTime: 2022-12-23 10:34
--- Description: 地图传送tips
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")


---@class WorldMapMarkerTipsTransferView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTransfer UFButton
---@field Common_PopUpBG_UIBP CommonPopUpBGView
---@field IconTransfer UFImage
---@field PanelRoot UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field PanelTipsLight UFHorizontalBox
---@field TextName UFTextBlock
---@field TextNear UFTextBlock
---@field ToggleBtnFavor UToggleButton
---@field AnimInConvenient UWidgetAnimation
---@field AnimInNormal UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapMarkerTipsTransferView = LuaClass(UIView, true)

function WorldMapMarkerTipsTransferView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTransfer = nil
	--self.Common_PopUpBG_UIBP = nil
	--self.IconTransfer = nil
	--self.PanelRoot = nil
	--self.PanelTips = nil
	--self.PanelTipsLight = nil
	--self.TextName = nil
	--self.TextNear = nil
	--self.ToggleBtnFavor = nil
	--self.AnimInConvenient = nil
	--self.AnimInNormal = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsTransferView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_PopUpBG_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsTransferView:OnInit()

end

function WorldMapMarkerTipsTransferView:OnDestroy()

end

function WorldMapMarkerTipsTransferView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local MapMarker = Params.MapMarker
	if nil == MapMarker then
		return
	end

	self.CrystalID = MapMarker:GetEventArg()

	self.TextName:SetText(MapMarker:GetTipsName())

	self.TextNear:SetText(_G.LSTR(700044))
	UIUtil.SetIsVisible(self.TextNear, Params.ShowClosest)

	local CurrAnim = self.AnimInNormal
	if Params.ShowClosest then
		CurrAnim = self.AnimInConvenient
	end
	self:PlayAnimation(CurrAnim)

	local NotHideOnClick = Params.NotHideOnClick
	UIUtil.SetIsVisible(self.Common_PopUpBG_UIBP, not NotHideOnClick)

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
	end, 0.1)
end

function WorldMapMarkerTipsTransferView:OnHide()
	_G.QuestMgr.QuestReport:DeleteCrossTask()
end

function WorldMapMarkerTipsTransferView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTransfer, self.OnClickedBtnTransfer)
end

function WorldMapMarkerTipsTransferView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function WorldMapMarkerTipsTransferView:OnRegisterBinder()

end

function WorldMapMarkerTipsTransferView:OnPreprocessedMouseButtonDown(MouseEvent)
	local UKismetInputLibrary = _G.UE.UKismetInputLibrary
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelTips, MousePosition) then
		_G.WorldMapVM.ClickWorldMapTipsContent = true
	else
		_G.WorldMapVM.ClickWorldMapTipsContent = false
	end
end

function WorldMapMarkerTipsTransferView:OnClickedBtnTransfer()
	local CrystalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
	if CrystalMgr:TransferByMap(self.CrystalID) then
		_G.QuestMgr.QuestReport:ReportCrossTask() --[sammrli] before Hide WorldMapPanel

		-- 这里不要除了主界面之外都隐藏，因为有可能传送不成功，比如自身的状态处于不可传送之类的，上面没有做判断
		-- 然后服务器会下发提示，导致提示界面被隐藏了
		-- 目前 UIViewID.CommonMsgBox 的层级是 High , UIViewID.ErrorTips 的层级是 Tips, 导致也不能通过层级做排除
		-- 因此，目前只能一个一个隐藏
		UIViewMgr:HideAllUIByLayer()

		--[[
		UIViewMgr:HideView(UIViewID.WorldMapPanel)
		UIViewMgr:HideView(UIViewID.QuestLogMainPanel)
		UIViewMgr:HideView(UIViewID.FishInghole, nil, {CrystalID = self.CrystalID})
		UIViewMgr:HideView(UIViewID.LeveQuestMainPanel)
		UIViewMgr:HideView(UIViewID.GatheringLogMainPanelView)
		UIViewMgr:HideView(UIViewID.CraftingLog)
		UIViewMgr:HideView(UIViewID.AetherCurrentMainPanelView)
		UIViewMgr:HideView(UIViewID.Main2ndPanel)
		UIViewMgr:HideView(UIViewID.AdventruePanel)
		UIViewMgr:HideView(UIViewID.FateArchiveMainPanel)
		UIViewMgr:HideView(UIViewID.GuideMainPanelView)
		UIViewMgr:HideView(UIViewID.GoldSauserEntranceMainPanel)
		UIViewMgr:HideView(UIViewID.PlayStyleMapWin)
		UIViewMgr:HideView(UIViewID.PVPInfoPanel)
		UIViewMgr:HideView(UIViewID.OpsActivityMainPanel)
		UIViewMgr:HideView(UIViewID.SightSeeingLogMainView)
		--]]
	end

	self:Hide()

	_G.WorldMapMgr:ReportData(MapDefine.MapReportType.CrystalTransfer, MapDefine.CrystalTransferSource.TransferTips, self.CrystalID)
end

return WorldMapMarkerTipsTransferView