---
--- Author: Administrator
--- DateTime: 2025-06-23 16:17
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local UIUtil = require("Utils/UIUtil")
local MapUtil = require("Game/Map/MapUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local GoldSaucerBlessingDefine = require("Game/GoldSaucerMiniGame/GoldSaucerBlessingDefine")
local EBlessingState = GoldSaucerBlessingDefine.EBlessingState

---@class WorldMapGoldSaucerMarkerTipsView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnTrack UFButton
---@field CanvasFollow UFCanvasPanel
---@field Common_PopUpBG_UIBP CommonPopUpBGView
---@field HorizontalContent UFHorizontalBox
---@field ImgTrackIcon UFImage
---@field PanelItem UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field TextBegin UFTextBlock
---@field TextName UFTextBlock
---@field TextTime UFTextBlock
---@field TimeProgressPanel UFCanvasPanel
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapGoldSaucerMarkerTipsView = LuaClass(UIView, true)

function WorldMapGoldSaucerMarkerTipsView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnTrack = nil
	--self.CanvasFollow = nil
	--self.Common_PopUpBG_UIBP = nil
	--self.HorizontalContent = nil
	--self.ImgTrackIcon = nil
	--self.PanelItem = nil
	--self.PanelTips = nil
	--self.TextBegin = nil
	--self.TextName = nil
	--self.TextTime = nil
	--self.TimeProgressPanel = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapGoldSaucerMarkerTipsView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.Common_PopUpBG_UIBP)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapGoldSaucerMarkerTipsView:OnInit()
    self.TimeCountTimer = nil -- 界面计时倒数计时器
	self.TotalTime = 0 -- 计时器起始时间
end

function WorldMapGoldSaucerMarkerTipsView:OnDestroy()

end

function WorldMapGoldSaucerMarkerTipsView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local MapMarker = Params.MapMarker

	local IconPath = MapUtil.GetMapMarkerStateIconPath(MapMarker)
	UIUtil.ImageSetBrushFromAssetPath(self.ImgTrackIcon, IconPath)
	self:UpdateDynamicData(MapMarker)
end

function WorldMapGoldSaucerMarkerTipsView:OnHide()

end

function WorldMapGoldSaucerMarkerTipsView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnTrack, self.OnClickedFollow)
end

function WorldMapGoldSaucerMarkerTipsView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MapOnUpdateMarker, self.OnMarkerStateChange)
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
end

function WorldMapGoldSaucerMarkerTipsView:OnRegisterBinder()

end

function WorldMapGoldSaucerMarkerTipsView:OnClickedFollow()
	local Params = self.Params
	local MapMarker = Params.MapMarker
	local Result = MapMarker:ToggleFollow()
	--采集笔记追踪体验调整(职业不符弹切换职业弹窗时，追踪的tips保持不关闭状态，切换后可直接交互)
	if Result ~= nil and Result == false then
		return
	end
	self:Hide()
end

function WorldMapGoldSaucerMarkerTipsView:OnPreprocessedMouseButtonDown(MouseEvent)
	local UKismetInputLibrary = _G.UE.UKismetInputLibrary
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.PanelTips, MousePosition) then
		_G.WorldMapVM.ClickWorldMapTipsContent = true
	else
		_G.WorldMapVM.ClickWorldMapTipsContent = false
	end
end

function WorldMapGoldSaucerMarkerTipsView:OnMarkerStateChange(EvtParams)
	local Params = self.Params
	if nil == Params then
		return
	end

	local MapMarker = Params.MapMarker
	if not MapMarker then
		return
	end
	local Marker = EvtParams.Marker
	if not Marker or Marker ~= MapMarker then
		return
	end

	self:UpdateDynamicData(Marker)
end

function WorldMapGoldSaucerMarkerTipsView:UpdateDynamicData(MapMarker)
	if not MapMarker then
		return
	end
	self.TextName:SetText(MapMarker:GetTipsName())
	local BlessState = MapMarker:GetMarkerBlessState()
	local bHideTimePanel = not BlessState or BlessState == EBlessingState.NotBegin
	UIUtil.SetIsVisible(self.TimeProgressPanel, not bHideTimePanel)
	UIUtil.SetIsVisible(self.TextBegin, BlessState == EBlessingState.Prepare)
	local RemainSec = 0
	if BlessState == EBlessingState.Prepare then
		RemainSec = _G.GoldSaucerBlessingMgr:GetTheSecToTheRoundStart()
	elseif BlessState and BlessState ~= EBlessingState.NotBegin then
		RemainSec = _G.GoldSaucerBlessingMgr:GetTheSecToRoundEnd()
	end
	self:StartTimeCountTimer(RemainSec)
	self:AdjustTipsPos()
end

function WorldMapGoldSaucerMarkerTipsView:StartTimeCountTimer(RemainSec)
	local TimeCountTimer = self.TimeCountTimer
	if TimeCountTimer then
		self:UnRegisterTimer(TimeCountTimer)
	end

	self.TotalTime = RemainSec
	self.TimeCountTimer = self:RegisterTimer(function()
	     local CurTime = self.TotalTime
		 self.TextTime:SetText(LocalizationUtil.GetCountdownTimeForShortTime(CurTime, "mm:ss")) 
		 if CurTime > 0 then
			self.TotalTime = CurTime - 1
		 else
			self:UnRegisterTimer(self.TimeCountTimer)
			self.TimeCountTimer = nil
		 end
	end, 0, 1, 0)
end

function WorldMapGoldSaucerMarkerTipsView:AdjustTipsPos()
	local Params = self.Params
	if nil == Params then
		return
	end
	local ScreenPosition = Params.ScreenPosition
	local _, ViewportPosition = UIUtil.AbsoluteToViewport(ScreenPosition)
	UIUtil.CanvasSlotSetPosition(self.PanelTips, ViewportPosition)
	-- 调整tips位置，确保显示在安全区内
	local AdjustDelayTime = 0.5 -- self.AnimIn:GetEndTime() 暂时没有AnimIn动画，先默认延迟0.5
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
	end, AdjustDelayTime)
end

return WorldMapGoldSaucerMarkerTipsView