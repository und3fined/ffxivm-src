---
--- Author: Administrator
--- DateTime: 2023-11-15 16:34
--- Description:
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local EventID = require("Define/EventID")

local UE = _G.UE
local TreasureHuntSkillPanelVM = _G.TreasureHuntSkillPanelVM
local UWidgetBlueprintLibrary = UE.UWidgetBlueprintLibrary
local MIN_OFFSET = 100
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")
local UIBinderIsLoopAnimPlay = require("Binder/UIBinderIsLoopAnimPlay")

local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local MapCfg = require("TableCfg/MapCfg")

---@class TreasureHuntSkillPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field MapInfoPanel TreasureHuntMapSItemView
---@field NamedSlotChild UNamedSlot
---@field PanelSkill UFCanvasPanel
---@field MinRenderScale float
---@field MaxRenderScale float
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local TreasureHuntSkillPanelView = LuaClass(UIView, true)

function TreasureHuntSkillPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.MapInfoPanel = nil
	--self.NamedSlotChild = nil
	--self.PanelSkill = nil
	--self.MinRenderScale = nil
	--self.MaxRenderScale = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function TreasureHuntSkillPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.MapInfoPanel)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function TreasureHuntSkillPanelView:OnInit()
	self.OffsetX = 0
	self.OffsetY = 0

	self.TouchInfos = {
		[1] = {
			PointerIndex = 0,
			IsTouched = false,
			TouchPosition = UE.FVector2D(0, 0)
		},
	}

    local ViewModel = TreasureHuntSkillPanelVM:GetMapItemVM()
	self.MapInfoPanel.ViewModel = ViewModel
end

function TreasureHuntSkillPanelView:OnDestroy()
end

function TreasureHuntSkillPanelView:OnShow()
	UIUtil.CanvasSlotSetPosition(self.NamedSlotChild, _G.UE.FVector2D(0, 0))
	self.OffsetX = 0
	self.OffsetY = 0

	self.MapInfoPanel:ShowSkillPanel()
	TreasureHuntSkillPanelVM:AddPositionTimer()
end

function TreasureHuntSkillPanelView:OnHide()
	self.IsNeedShowCrystal = false
	if TreasureHuntSkillPanelVM:IsPanelClosedByOtherUI() ~= true then
		TreasureHuntSkillPanelVM:ClosePositionTimer()
	end
end

function TreasureHuntSkillPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.MapInfoPanel.BtnClose, self.OnClickedBtnClose)
	UIUtil.AddOnClickedEvent(self, self.MapInfoPanel.BtnGOMap, self.OnClickedBtnGOMap)
end

function TreasureHuntSkillPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.WorldMapFinishChanged, self.OnWorldMapFinishChanged)

end

function TreasureHuntSkillPanelView:OnRegisterBinder()

end

function TreasureHuntSkillPanelView:OnClickedBtnClose()
	TreasureHuntSkillPanelVM:CloseSkillPanel()
end

function TreasureHuntSkillPanelView:OnClickedBtnGOMap()
	if _G.SingBarMgr:GetMajorIsSinging() then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(640031))  --读条中无法操作！
		return
	end

	if _G.PWorldMgr:GetCrystalPortalMgr():GetIsTransferring() then
		_G.MsgTipsUtil.ShowTips(_G.LSTR(640032)) --传送中无法操作！
		return
	end

	local MapItemVM = TreasureHuntSkillPanelVM:GetMapItemVM()
	if MapItemVM == nil then return end
	local MapData = MapItemVM:GetMapData()
	if MapData == nil then return end

	-- 如果没打开大地图则通过WorldMapContentView:ShowTreasureHuntCrystal找水晶，如果已经打开地图了则通过WorldMapFinishChanged找水晶
	self.IsNeedShowCrystal = UIViewMgr:IsViewVisible(UIViewID.WorldMapPanel)
	_G.WorldMapMgr:ShowWorldMapTreasureHunt(MapData)
end

function TreasureHuntSkillPanelView:OnWorldMapFinishChanged(Params)
	if not self.IsNeedShowCrystal then return end

	self.IsNeedShowCrystal = false
	local WorldMapView = UIViewMgr:FindView(UIViewID.WorldMapPanel)
	if WorldMapView then
		local MapItemVM = TreasureHuntSkillPanelVM:GetMapItemVM()
		if MapItemVM == nil then return end
		local MapData = MapItemVM:GetMapData()
		if MapData == nil then return end
		WorldMapView:ShowTreasureHuntCrystal(MapData)
	end
end

-- 移动相关的逻辑
function TreasureHuntSkillPanelView:GetTouchInfo(PointerIndex)
	return self.TouchInfos[PointerIndex + 1]
end

function TreasureHuntSkillPanelView:GetTouchCount()
	local Count = 0
	for i = 1, #self.TouchInfos do
		if self.TouchInfos[i].IsTouched then
			Count = Count + 1
		end
	end
	return Count
end

function TreasureHuntSkillPanelView:OnTouchStarted(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)

	local TouchInfo = self:GetTouchInfo(PointerIndex)
	if nil == TouchInfo then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local ScreenSpacePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)
	TouchInfo.IsTouched = true
	TouchInfo.TouchPosition = LocalPosition

	local Handled = UWidgetBlueprintLibrary.Handled()
	return UWidgetBlueprintLibrary.CaptureMouse(Handled, self)
end

function TreasureHuntSkillPanelView:OnTouchMoved(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)

	local TouchInfo = self:GetTouchInfo(PointerIndex)
	if nil == TouchInfo then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	local ScreenSpacePosition = UE.UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(InGeometry, ScreenSpacePosition)

	local Count = self:GetTouchCount()
	if Count <= 0 then
		TouchInfo.IsTouched = true
	end

	if Count == 1 then
		local LastPosition = TouchInfo.TouchPosition
		local Offset = LocalPosition - LastPosition
		self:OnMoved(Offset)
	end

	TouchInfo.TouchPosition = LocalPosition

	return UWidgetBlueprintLibrary.Handled()
end

function TreasureHuntSkillPanelView:OnTouchEnded(InGeometry, InTouchEvent)
	local PointerIndex = UE.UKismetInputLibrary.PointerEvent_GetPointerIndex(InTouchEvent)
	--print("CommGestureView:OnTouchEnded", PointerIndex)

	local TouchInfo = self:GetTouchInfo(PointerIndex)
	if nil == TouchInfo then
		return UWidgetBlueprintLibrary.UnHandled()
	end

	TouchInfo.IsTouched = false

	local Handled = UWidgetBlueprintLibrary.Handled()
	return UWidgetBlueprintLibrary.ReleaseMouseCapture(Handled)
end

function TreasureHuntSkillPanelView:OnMoved(Offset)
	local X = self.OffsetX + Offset.X
	local Y = self.OffsetY + Offset.Y

	self.OffsetX = X
	self.OffsetY = Y

	self:OnPositionChanged(self.OffsetX, self.OffsetY)
end

function TreasureHuntSkillPanelView:OnPositionChanged(X, Y)
	local Offsets = UIUtil.CanvasSlotGetOffsets(self.NamedSlotChild)
	Offsets.Left = X
	Offsets.Top = Y
	UIUtil.CanvasSlotSetOffsets(self.NamedSlotChild, Offsets)
end

function TreasureHuntSkillPanelView:GetPosition()
	local InPosition = UIUtil.CanvasSlotGetPosition(self.NamedSlotChild)
	return InPosition
end

function TreasureHuntSkillPanelView:SetPosition(InPosition)
	UIUtil.CanvasSlotSetPosition(self.NamedSlotChild, InPosition)
end

function TreasureHuntSkillPanelView:GetOffsets()
	local Offsets = {X = self.OffsetX,Y = self.OffsetY}
	return Offsets
end

function TreasureHuntSkillPanelView:SetOffsets(Offsets)
	self.OffsetX = Offsets.X
	self.OffsetY = Offsets.Y
end


return TreasureHuntSkillPanelView