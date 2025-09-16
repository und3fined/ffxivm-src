---
--- Author: Administrator
--- DateTime: 2024-10-16 11:06
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local EventID = require("Define/EventID")
local UIViewID = require("Define/UIViewID")
local MapDefine = require("Game/Map/MapDefine")
local ModuleMapContentVM = require("Game/Map/VM/ModuleMapContentVM")
local MapUtil = require("Game/Map/MapUtil")
local MajorUtil = require("Utils/MajorUtil")
--local UIBinderSetText = require("Binder/UIBinderSetText")
local MapContentType = MapDefine.MapContentType
local FVector2D = _G.UE.FVector2D
local FLOG_ERROR = _G.FLOG_ERROR
local TextDotInterval = 0.5
local TextDotChangeInterval = 0.5
local DotTextSrc = {
	"<span color=\"#490f0000\">...</>",
	"<span color=\"#490f00\">.</><span color=\"#490f0000\">..</>",
	"<span color=\"#490f00\">..</><span color=\"#490f0000\">.</>",
	"<span color=\"#490f00\">...</>"
}
local DelayHideTimeByAutoMove = 2 -- 暂定的由于自动寻路功能延时关闭界面时间


---@class PlayStyleMapWinView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnClose UFButton
---@field ImgFrame UImage
---@field ImgFrameBG UImage
---@field ScaleBox_0 UScaleBox
---@field TextContent URichTextBox
---@field TextContent_1 URichTextBox
---@field mapContent AetherCurrentMapPanelView
---@field AnimIn UWidgetAnimation
---@field AnimOut UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PlayStyleMapWinView = LuaClass(UIView, true)

function PlayStyleMapWinView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnClose = nil
	--self.ImgFrame = nil
	--self.ImgFrameBG = nil
	--self.ScaleBox_0 = nil
	--self.TextContent = nil
	--self.TextContent_1 = nil
	--self.mapContent = nil
	--self.AnimIn = nil
	--self.AnimOut = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PlayStyleMapWinView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.mapContent)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PlayStyleMapWinView:OnInit()
	self.DotIndex = nil
	self.SrcTitle = nil
	self.InitRichTextDesireSizeX = nil
	self.InitScaleBoxPos = UIUtil.CanvasSlotGetPosition(self.ScaleBox_0)
end

function PlayStyleMapWinView:OnDestroy()
	self.InitScaleBoxPos = nil
end

function PlayStyleMapWinView:OnShow()
	self:InitMapBaseInfo()
	self:UpdateMapInfoByParams()
end

function PlayStyleMapWinView:OnHide()
	ModuleMapContentVM:SetTouchAllowed(true)
	self.DotIndex = nil
	self.SrcTitle = nil
	self.InitRichTextDesireSizeX = nil
		
end

function PlayStyleMapWinView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnClose, self.OnBtnCloseClicked)
end

function PlayStyleMapWinView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.StartAutoPathMove, self.OnNotifyStartAutoPathMove)
end

function PlayStyleMapWinView:OnRegisterBinder()

end

function PlayStyleMapWinView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0.0, TextDotInterval, 0)
end

function PlayStyleMapWinView:OnTimer()
	self:UpdateRichTextDotNum()
end

function PlayStyleMapWinView:OnNotifyStartAutoPathMove()
	self:RegisterTimer(function()
		self:Hide()
		_G.UIViewMgr:HideView(UIViewID.GoldSauserEntranceMainPanel)
	end, DelayHideTimeByAutoMove)
end

function PlayStyleMapWinView:UpdateRichTextDotNum()
	local CurDotIndex = self.DotIndex
	if not CurDotIndex then
		return
	end
	local DotText = DotTextSrc[CurDotIndex]
	local TotalText = string.format("%s%s", self.SrcTitle, DotText)
	local TextWidget = self.TextContent
	if not TextWidget then
		return
	end

	TextWidget:SetText(TotalText)
	--self:UpdateScaleBoxPosition()
	if CurDotIndex < 4 then
		self.DotIndex = CurDotIndex + 1
	else
		self.DotIndex = 1
	end
end

function PlayStyleMapWinView:UpdateScaleBoxPosition()
	local InitScaleBoxPos = self.InitScaleBoxPos
	if not InitScaleBoxPos then
		return
	end
	UIUtil.CanvasSlotSetPosition(self.ScaleBox_0, FVector2D(InitScaleBoxPos.X + 4.3 * (self.DotIndex - 1), InitScaleBoxPos.Y))
end

function PlayStyleMapWinView:OnBtnCloseClicked()
	self:Hide()
end

function PlayStyleMapWinView:InitMapBaseInfo()
	local EasyTraceType = MapContentType.EasyTrace
	self.mapContent:SetContentType(EasyTraceType)
	ModuleMapContentVM:SetMapContentType(EasyTraceType)
	ModuleMapContentVM:SetTouchAllowed(false)
	_G.MapMarkerMgr:CreateProviders(EasyTraceType)
	self.DotIndex = 1
	
end

function PlayStyleMapWinView:UpdateMapInfoByParams()
	local Params = self.Params
	if not Params then
		return
	end

	local ViewModel = Params.Data
	if not ViewModel then
		return
	end

	local Title = ViewModel.MapTitle
	self.SrcTitle = Title
	--self.TextContent:SetText(Title)

	local MapID = ViewModel.MapID
	local UIMapID = ViewModel.UIMapID
	self.MapID = MapID
	self.UIMapID = UIMapID and UIMapID or MapUtil.GetUIMapID(MapID)
	local CenterMarkerParams = ViewModel.CenterMarkerParams
	
	if (not MapID and not UIMapID) or not CenterMarkerParams then
		return
	end
	
	local MapContent = self.mapContent
	if not MapContent then
		return
	end

	local TraceMarkerParams = ViewModel.TraceMarkerParams
	if TraceMarkerParams then
		MapContent:PreSetTraceMarkerToImmediatelyCreate(TraceMarkerParams)
	end

	if UIMapID then
		MapContent:ShowMapContent(nil, nil, nil, UIMapID)
	else
		MapContent:ShowMapContent(MapID, nil)
	end
	
	if TraceMarkerParams then
		MapContent:TraceMarker(TraceMarkerParams)
	end

	-- 标记点移至地图中心显示的逻辑拆出来单独处理
	local TargetMarkerID
	local TraceMarkerID
	local bCalculateClosestCrystal = CenterMarkerParams.bCalculateClosestCrystal
	if not bCalculateClosestCrystal then
		TargetMarkerID = MapContent:ConvertParamsTable2TargetMarkerID(CenterMarkerParams)
	else
		TargetMarkerID, TraceMarkerID = self:FindTheCenterMarkerFromTraceMarker(MapContent, TraceMarkerParams)
	end
	
	if TargetMarkerID then
		local bCloseTelepo = ViewModel.bCloseTelepo
		MapContent:FocusMarkerByID(TargetMarkerID)
		-- 显示最近传送点的标记才需要调整Scale
		if bCalculateClosestCrystal and TraceMarkerID and TargetMarkerID ~= TraceMarkerID then
			local DelayMoveTime = 0.2 -- 等待上一帧的地图UI调整完
			self:RegisterTimer(function()
				local X, Y = self:AdjustScaleByClosestCrystal(MapContent, TargetMarkerID, TraceMarkerParams)
				if X and Y then
					local ParentViewSize = UIUtil.CanvasSlotGetSize(MapContent.PanelMarker)
					local Pos = ParentViewSize / 2 - FVector2D(X, Y)
					ModuleMapContentVM:SetMapOffset(Pos.X, Pos.Y)
					local ScaleToAdjust = 0.8 -- 暂定缩放值，待后续看是否需要优化
					ModuleMapContentVM:SetMapScale(ScaleToAdjust)
				end
				MapContent:UpdateCenterTelepoMarkerTipsState(TargetMarkerID, bCloseTelepo)
			end, DelayMoveTime) -- 延时处理for Marker创建完成
		else
			MapContent:UpdateCenterTelepoMarkerTipsState(TargetMarkerID, bCloseTelepo)
		end
	end
end

function PlayStyleMapWinView:FindTheCenterMarkerFromTraceMarker(MapContent, TraceMarkerParams)
	local TraceMarkerID = MapContent:ConvertParamsTable2TargetMarkerID(TraceMarkerParams)
	if not TraceMarkerID then
		return
	end

	local _, TraceMapMarker = MapContent:GetMapMarkerByID(TraceMarkerID)
	if not TraceMapMarker then
		return
	end

	local function GetTheTraceMarkUIPos()
		local UIPosX, UIPosY = TraceMapMarker:GetAreaMapPos()
		return FVector2D(UIPosX, UIPosY)
	end

	local bAcrossMap = TraceMarkerParams.bAcrossMap -- 金碟专用(金碟游乐场与陆行鸟广场MapID不同，但小水晶可以互相传送)
	if bAcrossMap then
		local CrystalMarker = MapContent:FindClosestCrystal(GetTheTraceMarkUIPos(), MapUtil.IsCurrentMapCrystalByMarkerCfg)
		if CrystalMarker then
			return CrystalMarker.ID, TraceMarkerID
		else
			return TraceMarkerID, nil
		end
	else
		local CurMapID = _G.PWorldMgr:GetCurrMapResID()
		if CurMapID ~= self.MapID then
			return TraceMarkerID, nil
		end

		local CrystalMarker, ClosestDis = MapContent:FindClosestCrystal(GetTheTraceMarkUIPos(), MapUtil.IsCurrentMapCrystalByMarkerCfg)
		local MajorEntityID = MajorUtil.GetMajorEntityID()
		local MajorUIPosX, MajorUIPosY = MapUtil.GetActorUIPosByEntityID(self.UIMapID, MajorEntityID)
		local MajorDis2Trace = _G.UE.UKismetMathLibrary.Distance2D(GetTheTraceMarkUIPos(), FVector2D(MajorUIPosX, MajorUIPosY))
		if ClosestDis >= MajorDis2Trace then
			return TraceMarkerID, nil
		else
			return CrystalMarker.ID, TraceMarkerID
		end
	end
end

function PlayStyleMapWinView:AdjustScaleByClosestCrystal(MapContent, TargetMarkerID, TraceMarkerParams)
	local TraceMarkerId = MapContent:ConvertParamsTable2TargetMarkerID(TraceMarkerParams)
	if not TraceMarkerId then
		return
	end
	local TraceMarkerView = MapContent:GetMapMarkerByID(TraceMarkerId)
	if TraceMarkerView == nil then
		return
	end

	local TargetMarkerView = MapContent:GetMapMarkerByID(TargetMarkerID)
	if not TargetMarkerView then
		return
	end

	local LimitAreaCenterPos = UIUtil.LocalToAbsolute(self.ImgFrame, FVector2D(0, 0))
	local TraceMarkerPos = UIUtil.LocalToAbsolute(TraceMarkerView, FVector2D(0, 0))
	local LimitAreaSize = UIUtil.GetAbsoluteSize(self.ImgFrame)
	local PosOffset = TraceMarkerPos - LimitAreaCenterPos
	local OffsetX = math.abs(PosOffset.X)
	local OffsetY = math.abs(PosOffset.Y)
	if OffsetX > LimitAreaSize.X / 2 or OffsetY > LimitAreaSize.Y / 2 then
		local TraceLocalPos = UIUtil.CanvasSlotGetPosition(TraceMarkerView)
		local TargetLocalPos = UIUtil.CanvasSlotGetPosition(TargetMarkerView)
		local TraceLocalPosX = TraceLocalPos.X
		local TraceLocalPosY = TraceLocalPos.Y
		local TargetLocalPosX = TargetLocalPos.X
		local TargetLocalPosY = TargetLocalPos.Y

		local MiddlePosX = (TraceLocalPosX + TargetLocalPosX) / 2
		local MiddlePosY = (TraceLocalPosY + TargetLocalPosY) / 2 

		-- 如果追踪水晶在上方，需考虑传送tips高度
		if TargetLocalPosY < TraceLocalPosY then
			local WorldTransTipsHeight = 73
			MiddlePosY = MiddlePosY - WorldTransTipsHeight
		end

		return MiddlePosX, MiddlePosY
	end
end

return PlayStyleMapWinView