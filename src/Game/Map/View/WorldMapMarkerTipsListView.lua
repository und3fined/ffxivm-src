---
--- Author: Administrator
--- DateTime: 2023-09-14 14:39
--- Description: 地图标记列表tips
---

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIAdapterTableView = require("UI/Adapter/UIAdapterTableView")
local UIUtil = require("Utils/UIUtil")
local UIViewID = require("Define/UIViewID")
local MapUtil = require("Game/Map/MapUtil")

local FVector2D = _G.UE.FVector2D


---@class WorldMapMarkerTipsListView : UIView
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field LoctionListPanel UFCanvasPanel
---@field PopUpBG CommonPopUpBGView
---@field SizeBox_0 USizeBox
---@field TableViewList UTableView
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local WorldMapMarkerTipsListView = LuaClass(UIView, true)

function WorldMapMarkerTipsListView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.LoctionListPanel = nil
	--self.PopUpBG = nil
	--self.SizeBox_0 = nil
	--self.TableViewList = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsListView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	self:AddSubView(self.PopUpBG)
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function WorldMapMarkerTipsListView:OnInit()
	self.TableViewAdapter = UIAdapterTableView.CreateAdapter(self, self.TableViewList, self.OnSelectChanged, true)
end

function WorldMapMarkerTipsListView:OnDestroy()

end

function WorldMapMarkerTipsListView:OnShow()
	local Params = self.Params
	if nil == Params then
		return
	end

	local MapMarkers = Params.MapMarkers
	if nil == MapMarkers then
		return
	end

	local function SortPredicate(Left, Right)
		local LeftPriority = Left:GetPriority()
		local RightPriority = Right:GetPriority()
		if LeftPriority ~= RightPriority then
			return LeftPriority > RightPriority
		else
			return Left:GetID() < Right:GetID()
		end
	end
	table.sort(MapMarkers, SortPredicate)
	self.TableViewAdapter:UpdateAll(MapMarkers)

	local EventParams = Params.EventParams
	local _, ViewportPosition = UIUtil.AbsoluteToViewport(EventParams.ScreenPosition)
	UIUtil.CanvasSlotSetPosition(self.LoctionListPanel, ViewportPosition)
	self.IsMovingViewByOffset = false

	-- 调整tips位置，确保显示在安全区内
	self:RegisterTimer(function ()
		local NeedAdjust, OffSetX, OffSetY = MapUtil.GetAdjustTipsPosition(self.LoctionListPanel)
		if NeedAdjust then
			local OffSetVector2D = FVector2D(OffSetX, OffSetY)
			local WorldMapPanel = _G.UIViewMgr:FindVisibleView(UIViewID.WorldMapPanel)
			if WorldMapPanel then
				self.IsMovingViewByOffset = true
				WorldMapPanel.MapContent:MoveMapByOffect(OffSetVector2D, function (DeltaPostion, IsMoveFinish)
					UIUtil.CanvasSlotSetPosition(self.LoctionListPanel, ViewportPosition + DeltaPostion)
					if IsMoveFinish then
						self.IsMovingViewByOffset = false
					end
				end)
			end
		end
	end, self.AnimIn:GetEndTime())
end

function WorldMapMarkerTipsListView:OnHide()

end

function WorldMapMarkerTipsListView:OnRegisterUIEvent()

end

function WorldMapMarkerTipsListView:OnRegisterGameEvent()
	self:RegisterGameEvent(_G.EventID.PreprocessedMouseButtonDown, self.OnPreprocessedMouseButtonDown)
	self:RegisterGameEvent(_G.EventID.WorldMapMarkerTipsListRemove, self.OnWorldMapMarkerTipsListRemove)
end

--- 其他地方传入的，通过ID移除目标ITEM,Params是TABLE,里面包含一个ID，其他的用于后续可能的拓展
--- Params.SearchKeyName 指定查找目标的KEY名字
--- Params.SearchKeyValue 查找的KEY的值
function WorldMapMarkerTipsListView:OnWorldMapMarkerTipsListRemove(Params)
	if (Params == nil) then
		return
	end

	local SearchKeyValue = Params.SearchKeyValue
	if (SearchKeyValue == nil) then
		return
end

	local SearchKeyName = Params.SearchKeyName
	if (SearchKeyName == nil)then
		return
	end

	local MapMarkers = self.Params.MapMarkers
	if nil == MapMarkers then
		return
	end

	local RemovedItem = table.remove_item(MapMarkers, SearchKeyValue, SearchKeyName)
	if (RemovedItem ~= nil) then
		local function SortPredicate(Left, Right)
			local LeftPriority = Left:GetPriority()
			local RightPriority = Right:GetPriority()
			if LeftPriority ~= RightPriority then
				return LeftPriority > RightPriority
			else
				return Left:GetID() < Right:GetID()
			end
		end
		table.sort(MapMarkers, SortPredicate)
		self.TableViewAdapter:UpdateAll(MapMarkers)
	end
end

function WorldMapMarkerTipsListView:OnRegisterBinder()

end

function WorldMapMarkerTipsListView:OnPreprocessedMouseButtonDown(MouseEvent)
	local UKismetInputLibrary = _G.UE.UKismetInputLibrary
	local MousePosition = UKismetInputLibrary.PointerEvent_GetScreenSpacePosition(MouseEvent)
	if UIUtil.IsUnderLocation(self.LoctionListPanel, MousePosition) then
		_G.WorldMapVM.ClickWorldMapTipsContent = true
	else
		_G.WorldMapVM.ClickWorldMapTipsContent = false
	end
end

function WorldMapMarkerTipsListView:OnSelectChanged(Index, ItemData, ItemView)
	local Marker = ItemData
	if nil == Marker then
		return
	end

	-- tips界面移动过程中，不让点击列表，避免误操作
	if self.IsMovingViewByOffset then
		return
	end

	local WorldMapPanel = _G.UIViewMgr:FindVisibleView(UIViewID.WorldMapPanel)
		or _G.UIViewMgr:FindVisibleView(UIViewID.FishInghole)
	if WorldMapPanel then
		local MarkerView = WorldMapPanel.MapContent:GetMapMarkerViewByMarker(Marker)
		local ScreenPosition = UIUtil.LocalToAbsolute(MarkerView, FVector2D(0,-50))
		self.Params.EventParams.ScreenPosition = ScreenPosition
		if Marker.OnTriggerMapEvent ~= nil then
			Marker:OnTriggerMapEvent(self.Params.EventParams)
		end
	end
	self:Hide()
end

return WorldMapMarkerTipsListView