--
-- Author: anypkvcai
-- Date: 2023-03-07 14:57
-- Description:
--

local UIView = require("UI/UIView")
local LuaClass = require("Core/LuaClass")
local UIUtil = require("Utils/UIUtil")
local CommonUtil = require("Utils/CommonUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapUtil = require("Game/Map/MapUtil")
local UIViewMgr = require("UI/UIViewMgr")
local UIViewID = require("Define/UIViewID")
local EventID = require("Define/EventID")
local MapMarkerFactory = require("Game/Map/MapMarkerFactory")
local TimeUtil = require("Utils/TimeUtil")
local ProtoRes = require("Protocol/ProtoRes")
local ObjectGCType = require("Define/ObjectGCType")

local MapContentType = MapDefine.MapContentType
local MapMarkerType = MapDefine.MapMarkerType
local MapMarkerEventType = ProtoRes.MapMarkerEventType

local MapMarkerMgr = _G.MapMarkerMgr
local FLOG_INFO = _G.FLOG_INFO
local FLOG_ERROR = _G.FLOG_ERROR
local FVector2D = _G.UE.FVector2D


---@class MapContentView : UIView
---@field ContentType MapContentType
---AUTO GENERATED CODE 3 BEGIN, PLEASE DON'T MODIFY
---@field ImgMap UFImage
---@field PanelMap UFCanvasPanel
---@field PanelMarker UFCanvasPanel
---@field AnimIn UWidgetAnimation
---AUTO GENERATED CODE 3 END, PLEASE DON'T MODIFY
local MapContentView = LuaClass(UIView, true)

function MapContentView:Ctor()
	--AUTO GENERATED CODE 1 BEGIN, PLEASE DON'T MODIFY
	--self.ImgMap = nil
	--self.PanelMap = nil
	--self.PanelMarker = nil
	--self.AnimIn = nil
	--AUTO GENERATED CODE 1 END, PLEASE DON'T MODIFY
	self.ContentType = MapContentType.WorldMap
end

function MapContentView:OnRegisterSubView()
	--AUTO GENERATED CODE 2 BEGIN, PLEASE DON'T MODIFY
	--AUTO GENERATED CODE 2 END, PLEASE DON'T MODIFY
end

function MapContentView:OnInit()
	--self.MarkerAlignment = FVector2D(0.5, 0.5)
	self.MarkerInfos = {}
	self.SlicedMarkers = {}
	self.RenderScale = FVector2D(1, 1)
end

function MapContentView:OnDestroy()

end

function MapContentView:OnShow()

end

function MapContentView:OnHide()
	self:ReleaseAllMarker()
end

function MapContentView:OnRegisterUIEvent()

end

function MapContentView:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.MapOnAddMarker, self.OnGameEventMapAddMarker)
	self:RegisterGameEvent(EventID.MapOnRemoveMarker, self.OnGameEventMapRemoveMarker)
	self:RegisterGameEvent(EventID.MapOnUpdateMarker, self.OnGameEventMapUpdateMarker)
	self:RegisterGameEvent(EventID.MapOnAddMarkerList, self.OnGameEventAddMarkerList)
	self:RegisterGameEvent(EventID.MapOnRemoveMarkerList, self.OnGameEventMapRemoveMarkerList)
end

function MapContentView:OnRegisterBinder()

end

function MapContentView:OnGameEventMapAddMarker(Params)
	if self:CheckContentType(Params.ContentType) then
		self:CreateMarker(Params.Marker)
	end
end

function MapContentView:OnGameEventMapRemoveMarker(Params)
	if self:CheckContentType(Params.ContentType) then
		self:RemoveMarker(Params.Marker)
	end
end

function MapContentView:OnGameEventMapUpdateMarker(Params)
	local Marker = Params.Marker
	if nil == Marker then
		return
	end

	if self:CheckContentType(Params.ContentType) then
		local Info = self.MarkerInfos[Marker]
		if nil == Info then
			return
		end

		local ViewModel = Info.ViewModel
		ViewModel:UpdateVM(Marker)
	end
end

function MapContentView:OnGameEventAddMarkerList(Params)
	local Markers = Params.Markers
	if nil == Markers then
		return
	end

	if self:CheckContentType(Params.ContentType) then
		-- for i = 1, #Markers do
		-- 	self:CreateMarker(Markers[i])
		-- end

		-- 新增标记列表支持分帧创建
		self:CreateMarkers(Markers)
	end
end

function MapContentView:OnGameEventMapRemoveMarkerList(Params)
	local Markers = Params.Markers
	if nil == Markers then
		return
	end

	if self:CheckContentType(Params.ContentType) then
		for i = 1, #Markers do
			self:RemoveMarker(Markers[i])
		end
	end
end

function MapContentView:CheckContentType(ContentType)
	return ContentType == self.ContentType
end

---是否因为特殊原因需要立即创建（比如追踪操作）
function MapContentView:IsSpecialMarkerNeedImmediateCreate(MarkerType, MarkerID)
	return false
end

---@param UIMapID number 地图UIMapID
---@param MapID number 地图MapID，传参可以nil。有些标记是跟着地图ID的，比如Fate、Quest，此时需要MapID
function MapContentView:CreateAllMarkers(UIMapID, MapID)
	local _ <close> = CommonUtil.MakeProfileTag("MapContentView:CreateAllMarkers")

	self:ReleaseAllMarker()

	if nil == UIMapID or UIMapID <= 0 then
		return
	end
	self.UIMapID = UIMapID

	local Markers = MapMarkerMgr:GetMapMarkers(UIMapID, MapID, self:GetContentType())
	if nil == Markers then
		return
	end
	FLOG_INFO("[MapContentView:CreateAllMarkers] UIMapID=%d, MapID=%s, ContentType=%d, Markers count=%d"
		, UIMapID, MapID, self.ContentType, table.length(Markers))

	local _ <close> = CommonUtil.MakeProfileTag("MapContentView:CreateMarkers")
	self:CreateMarkers(Markers)
end

function MapContentView:CreateMarkers(Markers)
	self.SlicedExcuteTask = true -- 是否开启地图标记定时分帧创建
	if not self.SlicedExcuteTask then
		for i = 1, #Markers do
			local Marker = Markers[i]
			self:CreateMarker(Marker)
		end
	else
		local ImmediateMarkers = {} -- 当前帧立即创建，比如有些标记地图打开时需要被选中，需要立即创建
		local SlicedMarkers = {} -- 定时分帧创建，等于延迟创建，要评估具体标记类型的功能
		for i = 1, #Markers do
			local Marker = Markers[i]

			local CanSliced = false
			if self:GetContentType() == MapContentType.MiniMap then
				-- 小地图所有标记都分帧创建
				CanSliced = true
			else
				-- 其他地图只有某些类型标记才分帧创建
				local MarkerType = Marker:GetType()
				if MarkerType == MapMarkerType.FixPoint then
					local EventType = Marker:GetEventType()
					if EventType ~= MapMarkerEventType.MAP_MARKER_EVENT_TELEPO
						and EventType ~= MapMarkerEventType.MAP_MARKER_EVENT_TRANS_DOOR
						and not Marker:GetIsFollow()
						and not self:IsSpecialMarkerNeedImmediateCreate(MarkerType, Marker.ID) then
						-- FixPoint标记类型里，排除传送水晶、追踪状态标记等开始就要显示的，剩下的标记都认为可以分帧创建
						CanSliced = true
					end
				elseif MarkerType == MapMarkerType.Monster then
					CanSliced = true
				end
			end

			if CanSliced then
				table.insert(SlicedMarkers, Marker)
			else
				table.insert(ImmediateMarkers, Marker)
			end
		end

		FLOG_INFO("[MapContentView:CreateMarkers] Markers=%d, ImmediateMarkers=%d, SlicedMarkers=%d, ContentType=%d"
			, #Markers, #ImmediateMarkers, #SlicedMarkers, self.ContentType)

		for i = 1, #ImmediateMarkers do
			local Marker = ImmediateMarkers[i]
			self:CreateMarker(Marker)
		end

		table.merge_table(self.SlicedMarkers, SlicedMarkers)
		--self.SlicedMarkers = SlicedMarkers
		if self.CreateMarkersTimeID then
			self:UnRegisterTimer(self.CreateMarkersTimeID)
			self.CreateMarkersTimeID = nil
		end
		self.CreateMarkersTimeID = self:RegisterTimer(self.OnTimerCreateMarkers, 0.05, 0.05, 0)
	end
end

-- 地图标记定时分帧创建
function MapContentView:OnTimerCreateMarkers()
	local StartTime = TimeUtil.GetLocalTimeMS()

	local Markers = self.SlicedMarkers
	while #Markers > 0 do
		local Marker = Markers[1]
		self:CreateMarker(Marker)
		table.remove(Markers, 1)

		local Time = TimeUtil.GetLocalTimeMS()
		local bTimeOut = (Time - StartTime >= 5)
		if bTimeOut then
			--FLOG_INFO("[MapContentView:OnTimerCreateMarkers] left create markers count=%d", #Markers)
			break
		end
	end

	if #Markers == 0 then
		--FLOG_INFO("[MapContentView:OnTimerCreateMarkers] create finish, MarkerInfos count=%d", table.length(self.MarkerInfos))
		if self.CreateMarkersTimeID then
			self:UnRegisterTimer(self.CreateMarkersTimeID)
			self.CreateMarkersTimeID = nil
		end
	end
end

function MapContentView:ReleaseAllMarker()
	local _ <close> = CommonUtil.MakeProfileTag("MapContentView:ReleaseAllMarker")
	for MapMarker, Info in pairs(self.MarkerInfos) do
		local View = Info.View
		View:RemoveFromParent()
		UIViewMgr:RecycleView(View)

		MapMarkerFactory.ReleaseMarkerVM(Info.ViewModel)
		MapMarkerFactory.ReleaseMarker(MapMarker)
	end

	self.UIMapID = 0
	self.MarkerInfos = {}

	self.SlicedMarkers = {}
	if self.CreateMarkersTimeID then
		self:UnRegisterTimer(self.CreateMarkersTimeID)
		self.CreateMarkersTimeID = nil
	end
end

function MapContentView:CreateMarker(Marker)
	if self.UIMapID ~= Marker:GetUIMapID() then
		return
	end

	local Scale = self.RenderScale.X

	if self:GetContentType() == MapContentType.MiniMap then
		if Marker:GetType() == MapMarkerType.FixPoint then
			if not Marker:IsMarkerIconVisible(Scale) and not Marker:IsMarkerTextVisible(Scale) then
				-- 【优化】小地图不可以缩放，默认比例下不可见的标记不用创建，减少标记View数量
				return
			end
		end
	end

	local BPName = MapUtil.GetMapMarkerBPName(Marker:GetBPType())
	if nil == BPName then
		return
	end

	local GCType = ObjectGCType.LRU
	if MapUtil.IsRegionMarkerBPType(Marker:GetBPType()) then
		-- Region标记不用cache，避免二级地图切换后仍引用资源
		GCType = ObjectGCType.NoCache
	end

	local _ <close> = CommonUtil.MakeProfileTag(string.format("MapContentView:CreateMarker_%s", MapMarkerMgr:GetMapMarkerTypeName(Marker:GetType())))
	local View = UIViewMgr:CreateViewByName(BPName, GCType, self, true, false)
	if nil == View then
		FLOG_ERROR("[MapContentView:CreateMarker] Error, BPName=%s", BPName)
		return
	end

	self:OnCreateMarker(Marker, View)

	local ViewModel = MapMarkerFactory.CreateMarkerVM(Marker:GetType())
	ViewModel:UpdateVM(Marker)
	ViewModel:OnScaleChanged(Scale)

	if View.OnScaleChanged == nil then
		-- 有Lua错误上报里OnScaleChanged为nil，检查所有标记View里都定义了OnScaleChanged方法，加临时log定位看看
		FLOG_ERROR("[MapContentView:CreateMarker] Error, BPName: %s, Marker: %s", BPName, Marker:ToString())
	end
	View:ShowView(ViewModel)
	View:OnScaleChanged(Scale)

	self.MarkerInfos[Marker] = { ViewModel = ViewModel, View = View }
end

function MapContentView:OnCreateMarker(Marker, View)
	local IsRegionMarker = MapUtil.IsRegionMarkerBPType(Marker:GetBPType())
	if IsRegionMarker then
		self.PanelMap:AddChild(View)
	else
		self.PanelMarker:AddChild(View)
	end

	local Scale = self.RenderScale.X

	--UIUtil.CanvasSlotSetAlignment(View, self.MarkerAlignment)
	UIUtil.CanvasSlotSetAutoSize(View, true)

	local MarkerScale = IsRegionMarker and 1 or Scale
	local X, Y = MapUtil.AdjustMapMarkerPosition(MarkerScale, Marker:GetPosition())
	UIUtil.CanvasSlotSetPosition(View, FVector2D(X, Y))

	UIUtil.CanvasSlotSetZOrder(View, Marker:GetPriority())
end

function MapContentView:RemoveMarker(MapMarker)
	local Info = self.MarkerInfos[MapMarker]
	if nil == Info then
		-- 创建时可能分帧，移除时要判断下从分帧创建列表中移除
		table.remove_item(self.SlicedMarkers, MapMarker)
		return
	end

	self.MarkerInfos[MapMarker] = nil

	Info.View:RemoveFromParent()
	UIViewMgr:RecycleView(Info.View)

	MapMarkerFactory.ReleaseMarkerVM(Info.ViewModel)
	MapMarkerFactory.ReleaseMarker(MapMarker)
end


---@param ContentType MapContentType
function MapContentView:SetContentType(ContentType)
	self.ContentType = ContentType
end

---@return MapContentType
function MapContentView:GetContentType()
	return self.ContentType
end

function MapContentView:SetContentPosition(Position)
	UIUtil.CanvasSlotSetPosition(self.PanelMap, Position)
	UIUtil.CanvasSlotSetPosition(self.PanelMarker, Position)
end

function MapContentView:SetContentSize(Size)
	UIUtil.CanvasSlotSetSize(self.PanelMap, Size)
	UIUtil.CanvasSlotSetSize(self.PanelMarker, Size)
end


---@return MarkerView, MapMarker
function MapContentView:GetMapMarkerByID(MarkerID)
	for MapMarker, Info in pairs(self.MarkerInfos) do
		if MapMarker:GetID() == MarkerID then
			return Info.View, MapMarker
		end
	end
end

---获取任务
---@return MarkerView, MapMarker
function MapContentView:GetMapMarkerQuest(QuestID, TargetID)
	for MapMarker, Info in pairs(self.MarkerInfos) do
		if MapMarker:GetType() == MapMarkerType.Quest
			and MapMarker:GetID() == QuestID
			and	MapMarker.TargetID == TargetID then
			return Info.View, MapMarker
		end
	end
end

---获取传送水晶
---@return MapMarker
function MapContentView:GetMapMarkerCrystal(CrystalID)
	for MapMarker, _ in pairs(self.MarkerInfos) do
		if MapMarker.GetEventArg and MapMarker.GetEventType then
			local EventType = MapMarker:GetEventType()
			local EventArg = MapMarker:GetEventArg()
			if EventType == MapMarkerEventType.MAP_MARKER_EVENT_TELEPO and EventArg == CrystalID then
				return MapMarker
			end
		end
	end
end

---查找标记。通过标记类型、标记子类型、标记ID三个参数查找，这是最通用的唯一确定一个标记的方法
---@param MarkerType number 标记类型
---@param MarkerID number 标记ID
---@param MarkerSubType number 标记子类型
---@param SubID number 子ID
---@return MarkerView, MapMarker
function MapContentView:GetMapMarkerByTypeAndID(MarkerType, MarkerID, MarkerSubType, SubID)
	for MapMarker, Info in pairs(self.MarkerInfos) do
		if MapMarker:GetType() == MarkerType
			and MapMarker:GetID() == MarkerID
			and MapMarker:GetSubType() == MarkerSubType then
			if not SubID then
				return Info.View, MapMarker
			else
				if MapMarker:GetSubID() == SubID then
					return Info.View, MapMarker
				end
			end
		end
	end
end

---@param MarkerPredicate function 标记查找函数
---@return MarkerView, MapMarker
function MapContentView:GetMapMarkerByPredicate(MarkerPredicate)
	if nil == MarkerPredicate then
		return
	end

	for MapMarker, Info in pairs(self.MarkerInfos) do
		if MarkerPredicate(MapMarker) then
			return Info.View, MapMarker
		end
	end
end

---@return MarkerView
function MapContentView:GetMapMarkerViewByMarker(MapMarker)
	for _, Info in pairs(self.MarkerInfos) do
		if Info.ViewModel:GetMapMarker() == MapMarker then
			return Info.View
		end
	end
end

---@return MapMarkerVM
function MapContentView:GetMapMarkerViewModeByMarker(MapMarker)
	for _, Info in pairs(self.MarkerInfos) do
		if Info.ViewModel:GetMapMarker() == MapMarker then
			return Info.ViewModel
		end
	end
end


function MapContentView:OnClickedMap(ScreenPosition)
	if not UIUtil.IsUnderLocation(self.PanelMap, ScreenPosition) then
		-- 这里改用PanelMap，而不是PanelMarker，是因为一级地图的尺寸和二三级地图不同
		return
	end

	if not UIUtil.IsVisible(self.PanelMarker) then
		-- 一级地图缩放到最小时，会隐藏PanelMarker来隐藏所有标记
		return
	end

	local MapMarkers = {}
	local RegionMarkers = {}
	for MapMarker, Info in pairs(self.MarkerInfos) do
		if Info.ViewModel:GetIsMarkerVisible() and Info.View:IsUnderLocation(ScreenPosition) then
			if MapUtil.IsRegionMarkerBPType(MapMarker:GetBPType()) then
				table.insert(RegionMarkers, MapMarker)
			else
				table.insert(MapMarkers, MapMarker)
			end
		end
	end

	self:OnClickedMakers(MapMarkers, RegionMarkers, ScreenPosition)
end

function MapContentView:OnClickedMakers(MapMarkers, RegionMarkers, ScreenPosition)
	if nil == MapMarkers then
		return
	end

	local Count = #MapMarkers
	if Count <= 0 then
		return
	end

	local Marker = MapMarkers[1]
	if nil == Marker then
		return
	end

	local Info = self.MarkerInfos[Marker]
	local MarkerView = Info.View
	ScreenPosition = UIUtil.LocalToAbsolute(MarkerView, FVector2D(0,-50))

	local EventParams = { ScreenPosition = ScreenPosition }
	if 1 == Count then
		if _G.NewTutorialMgr:GetPlayingTutorialMapItem(Marker.ID) then
			_G.NewTutorialMgr:InterceptMapClickEvent()
			return
		end
		if Marker.OnTriggerMapEvent then
			Marker:OnTriggerMapEvent(EventParams)
		end
	else
		local Params = { MapMarkers = MapMarkers, EventParams = EventParams }
		UIViewMgr:ShowView(UIViewID.WorldMapMarkerTipsList, Params)
	end
end


---更新地图标记图标可见性
function MapContentView:OnValueChangedMarkerIconVisible(NewValue, OldValue, MarkerType)
	for MapMarker, Info in pairs(self.MarkerInfos) do
		if MarkerType == nil or MapMarker:GetType() == MarkerType then
			Info.ViewModel:UpdateIconVisibility()
		end
	end
end

---更新地图标记文字可见性
function MapContentView:OnValueChangedMarkerTextVisible(NewValue, OldValue, MarkerType)
	for MapMarker, Info in pairs(self.MarkerInfos) do
		if MarkerType == nil or MapMarker:GetType() == MarkerType then
			Info.ViewModel:UpdateNameVisibility()
		end
	end
end

---更新地图标记可见性：迷雾变更
function MapContentView:UpdateMarkerByFogInfo()
	for Marker, Info in pairs(self.MarkerInfos) do
		if Marker:IsControlByFog() then
			Info.ViewModel:UpdateNameVisibility()
			Info.ViewModel:UpdateIconVisibility()
		end
	end
end

---更新地图标记可见性：开启条件变更
function MapContentView:UpdateMarkerByOpenFlag()
	for Marker, Info in pairs(self.MarkerInfos) do
		if Marker:IsControlByOpenFlag() then
			Info.ViewModel:UpdateNameVisibility()
			Info.ViewModel:UpdateIconVisibility()
		end
	end
end

---更新地图标记显示优先级，目前只有任务标记有这个需求
function MapContentView:UpdateMarkerPriority()
	for Marker, Info in pairs(self.MarkerInfos) do
		if Marker:GetType() == MapMarkerType.Quest then
			Info.ViewModel:UpdatePriority()
		end
	end
end

---更新地图标记高亮效果
function MapContentView:UpdateMarkerHighlightEffect(Params)
	if Params == nil then
		return
	end

	local Marker = Params.Marker
	local MarkerPredicate = Params.MarkerPredicate

	if Marker then
		-- 单个标记
		local Info = self.MarkerInfos[Marker]
		if Info then
			Info.View:PlayHighlightEffect()
		end
	elseif MarkerPredicate then
		-- 符合条件的标记
		for MapMarker, Info in pairs(self.MarkerInfos) do
			if MarkerPredicate(MapMarker) then
				Info.View:PlayHighlightEffect()
			end
		end
	end
end

---更新地图标记扩展图标
function MapContentView:UpdateMarkerExtraIcon()
	for Marker, Info in pairs(self.MarkerInfos) do
		if Marker:GetType() == MapMarkerType.FixPoint and Marker:IsEventTypeChangeMap() then
			Marker:UpdateAdjacentMapIcon()
			if Info.View.UpdateExtraIcon then
				Info.View:UpdateExtraIcon()
			end
		end
	end
end

return MapContentView