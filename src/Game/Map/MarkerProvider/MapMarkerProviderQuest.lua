--
-- Author: anypkvcai
-- Date: 2023-03-21 11:01
-- Description:
--

local LuaClass = require("Core/LuaClass")
local MapMarkerProvider = require("Game/Map/MarkerProvider/MapMarkerProvider")
local MapMarkerQuest = require("Game/Map/Marker/MapMarkerQuest")
local MapUtil = require("Game/Map/MapUtil")
local MapDefine = require("Game/Map/MapDefine")
local MapMarkerType = MapDefine.MapMarkerType
local QuestDefine = require("Game/Quest/QuestDefine")
local QuestNaviType = QuestDefine.NaviType


---@class MapMarkerProviderQuest : MapMarkerProvider
local MapMarkerProviderQuest = LuaClass(MapMarkerProvider)

function MapMarkerProviderQuest:Ctor()

end

function MapMarkerProviderQuest:GetMarkerType()
	return MapMarkerType.Quest
end

function MapMarkerProviderQuest:OnGetMarkers(UIMapID, MapID)
	--加载当前地图的关卡数据
	_G.QuestTrackMgr:TryInitQuestParams(MapID)

	local MapMarkers = self:CreateQuestMarkers()

	return MapMarkers
end

function MapMarkerProviderQuest:OnCreateMarker(Params)
	local Quest = Params
	local Marker = self:CreateMarker(MapMarkerQuest, Quest.QuestID, Quest)

	self:OnUpdateQuestIcon(Marker, Quest.QuestID)

	local IsTrackQuest = false
	if self:IsTrackQuest(Quest.QuestID)
        or _G.WorldMapMgr:IsWorldMapShowQuest(Quest.QuestID) then
		IsTrackQuest = true
	end
	Marker:SetIsTrackQuest(IsTrackQuest)

	local Pos = Quest.Pos
	local X, Y = MapUtil.GetUIPosByLocation(Pos, Quest.UIMapID)
	if Quest.IsMapping and Quest.MappingMapCfg then
		-- 映射任务，用地图映射的入口坐标
		local MappingMapCfg = Quest.MappingMapCfg
		Pos = MapUtil.GetMappingMapTransPos(MappingMapCfg.MappingMapID, MappingMapCfg.ActorResID, MappingMapCfg.TransType)
		X, Y = MapUtil.GetUIPosByLocation(Pos, MappingMapCfg.MappingUIMapID)
	end
	Marker:SetAreaMapPos(X, Y)
	if Pos then
		Marker:SetWorldPos(Pos.X, Pos.Y, Pos.Z)
	end

	-- 记录标记所属的三级地图信息
	-- 任务所属UIMapID，同个地图可以多层即多个UIMapID
	Marker:SetAreaUIMapID(Quest.UIMapID)
	-- 任务所属MapID
	Marker:SetMapID(Quest.MapID)

	return Marker
end


-- 是否已接取的追踪中任务
function MapMarkerProviderQuest:IsTrackQuest(QuestID)
	if nil == self.TrackingQuestList then
		return false
	end

	return nil ~= table.find_item(self.TrackingQuestList, QuestID, "QuestID")
end

-- 是否未接取的追踪中任务
function MapMarkerProviderQuest:IsFollowQuest(QuestID)
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo == nil  then
		return false
	end
	if FollowInfo.FollowType ~= self:GetMarkerType() then
		return false
	end
	local FollowQuestID = FollowInfo.FollowID
	return FollowQuestID == QuestID
end


function MapMarkerProviderQuest:CreateQuestMarkers()
	local MapMarkers = {}

	self.TrackingQuestList = _G.QuestTrackMgr:GetTrackingQuestParam()
	local TrackingQuestList = self.TrackingQuestList
	--print("[MapMarkerProviderQuest] CreateQuestMarkers TrackingQuestList", table.tostring_block(TrackingQuestList))
	local MainlimeQuestList = _G.QuestTrackMgr:GetMainlineQuestParam()
	--print("[MapMarkerProviderQuest] CreateQuestMarkers MainlimeQuestList", table.tostring_block(MainlimeQuestList))

	-- 任务排序
	local function SortQuestList(QuestList)
		table.sort(QuestList, function(Left, Right)
			-- 按任务跳转查看状态排序，当前查看的任务优先
			local LeftQuestShow = _G.WorldMapMgr:IsWorldMapShowQuest(Left.QuestID)
			local RightQuestShow = _G.WorldMapMgr:IsWorldMapShowQuest(Right.QuestID)
			if LeftQuestShow ~= RightQuestShow then
				if LeftQuestShow then return true end
				if RightQuestShow then return false end
			end

			-- 按任务追踪状态排序，追踪任务优先
			local LeftQuestTrack = self:IsTrackQuest(Left.QuestID) or self:IsFollowQuest(Left.QuestID)
			local RightQuestTrack = self:IsTrackQuest(Right.QuestID) or self:IsFollowQuest(Right.QuestID)
			if LeftQuestTrack ~= RightQuestTrack then
				if LeftQuestTrack then return true end
				if RightQuestTrack then return false end
			end

			-- 按任务接取状态排序，接取任务优先
			local LeftQuestStatus = _G.QuestMgr:GetQuestStatus(Left.QuestID)
			local RightQuestStatus = _G.QuestMgr:GetQuestStatus(Right.QuestID)
			if LeftQuestStatus ~= RightQuestStatus then
				return LeftQuestStatus > RightQuestStatus
			end

			-- 按任务类型排序，类型小（规则：主线>重要支线>普通支线）的优先
			local LeftQuestType = _G.QuestMgr:GetQuestType(Left.QuestID)
			local RightQuestType = _G.QuestMgr:GetQuestType(Right.QuestID)
			if LeftQuestType ~= RightQuestType then
				return LeftQuestType < RightQuestType
			end

			-- 按任务ID排序，ID小的优先
			if Left.QuestID ~= Right.QuestID then
				return Left.QuestID < Right.QuestID
			end
			return false
		end)
	end

	-- 获取映射到当前地图的任务
	local function GetMappingQuest()
		local MappingMapCfgList = _G.WorldMapMgr:FindMappingMapCfgList(self.MapID, self.UIMapID)
		if not MappingMapCfgList then
			return
		end

		local ShowMappingQuestList = nil
		for _, MappingMapCfg in ipairs(MappingMapCfgList) do
			-- 主角已经在目标地图内，查看地图时不显示映射任务，否则才显示映射任务
			if MappingMapCfg.UIMapID ~= _G.MapMgr:GetUIMapID() then
				-- add by sammrli 兜底,确保矫正地图的地图数据初始化一次
				_G.QuestTrackMgr:TryInitQuestParams(MappingMapCfg.MapID)
				-- 映射到当前地图的任务列表
				local MappingQuestList = _G.QuestTrackMgr:GetMapQuestList(MappingMapCfg.MapID)
				--print("[MapMarkerProviderQuest] GetMappingQuest MappingQuestList=%s", table.tostring_block(MappingQuestList))
				if #MappingQuestList > 0 then
					SortQuestList(MappingQuestList)

					for _, Quest in ipairs(MappingQuestList) do
						if Quest.UIMapID == MappingMapCfg.UIMapID then --可能是同mapid不同uimapid，这里加多个限制
							local ShowMappingQuest = table.deepcopy(Quest)
							ShowMappingQuest.IsMapping = true
							ShowMappingQuest.MappingMapCfg = MappingMapCfg

							if not ShowMappingQuestList then
								ShowMappingQuestList = {}
							end
							table.insert(ShowMappingQuestList, ShowMappingQuest)
							-- 限制显示5个
							if #ShowMappingQuestList >= 5 then
								break
							end
						end
					end
				end
			end
		end

		return ShowMappingQuestList
	end

	-- 获取一级、二级地图要显示的任务列表
	local function GenShowQuestList(IsRegionMap)
		local ShowQuestList = {}

		-- 追踪中的已接取任务
		for i = 1, #TrackingQuestList do
			local MapQuestParam = TrackingQuestList[i]
			table.insert(ShowQuestList, MapQuestParam)
		end

		-- 追踪中的未接取任务
		local FollowQuest = self:GetFollowQuest()
		if FollowQuest then
			table.insert(ShowQuestList, FollowQuest)
		end

		-- 主线任务去重，过滤掉追踪中的
		for i = 1, #MainlimeQuestList do
			local MapQuestParam = MainlimeQuestList[i]
			if not self:IsTrackQuest(MapQuestParam.QuestID)
				and not self:IsFollowQuest(MapQuestParam.QuestID) then
				table.insert(ShowQuestList, MapQuestParam)
			end
		end

		if IsRegionMap then
			local NewShowQuestList = {}
			for i = 1, #ShowQuestList do
				local Quest = ShowQuestList[i]
				local MappingMapCfg = _G.WorldMapMgr:FindMappingMapCfgByMapID(Quest.MapID)
				-- 一级地图不需要映射
				-- 二级地图，如果任务所在地图需要映射显示
				-- 主角已经在目标地图内，查看地图时不显示映射任务，否则才显示映射任务
				if MappingMapCfg then
					if MappingMapCfg.UIMapID ~= _G.MapMgr:GetUIMapID() then
						-- 地图映射任务需要修改任务数据，任务本身的数据不能修改，这里copy一份用于显示
						local ShowMappingQuest = table.deepcopy(Quest)
						ShowMappingQuest.IsMapping = true
						ShowMappingQuest.MappingMapCfg = MappingMapCfg
						table.insert(NewShowQuestList, ShowMappingQuest)
					end
				else
					table.insert(NewShowQuestList, ShowQuestList[i])
				end
			end

			ShowQuestList = NewShowQuestList
		end

		SortQuestList(ShowQuestList)
		--print("[MapMarkerProviderQuest] GenShowQuestList ShowQuestList", table.tostring_block(ShowQuestList))

		return ShowQuestList
	end

	if MapUtil.IsAreaMap(self.UIMapID) then
		local MapID = self.MapID
		if nil == MapID or 0 == MapID then
			return
		end
		-- 校正动态地图ID，比如当前所在沙之家是动态地图1072，任务查找要用原始地图1065
		local DynamicMapID = _G.NavigationPathMgr:RejustDynamicMap(self.MapID)
		-- 当前地图的任务
		local QuestList = _G.QuestTrackMgr:GetMapQuestList(DynamicMapID)
		if nil == QuestList then
			return
		end
		--print("[MapMarkerProviderQuest] CreateQuestMarkers QuestList=%s", table.tostring_block(QuestList))
		for i = 1, #QuestList do
			local Quest = QuestList[i]
			if nil ~= Quest.Pos and Quest.UIMapID == self.UIMapID then
				local Marker = self:OnCreateMarker(Quest)
				table.insert(MapMarkers, Marker)
			end
		end

		-- 映射到当前地图的任务，主要是沙之家的任务要映射到西萨纳兰的问题
		local MappingQuestList = GetMappingQuest()
		if MappingQuestList then
			for _, Quest in ipairs(MappingQuestList) do
				if nil ~= Quest.Pos then
					local Marker = self:OnCreateMarker(Quest)
					table.insert(MapMarkers, Marker)
				end
			end
		end

	elseif MapUtil.IsRegionMap(self.UIMapID) then

		local function CreateQuestMarker(QuestList)
			local AreaUIMapExists = {} -- 任务在同一个地图时要去重显示

			for i = 1, #QuestList do
				local Quest = QuestList[i]
				if nil ~= Quest.Pos then
					local AreaUIMapID = Quest.UIMapID
					if Quest.IsMapping and Quest.MappingMapCfg then
						AreaUIMapID = Quest.MappingMapCfg.MappingUIMapID
					end

					local RegionUIMapID = MapUtil.GetUpperUIMapID(AreaUIMapID)
					if RegionUIMapID == self.UIMapID then
						if not AreaUIMapExists[AreaUIMapID] then
							AreaUIMapExists[AreaUIMapID] = true

							local Marker = self:OnCreateMarker(Quest)
							local SetPosResult = MapUtil.SetRegionUIPos(Marker, self.UIMapID, AreaUIMapID)
							if SetPosResult then
								table.insert(MapMarkers, Marker)
							end
						end
					end
				end
			end
		end

		local ShowQuestList = GenShowQuestList(true)
		CreateQuestMarker(ShowQuestList)

	elseif MapUtil.IsWorldMap(self.UIMapID) then

		local function CreateQuestMarker(QuestList)
			local RegionUIMapExists = {} -- 任务在同一个地图时要去重显示

			for i = 1, #QuestList do
				local Quest = QuestList[i]
				if nil ~= Quest.Pos then
					local AreaUIMapID = Quest.UIMapID
					if Quest.IsMapping and Quest.MappingMapCfg then
						AreaUIMapID = Quest.MappingMapCfg.MappingUIMapID
					end

					local RegionUIMapID = MapUtil.GetUpperUIMapID(AreaUIMapID)
					if RegionUIMapID and not RegionUIMapExists[RegionUIMapID] then
						RegionUIMapExists[RegionUIMapID] = true

						local Marker = self:OnCreateMarker(Quest)
						MapUtil.SetWorldUIPos(Marker, self.UIMapID, RegionUIMapID)
						table.insert(MapMarkers, Marker)
					end
				end
			end
		end

		local ShowQuestList = GenShowQuestList()
		CreateQuestMarker(ShowQuestList)
	end

	self:UpdateQuestPriority(MapMarkers)

	return MapMarkers
end

function MapMarkerProviderQuest:UpdateAllQuest()
	self:ClearMarkers()
	self:UpdateMarkers()
end

function MapMarkerProviderQuest:UpdateQuest(Params)
	if nil == Params then
		return
	end

	if Params.bOnConditionUpdate then
		local QuestID = Params.QuestID
		if QuestID then
			self:UpdateQuestIcon(QuestID)
		else
			self:UpdateAllQuest()
			return
		end
	else
		local RemovedQuestList = Params.RemovedQuestList
		if nil ~= RemovedQuestList then
			for i = 1, #RemovedQuestList do
				local Quest = RemovedQuestList[i]
				self:RemoveMarker({ QuestID = Quest.QuestID, TargetID = Quest.TargetID })
			end
		end

		local UpdatedQuestList = Params.UpdatedQuestList
		if nil ~= UpdatedQuestList then
			for i = 1, #UpdatedQuestList do
				local Quest = UpdatedQuestList[i]
				local QuestID = Quest.QuestID
				local Marker = self:FindMarker({ QuestID = QuestID, TargetID = Quest.TargetID })
				if nil ~= Marker then
					self:OnUpdateQuestIcon(Marker, QuestID)
				else
					if nil ~= Quest.Pos and Quest.UIMapID == self.UIMapID then
						self:AddMarker(Quest)
					end
				end
			end
		end
	end

	self:UpdateQuestPriority(self.MapMarkers)
end

---更新任务标记显示优先级
function MapMarkerProviderQuest:UpdateQuestPriority(MapMarkers)
	if nil == MapMarkers then
		return
	end

	local Quest2MapMarkerMap = {}
	local Npc2QuestListMap = {}

	for i = 1, #MapMarkers do
		local Marker = MapMarkers[i]
		local MapQuestParamClass = Marker.MapQuestParamClass
		if MapQuestParamClass.NaviType == QuestNaviType.NpcResID and MapQuestParamClass.NaviObjID > 0 then
			Quest2MapMarkerMap[MapQuestParamClass] = Marker

			local NpcID = MapQuestParamClass.NaviObjID
			local NpcQuestList = Npc2QuestListMap[NpcID]
			if NpcQuestList == nil then
				Npc2QuestListMap[NpcID] = {}
				NpcQuestList = Npc2QuestListMap[NpcID]
			end
			table.insert(NpcQuestList, MapQuestParamClass)
		end
	end

	for _, NpcQuestList in pairs(Npc2QuestListMap) do
		local QuestCount = #NpcQuestList
		if QuestCount > 1 then
			-- 同一个位置存在多个任务时，按规则排序，调整任务标记显示优先级
			table.sort(NpcQuestList, _G.QuestMgr.QuestRegister.NpcQuestComp)

			for Index, MapQuestParamClass in ipairs(NpcQuestList) do
				local Marker = Quest2MapMarkerMap[MapQuestParamClass]
				Marker:SetOverlayPriority(QuestCount - Index + 1)
			end
		end
	end

	_G.EventMgr:SendEvent(_G.EventID.MapMarkerPriorityUpdate)
end

function MapMarkerProviderQuest:UpdateQuestIcon(QuestID)
	local MapMarkers = self.MapMarkers
	if nil == MapMarkers then
		return
	end
	for i = 1, #MapMarkers do
		local Marker = MapMarkers[i]
		if Marker:GetID() == QuestID then
			self:OnUpdateQuestIcon(Marker, QuestID)
		end
	end
end

function MapMarkerProviderQuest:OnUpdateQuestIcon(Marker, QuestID)
	if nil == Marker then
		return
	end

	local IconPath = _G.QuestMgr:GetQuestIconAtMap(QuestID)
	--_G.FLOG_INFO("[MapMarkerProviderQuest] OnUpdateQuestIcon QuestID=%d IconPath=%s", QuestID, IconPath)
	Marker:SetIconPath(IconPath)
	self:SendUpdateMarkerEvent(Marker)
end

function MapMarkerProviderQuest:TrackQuestChanged(QuestID)
	self.TrackingQuestList = _G.QuestTrackMgr:GetTrackingQuestParam()
	--print("[MapMarkerProviderQuest] TrackQuestChanged", table.tostring_block(self.TrackingQuestList))

	local MapMarkers = self.MapMarkers
	if nil == MapMarkers then
		return
	end
	for i = 1, #MapMarkers do
		local Marker = MapMarkers[i]
		local IsTrack = Marker:GetID() == QuestID
		if IsTrack ~= Marker:GetIsTrackQuest() then
			Marker:SetIsTrackQuest(IsTrack)
			self:SendUpdateMarkerEvent(Marker)
		end
	end

	self:UpdateQuestPriority(self.MapMarkers)
end

---获取当前UIMapID的追踪任务
function MapMarkerProviderQuest:GetFollowQuest()
	local FollowInfo = _G.WorldMapMgr:GetMapFollowInfo()
	if FollowInfo == nil  then
		return
	end
	if FollowInfo.FollowType ~= self:GetMarkerType() then
		return
	end
	local FollowQuestID = FollowInfo.FollowID
	local FollowUIMapID = FollowInfo.FollowUIMapID
	local FollowMapID = FollowInfo.FollowMapID

	_G.QuestTrackMgr:TryInitQuestParams(FollowMapID) --兜底，如果任务没有追踪数据则初始化

	local MapQuestParams = _G.QuestTrackMgr:GetMapQuestParam(FollowMapID, FollowQuestID, 0)
	local FollowQuest = nil -- 追踪中的未接取任务
	if MapQuestParams and #MapQuestParams > 0 then
		FollowQuest = MapQuestParams[1]
	end
	return FollowQuest, FollowUIMapID
end

---获取当前UIMapID的任务追踪标记，追踪任务实现方式有不同，目前未用到
---@deprecated
---@return Marker
function MapMarkerProviderQuest:GetFollowMarker()
	local FollowQuest, FollowUIMapID = self:GetFollowQuest()
	if FollowQuest == nil then
		return
	end

	if MapUtil.IsAreaMap(self.UIMapID) then
		return

	elseif MapUtil.IsRegionMap(self.UIMapID) then
		-- 二级地图的追踪标记
		local RegionUIMapID = MapUtil.GetUpperUIMapID(FollowUIMapID)
		if RegionUIMapID == self.UIMapID then
			local Marker = self:OnCreateMarker(FollowQuest)
			local SetPosResult = MapUtil.SetRegionUIPos(Marker, self.UIMapID, FollowUIMapID)
			if not SetPosResult then
				return
			end
			return Marker
		end

	elseif MapUtil.IsWorldMap(self.UIMapID) then
		-- 一级地图的追踪标记
		local RegionUIMapID = MapUtil.GetUpperUIMapID(FollowUIMapID)
		if RegionUIMapID then
			local Marker = self:OnCreateMarker(FollowQuest)
			MapUtil.SetWorldUIPos(Marker, self.UIMapID, RegionUIMapID)
			return Marker
		end
	end
end

-- 任务可以有多个目标，仅通过QuestID不能定位一个任务，需要配合TargetID
function MapMarkerProviderQuest:FindMarker(Params)
	local Marker = table.find_by_predicate(self.MapMarkers, function(Marker)
		return Marker:GetID() == Params.QuestID and Marker:GetTargetID() == Params.TargetID
	end)
	return Marker
end

-- 更新地图追踪标记
function MapMarkerProviderQuest:UpdateFollowMarker(FollowInfo)
	if FollowInfo == nil then
		return
	end

	if MapUtil.IsAreaMap(self.UIMapID) then
		local Params = { QuestID = FollowInfo.FollowID, TargetID = 0 } -- 未接取任务的TargetID为0
		local Marker = self:FindMarker(Params)
		if Marker then
			Marker:UpdateFollow()
			self:SendUpdateMarkerEvent(Marker)
		end
	else
		_G.EventMgr:SendEvent(_G.EventID.WorldMapUpdateAllMarker)
	end
end

return MapMarkerProviderQuest