---
--- Author: peterxie
--- DateTime:
--- Description: PVP地图，PVP玩法共用 不同之处，战场指挥时小地图可以放大进行操作
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local MathUtil = require("Utils/MathUtil")
local MsgBoxUtil = require("Utils/MsgBoxUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local MapUtil = require("Game/Map/MapUtil")
local MajorUtil = require("Utils/MajorUtil")
local MapDefine = require("Game/Map/MapDefine")
local PVPMapVM = require("Game/PVP/Map/VM/PVPMapVM")
local EventID = require("Define/EventID")
local PVPColosseumDefine = require("Game/PVP/Colosseum/PVPColosseumDefine")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIBinderUpdateBindableList = require("Binder/UIBinderUpdateBindableList")
local UIBinderSetIsVisible = require("Binder/UIBinderSetIsVisible")

local ProtoRes = require ("Protocol/ProtoRes")
local PVPCommunicateCommand = ProtoRes.PVPCommunicateCommand
local PVPCommunicateMethod = ProtoRes.PVPCommunicateMethod
local PVPCommunicateTarget = ProtoRes.PVPCommunicateTarget

local MapMarkerType = MapDefine.MapMarkerType
local MapContentType = MapDefine.MapContentType
local LSTR = _G.LSTR
local UE = _G.UE
local UKismetInputLibrary = UE.UKismetInputLibrary
local UWidgetBlueprintLibrary = UE.UWidgetBlueprintLibrary
local Unhandled <const> = UWidgetBlueprintLibrary.Unhandled()
local Handled <const> = UWidgetBlueprintLibrary.Handled()
local FVector2D = UE.FVector2D
local PVPMapDefaultSize = FVector2D(324, 324) -- 小地图默认大小
local PVPMapDragScale = 2 -- 小地图缩放比例
local PVPMapHalfWidth = MapDefine.MapConstant.PVPMAP_PANEL_HALF_WIDTH

local MathLibrary = _G.UE.UKismetMathLibrary
local TraceMarkDefaultSizeY = 30 -- 显示轨迹划痕固定宽度为30
local TracePosTolerance = 0.5 -- 划动检测误差距离

---@class PVPMapPanelView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field BtnExit UFButton
---@field BtnMap UFButton
---@field BtnMore UFButton
---@field BtnRecord UFButton
---@field FCanvasPanel_0 UFCanvasPanel
---@field ImgBg2 UFImage
---@field ImgCDAttack URadialImage
---@field ImgCDLimit URadialImage
---@field ImgCDMuster URadialImage
---@field ImgCDRetreat URadialImage
---@field LineItem_UIBP PVPMapLineItemView
---@field MaskBoxMap UMaskBox
---@field Min UFCanvasPanel
---@field NaviMapContent NaviMapContentView
---@field PanelMap UFCanvasPanel
---@field PanelMore UFCanvasPanel
---@field PanelTips UFCanvasPanel
---@field TableViewJob UTableView
---@field ToggleBtnAttack UToggleButton
---@field ToggleBtnLimit UToggleButton
---@field ToggleBtnMuster UToggleButton
---@field ToggleBtnRetreat UToggleButton
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local PVPMapPanelView = LuaClass(UIView, true)

function PVPMapPanelView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.BtnExit = nil
	--self.BtnMap = nil
	--self.BtnMore = nil
	--self.BtnRecord = nil
	--self.FCanvasPanel_0 = nil
	--self.ImgBg2 = nil
	--self.ImgCDAttack = nil
	--self.ImgCDLimit = nil
	--self.ImgCDMuster = nil
	--self.ImgCDRetreat = nil
	--self.LineItem_UIBP = nil
	--self.MaskBoxMap = nil
	--self.Min = nil
	--self.NaviMapContent = nil
	--self.PanelMap = nil
	--self.PanelMore = nil
	--self.PanelTips = nil
	--self.TableViewJob = nil
	--self.ToggleBtnAttack = nil
	--self.ToggleBtnLimit = nil
	--self.ToggleBtnMuster = nil
	--self.ToggleBtnRetreat = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function PVPMapPanelView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.LineItem_UIBP)
	self:AddSubView(self.NaviMapContent)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function PVPMapPanelView:OnInit()
	self.NaviMapContent:SetContentType(MapContentType.PVPMap)

	self.AdapterMapTargetList = UIAdapterTableView.CreateAdapter(self, self.TableViewJob)

	self.Binders = {
		{ "TargetVMList", UIBinderUpdateBindableList.New(self, self.AdapterMapTargetList) },
		{ "MapDragScale", UIBinderSetIsVisible.New(self, self.TableViewJob)},
		{ "MapDragScale", UIBinderSetIsVisible.New(self, self.PanelMore, true)},
	}

	self.TipsVisible = false
	self.CanCommunicate = true
	self.TimeCountDown = PVPColosseumDefine.ColosseumConstant.CommunicateCD
	self.CDImageList = {
		self.ImgCDAttack, 
		self.ImgCDRetreat, 
		self.ImgCDMuster, 
		self.ImgCDLimit
	}

	UIUtil.SetIsVisible(self.ToggleBtnAttack, true, true)
	UIUtil.SetIsVisible(self.ToggleBtnLimit, true, true)
	UIUtil.SetIsVisible(self.ToggleBtnMusterv, true, true)
	UIUtil.SetIsVisible(self.ToggleBtnRetreat, true, true)
end

function PVPMapPanelView:OnDestroy()

end

function PVPMapPanelView:OnShow()
	local MajorUIMapID = _G.MapMgr:GetUIMapID()
	local HalfWidth = MapUtil.GetPVPUIMapHalfWidth(MajorUIMapID)
	self.NaviMapContent:SetContentSize(_G.UE.FVector2D(HalfWidth * 2, HalfWidth * 2))

	if nil ~= self.MaskBoxMap then
		self.MaskBoxMap:RequestRender()
	end

	-- PVP地图，在地图层和背景层之间加了一层遮罩
	UIUtil.SetIsVisible(self.NaviMapContent.ImgMiniMapBg, true)
	UIUtil.SetIsVisible(self.NaviMapContent.ImgBG, false)
	UIUtil.SetIsVisible(self.PanelTips, false)
	self:UpdateCDImg(false)
end

function PVPMapPanelView:OnHide()

end

function PVPMapPanelView:OnRegisterUIEvent()
	UIUtil.AddOnClickedEvent(self, self.BtnMore, self.OnClickedBtnMore)
	UIUtil.AddOnClickedEvent(self, self.BtnExit, self.OnClickedBtnExit)
	UIUtil.AddOnClickedEvent(self, self.BtnRecord, self.OnClickedBtnRecord)
	UIUtil.AddOnClickedEvent(self, self.BtnMap, self.OnClickedBtnMap)
	
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnAttack, self.OnToggleBtnAttackClicked)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnRetreat, self.OnToggleBtnRetreatClicked)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnMuster, self.OnToggleBtnMusterClicked)
	UIUtil.AddOnClickedEvent(self, self.ToggleBtnLimit, self.OnToggleBtnLimitClicked)
	
end

function PVPMapPanelView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.PVPColosseumCommunicateInfo, self.OnGameEventPVPColosseumCommunicateInfo)
end

function PVPMapPanelView:OnRegisterBinder()
	self:RegisterBinders(PVPMapVM, self.Binders)
end

function PVPMapPanelView:OnRegisterTimer()
	self:RegisterTimer(self.OnTimer, 0, 1, 0)
end

function PVPMapPanelView:OnTimer()
	self:UpdateRenderOpacity()
end

function PVPMapPanelView:UpdateRenderOpacity()
	if not PVPMapVM.MapDragScale then
		return
	end

	for _, ViewModel in ipairs(PVPMapVM.TargetVMList:GetItems()) do
		ViewModel:UpdateRenderOpacity()
	end
end


function PVPMapPanelView:OnClickedBtnMore()
	local IsVisible = not self.TipsVisible
	self.TipsVisible = IsVisible

	UIUtil.SetIsVisible(self.PanelTips, IsVisible)
end

function PVPMapPanelView:OnClickedBtnExit()

	local function ConfirmCallBack()
		local ProtoCS = require ("Protocol/ProtoCS")
		local ColosseumSequence = ProtoCS.ColosseumSequence
		local PVPColosseumMgr = _G.PVPColosseumMgr
		if (PVPColosseumMgr:GetSequence() ~= ColosseumSequence.COLOSSEUM_PHASE_RESULT) then
			-- 非结算阶段，判断场上人数是否满员
			if PVPColosseumMgr:IsMatchFull() then
				MsgTipsUtil.ShowTipsByID(338009)
			end
		end

		_G.PWorldMgr:SendLeavePWorld()
	end

	MsgBoxUtil.ShowMsgBoxTwoOp(self, LSTR(10004), LSTR(810029), ConfirmCallBack, nil, LSTR(10003), LSTR(10002))
end

function PVPMapPanelView:OnClickedBtnRecord()
	_G.UIViewMgr:ShowView(_G.UIViewID.PVPColosseumRecordInside)
end

function PVPMapPanelView:OnClickedBtnMap()
	-- nothing
end

function PVPMapPanelView:OnToggleBtnAttackClicked()
	MsgTipsUtil.ShowTips(LSTR(10062))
	self.ToggleBtnAttack:SetChecked(false)
end

function PVPMapPanelView:OnToggleBtnRetreatClicked()
	MsgTipsUtil.ShowTips(LSTR(10062))
	self.ToggleBtnRetreat:SetChecked(false)
end

function PVPMapPanelView:OnToggleBtnMusterClicked()
	MsgTipsUtil.ShowTips(LSTR(10062))
	self.ToggleBtnMuster:SetChecked(false)
end

function PVPMapPanelView:OnToggleBtnLimitClicked()
	MsgTipsUtil.ShowTips(LSTR(10062))
	self.ToggleBtnLimit:SetChecked(false)
end

function PVPMapPanelView:OnCancelSelect()
	self.ToggleBtnAttack:SetChecked(false)
	self.ToggleBtnRetreat:SetChecked(false)
	self.ToggleBtnMuster:SetChecked(false)
	self.ToggleBtnLimit:SetChecked(false)
end


-- 小地图缩放
function PVPMapPanelView:ScaleMap(bReset)
	if PVPMapVM.CommandType == PVPCommunicateCommand.PVPCommunicateCommandNone
		or PVPMapVM.CommandType == PVPCommunicateCommand.PVPCommunicateCommandLimit then
		return
	end

	--local HalfWidth
	local MajorUIMapID = _G.MapMgr:GetUIMapID()
	local HalfWidth = MapUtil.GetPVPUIMapHalfWidth(MajorUIMapID)
	if bReset then
		PVPMapVM.MapDragScale = false
		UIUtil.CanvasSlotSetSize(self.Min, PVPMapDefaultSize)
	else
		PVPMapVM.MapDragScale = true
		PVPMapVM:UpdateTargetList()
		UIUtil.CanvasSlotSetSize(self.Min, PVPMapDefaultSize * PVPMapDragScale)
		HalfWidth = HalfWidth * PVPMapDragScale
	end
	--MapDefine.MapConstant.PVPMAP_PANEL_HALF_WIDTH = HalfWidth
	self.NaviMapContent:SetContentSize(FVector2D(HalfWidth * 2, HalfWidth * 2))

	-- 小地图缩放时，更新地图标记位置和大小
	for MapMarker, Info in pairs(self.NaviMapContent.MarkerInfos) do
		if bReset then
			Info.ViewModel:OnScaleChanged(1)
			Info.View:UpdateMarkerViewScale(0.5)
		else
			Info.ViewModel:OnScaleChanged(2)
			Info.View:UpdateMarkerViewScale(1)
		end
		Info.View:UpdateMarkerView()
		if MapMarker:CanDragSelect() then
			Info.ViewModel:SetIsSelected(false)
		end
	end

	for _, ItemView in ipairs(self.AdapterMapTargetList.ItemViewList) do
		local ViewModel = ItemView:GetViewModel()
		ViewModel:SetIsSelected(false)
	end
end

-- function PVPMapPanelView:OnMouseButtonDown(MyGeometry, MouseEvent)
-- 	local ScreenPosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)

-- 	PVPMapVM.CommandType = PVPCommunicateCommand.PVPCommunicateCommandNone
-- 	if UIUtil.IsUnderLocation(self.ToggleBtnAttack, ScreenPosition) then
-- 		PVPMapVM.CommandType = PVPCommunicateCommand.PVPCommunicateCommandAttack
-- 		self.ToggleBtnAttack:SetChecked(true)
-- 	elseif UIUtil.IsUnderLocation(self.ToggleBtnRetreat, ScreenPosition) then
-- 		PVPMapVM.CommandType = PVPCommunicateCommand.PVPCommunicateCommandRetreat
-- 		self.ToggleBtnRetreat:SetChecked(true)
-- 	elseif UIUtil.IsUnderLocation(self.ToggleBtnMuster, ScreenPosition) then
-- 		PVPMapVM.CommandType = PVPCommunicateCommand.PVPCommunicateCommandMuster
-- 		self.ToggleBtnMuster:SetChecked(true)
-- 	elseif UIUtil.IsUnderLocation(self.ToggleBtnLimit, ScreenPosition) then
-- 		PVPMapVM.CommandType = PVPCommunicateCommand.PVPCommunicateCommandLimit
-- 		self.ToggleBtnLimit:SetChecked(true)
-- 	end
	
-- 	if PVPMapVM.CommandType > PVPCommunicateCommand.PVPCommunicateCommandNone then
-- 		self.bDrawLine = false
-- 		local PanelSize = UIUtil.CanvasSlotGetSize(self.FCanvasPanel_0)
-- 		local LocalPosition = UIUtil.AbsoluteToLocal(self.FCanvasPanel_0, ScreenPosition)
-- 		LocalPosition.X = LocalPosition.X - PanelSize.X
-- 		self.PositionA = LocalPosition
-- 		--- 初始化连线轨迹
-- 		self.StartPos = LocalPosition
-- 		UIUtil.CanvasSlotSetPosition(self.LineItem_UIBP, LocalPosition)
-- 		UIUtil.CanvasSlotSetSize(self.LineItem_UIBP, FVector2D(0, TraceMarkDefaultSizeY))
-- 		UIUtil.SetIsVisible(self.LineItem_UIBP, true)
		
-- 		return UWidgetBlueprintLibrary.CaptureMouse(Handled, self)
-- 	end

-- 	return Unhandled
-- end

-- function PVPMapPanelView:OnMouseMove(MyGeometry, MouseEvent)
-- 	if PVPMapVM.CommandType == PVPCommunicateCommand.PVPCommunicateCommandNone
-- 		or PVPMapVM.CommandType == PVPCommunicateCommand.PVPCommunicateCommandLimit then
-- 		return Handled
-- 	end

-- 	local ScreenPosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)

-- 	if UIUtil.IsUnderLocation(self.ToggleBtnAttack, ScreenPosition)
-- 		or UIUtil.IsUnderLocation(self.ToggleBtnRetreat, ScreenPosition)
-- 		or UIUtil.IsUnderLocation(self.ToggleBtnMuster, ScreenPosition)
-- 		or UIUtil.IsUnderLocation(self.ToggleBtnLimit, ScreenPosition) then
-- 		self.bDrawLine = false
-- 		return Handled
-- 	end
	
-- 	local LocalPosition = UE.USlateBlueprintLibrary.AbsoluteToLocal(MyGeometry, ScreenPosition)
-- 	self.PositionB = LocalPosition
-- 	self.bDrawLine = true

-- 	if UIUtil.IsUnderLocation(self.Min, ScreenPosition) and not PVPMapVM.MapDragScale then
-- 		self:ScaleMap(false)
-- 	else
-- 		self:DrawCutMarkLine(MouseEvent)
-- 	end


-- 	for MapMarker, Info in pairs(self.NaviMapContent.MarkerInfos) do
-- 		if MapMarker:CanDragSelect() then
-- 			if Info.View:IsUnderLocation(ScreenPosition) then
-- 				Info.ViewModel:SetIsSelected(true)
-- 				local CommunicateInfo = self:GetCommunicateInfoByMiniMap(MapMarker)
-- 				local TipsContent = PVPMapVM:GetCommunicateInfoTips(CommunicateInfo.SendRoleID, CommunicateInfo.Command, 
-- 				CommunicateInfo.Method,CommunicateInfo.Target, CommunicateInfo.ParamID)
-- 				Info.ViewModel:SetTipsContent(TipsContent)
-- 			else
-- 				Info.ViewModel:SetIsSelected(false)
-- 			end
-- 		end
-- 	end

-- 	for _, ItemView in ipairs(self.AdapterMapTargetList.ItemViewList) do
-- 		local ViewModel = ItemView:GetViewModel()
-- 		if UIUtil.IsUnderLocation(ItemView, ScreenPosition) then
-- 			ViewModel:SetIsSelected(true)
-- 			local CommunicateInfo = self:GetCommunicateInfoByTargetList(ViewModel)
-- 			local TipsContent = PVPMapVM:GetCommunicateInfoTips(CommunicateInfo.SendRoleID, CommunicateInfo.Command, 
-- 				CommunicateInfo.Method,CommunicateInfo.Target, CommunicateInfo.ParamID)
-- 			ViewModel:SetTipsContent(TipsContent)
-- 		else
-- 			ViewModel:SetIsSelected(false)
-- 		end
-- 	end

-- 	return Handled
-- end

-- function PVPMapPanelView:OnMouseButtonUp(MyGeometry, MouseEvent)
-- 	UIUtil.SetIsVisible(self.LineItem_UIBP, false)
-- 	self.CurPos = nil
-- 	self.StartPos = nil
-- 	self:OnCancelSelect()
	
-- 	-- 冷却中
-- 	if not self.CanCommunicate then
-- 		_G.MsgTipsUtil.ShowTipsByID(338056) --信息发送过快，请稍后再试
-- 		return self:OnCommunicateEnd()
-- 	end

-- 	local ScreenPosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
-- 	if UIUtil.IsUnderLocation(self.ToggleBtnAttack, ScreenPosition)
-- 		or UIUtil.IsUnderLocation(self.ToggleBtnRetreat, ScreenPosition)
-- 		or UIUtil.IsUnderLocation(self.ToggleBtnMuster, ScreenPosition)
-- 		or UIUtil.IsUnderLocation(self.ToggleBtnLimit, ScreenPosition) then
-- 		-- 模拟直接点击按钮
-- 		PVPMapVM:SendCommunicateInfoByClick()
-- 		self:OnStartCommunicateCountDown()
-- 		return self:OnCommunicateEnd()
-- 	end

-- 	for MapMarker, Info in pairs(self.NaviMapContent.MarkerInfos) do
-- 		if MapMarker:CanDragSelect() then
-- 			if Info.View:IsUnderLocation(ScreenPosition) then
-- 				print("OnMouseButtonUp", MapMarker:ToString())
-- 				PVPMapVM:SendCommunicateInfoByMiniMap(MapMarker)
-- 				self:OnStartCommunicateCountDown()
-- 				break
-- 			end
-- 		end
-- 	end

-- 	for _, ItemView in ipairs(self.AdapterMapTargetList.ItemViewList) do
-- 		local ViewModel = ItemView:GetViewModel()
-- 		if UIUtil.IsUnderLocation(ItemView, ScreenPosition) then
-- 			print("OnMouseButtonUp", ViewModel.ID)
-- 			PVPMapVM:SendCommunicateInfoByTargetList(ViewModel)
-- 			self:OnStartCommunicateCountDown()
-- 			break
-- 		end
-- 	end

-- 	return self:OnCommunicateEnd()
-- end

function PVPMapPanelView:OnCommunicateEnd()
	self:ScaleMap(true)
	self.bDrawLine = false
	PVPMapVM.CommandType = PVPCommunicateCommand.PVPCommunicateCommandNone
	return UWidgetBlueprintLibrary.ReleaseMouseCapture(Handled)
end

-- 开始沟通CD
function PVPMapPanelView:OnStartCommunicateCountDown()
	local function UpdateCommunicateCD()
		--  显示CD图，设置CD进度
		self.TimeCountDown = self.TimeCountDown - 0.05
		self.CanCommunicate = self.TimeCountDown <= 0
		local Percent = math.clamp(self.TimeCountDown / PVPColosseumDefine.ColosseumConstant.CommunicateCD, 0, 1)
		self:UpdateCDImg(true, Percent)
		if self.CanCommunicate then
			-- 隐藏CD图
			self:UpdateCDImg(false)
			self.TimeCountDown = PVPColosseumDefine.ColosseumConstant.CommunicateCD
			self:UnRegisterTimer(self.TimerCommunicate)
		end
	end
	self.TimerCommunicate = self:RegisterTimer(UpdateCommunicateCD, 0, 0.05, -1)
end

function PVPMapPanelView:UpdateCDImg(IsVisible, Percent)
	for _, CDImage in ipairs(self.CDImageList) do
		UIUtil.SetIsVisible(CDImage, IsVisible)
		if IsVisible and Percent then
			CDImage:SetPercent(Percent)
		end
	end
end

---收到PVP沟通信息，小地图目标对应标记增加表现
function PVPMapPanelView:OnGameEventPVPColosseumCommunicateInfo(Params)
	local PVPCommunicateInfo = Params
	if PVPCommunicateInfo == nil then
		return
	end
	local CommandType = PVPCommunicateInfo.Command
	local SendMethod = PVPCommunicateInfo.Method
	local TargetType = PVPCommunicateInfo.Target
	local ParamID = PVPCommunicateInfo.ParamID

	local MarkerPredicate
	if SendMethod == PVPCommunicateMethod.PVPCommunicateMethodMiniMap
		or SendMethod == PVPCommunicateMethod.PVPCommunicateMethodTargetList then

		if TargetType == PVPCommunicateTarget.PVPCommunicateTargetCrystal then
			MarkerPredicate = function(Marker)
				if Marker:GetType() == MapMarkerType.Monster and Marker.IsColosseumCrystal then
					return true
				end
				return false
			end

		elseif TargetType == PVPCommunicateTarget.PVPCommunicateTargetPlayerInView then
			local TargetRoleID = ParamID
			MarkerPredicate = function(Marker)
				if Marker:GetType() == MapMarkerType.PVPPlayer and Marker:GetRoleID() == TargetRoleID then
					return true
				end
				return false
			end
		end
	end

	if MarkerPredicate == nil then
		return
	end
	local MarkerView = self.NaviMapContent:GetMapMarkerByPredicate(MarkerPredicate)
	if not MarkerView then
		return
	end
	--MarkerView:CreateTrackAnimView(CommandType)
end

---拖拽选中小地图目标
---@param MapMarker MapMarkerMonster | MapMarkerPVPPlayer
function PVPMapPanelView:GetCommunicateInfoByMiniMap(MapMarker)
	local PVPCommunicateInfo = {}
	PVPCommunicateInfo.SendRoleID = MajorUtil.GetMajorRoleID()
	PVPCommunicateInfo.Command = PVPMapVM.CommandType
	PVPCommunicateInfo.Method = PVPCommunicateMethod.PVPCommunicateMethodMiniMap

	local TargetType
	local MarkerType = MapMarker:GetType()
	if MarkerType == MapMarkerType.Monster and MapMarker.IsColosseumCrystal then
		TargetType = PVPCommunicateTarget.PVPCommunicateTargetCrystal
		PVPCommunicateInfo.ParamID = MapMarker:GetResID()
	elseif MarkerType == MapMarkerType.PVPPlayer then
		TargetType = PVPCommunicateTarget.PVPCommunicateTargetPlayerInView
		PVPCommunicateInfo.ParamID = MapMarker:GetRoleID()
	end
	PVPCommunicateInfo.Target = TargetType

	return PVPCommunicateInfo
end

---拖拽选中目标列表
---@param TargetItemVM PVPMapTargetItemVM
function PVPMapPanelView:GetCommunicateInfoByTargetList(TargetItemVM)
	local PVPCommunicateInfo = {}
	PVPCommunicateInfo.SendRoleID = MajorUtil.GetMajorRoleID()
	PVPCommunicateInfo.Command = PVPMapVM.CommandType
	PVPCommunicateInfo.Method = PVPCommunicateMethod.PVPCommunicateMethodTargetList

	local TargetType
	if TargetItemVM.IsColosseumCrystal then
		TargetType = PVPCommunicateTarget.PVPCommunicateTargetCrystal
		PVPCommunicateInfo.ParamID = TargetItemVM.ID
	elseif TargetItemVM.IsPlayer then
		if TargetItemVM.IsInVision then
			TargetType = PVPCommunicateTarget.PVPCommunicateTargetPlayerInView
		else
			TargetType = PVPCommunicateTarget.PVPCommunicateTargetPlayerOutView
		end
		PVPCommunicateInfo.ParamID = TargetItemVM.ID
	end
	PVPCommunicateInfo.Target = TargetType

	return PVPCommunicateInfo
end

--- 计算向量极坐标系夹角(-180~-90度/90~180度的角需要转换到对应旋转对称的象限中去)
---@param bCheck boolean@是否用来验证操作结果
function PVPMapPanelView:CalAngleByStartPosAndCurPos(bCheck)
	local StartPos = self.StartPos
	if not StartPos then
		return
	end
	local EndPos = self.CurPos
	if not EndPos then
		return
	end

	local VecY = StartPos.Y - EndPos.Y
	local VecX = StartPos.X - EndPos.X
	if bCheck and VecX < 0 then
		VecX = -1 * VecX
		VecY = -1 * VecY
	end
	local Angle = MathUtil.GetTransformAngle(VecX, VecY)
	return Angle
end

function PVPMapPanelView:DrawCutMarkLine(InTouchEvent)
	local StartPos = self.StartPos
	if not StartPos then
		return
	end

	local ScreenSpacePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(InTouchEvent)
	local LocalPosition = UIUtil.AbsoluteToLocal(self.FCanvasPanel_0, ScreenSpacePosition)
	local PanelSize = UIUtil.CanvasSlotGetSize(self.FCanvasPanel_0)
	LocalPosition.X = LocalPosition.X - PanelSize.X
	local OldCurPos = self.CurPos
	local DeltaLength = MathLibrary.Distance2D(OldCurPos, LocalPosition)
	if DeltaLength < TracePosTolerance then
		return
	end
	
	local Length = MathLibrary.Distance2D(StartPos, LocalPosition)
	local TargetTraceWidget = self.LineItem_UIBP
	if TargetTraceWidget then
		UIUtil.CanvasSlotSetSize(TargetTraceWidget, FVector2D(Length, TraceMarkDefaultSizeY))
		local Angle = self:CalAngleByStartPosAndCurPos()
		if Angle then
			TargetTraceWidget:SetRenderTransformAngle(Angle)
		end
	end
	
	self.CurPos = LocalPosition
end


return PVPMapPanelView