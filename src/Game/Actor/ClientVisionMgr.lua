--------- 本地Actor的视野管理
---

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local ClientActorFactory = require("Game/Actor/ClientActorFactory")
-- local MapCfg = require("TableCfg/MapCfg")
local VisionPworldMonsterWhitelistCfg = require("TableCfg/VisionPworldMonsterWhitelistCfg")

local CS_CMD = ProtoCS.CS_CMD
local PWORLD_CMD = ProtoCS.CS_PWORLD_CMD
local EActorType = _G.UE.EActorType
local FLOG_WARNING = _G.FLOG_WARNING
local EventID = _G.EventID

--对应于MapEditCfg中的那些，有需要的新增
--因为MapEditCfg中不同的类型，可能MapEditorID是相同的


--对于一个MapEditorID，并不能定义一个具体的种植物；  得要结合种植物类型、MapID
--因为关卡编辑器，对于不同类型，不同地图，可能MapEditorID相同

--格子大小20米，视野按类型配置（目前采集物20米，客户端npc50米）

---@class ClientVisionMgr : MgrBase
local ClientVisionMgr = LuaClass(MgrBase)

local UActorManager = nil
local UWorldMgr = nil
local MapEditorActorConfig = nil

function ClientVisionMgr:OnInit()
	self.MapEditorIDToEntityID = {}

	--默认虚拟块是20米的方块
	self.MapVirtualTileSize = 2000

	MapEditorActorConfig = _G.MapEditorActorConfig
end

function ClientVisionMgr:OnBegin()
	--新增ClientActor类型的时候，要注意这两个映射的处理
	self.EntityIDToEditorID = {}
	self.MapEditorIDToEntityID = {}
	self.ClientActorNeedServerEntityID = {}
	for _, ActorConfig in pairs(MapEditorActorConfig) do
		self.MapEditorIDToEntityID[ActorConfig.ActorType] = {}
		self.ClientActorNeedServerEntityID[ActorConfig.ActorType] = {}
	end

    if UActorManager == nil then
        UActorManager = _G.UE.UActorManager.Get()
    end
	
    if UWorldMgr == nil then
        UWorldMgr = _G.UE.UWorldMgr.Get()
    end

	ClientActorFactory:Init()

	--======  纳入视野管理的，类似处理就好 ===============
	--将CurMapEditCfg.PickItemList数组转换为下面的形式
	--  [地图块索引X][地图块索引Y] = {}   --CurMapEditCfg.PickItemList数组的index列表
	-- self.GatherTileData = {}

	self.bNoTick = false

	self.VisionWhitelist = nil
end

function ClientVisionMgr:OnEnd()
	ClientActorFactory:UnInit()

    if self.TickTimerHandler then
        _G.TimerMgr:CancelTimer(self.TickTimerHandler)
		self.TickTimerHandler = nil
    end

	-- self.GatherTileData = {}
	self:Clear()
end

function ClientVisionMgr:OnShutdown()
end

function ClientVisionMgr:OnRegisterNetMsg()
end

function ClientVisionMgr:OnRegisterGameEvent()
	-- self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)

    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventPWorldMapEnter)
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventPWorldMapExit)
	self:RegisterGameEvent(EventID.PWorldExit, self.OnGameEventPWorldExit)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
end

function ClientVisionMgr:ResetMap()
	print("ClientVisionMgr:ResetMap")
	if not self.MajorTileX or not self.MajorTileY then
		return
	end

	-- 断线重连调用至此处时，sequence有可能正用到场景里的客户端actor，故不做后续清理。https://tapd.woa.com/tapd_fe/20420083/bug/detail/1020420083139483025
	if _G.StoryMgr:SequenceIsPlaying() then
		return
	end

	for _, ActorConfig in pairs(MapEditorActorConfig) do
		local VirtualTileOffset = math.ceil(ActorConfig.ViewSize / self.MapVirtualTileSize)
		for X = self.MajorTileX - VirtualTileOffset, self.MajorTileX + VirtualTileOffset do
			for Y = self.MajorTileY - VirtualTileOffset, self.MajorTileY + VirtualTileOffset do
				if self[ActorConfig.TileDataKey][X] and self[ActorConfig.TileDataKey][X][Y] then
					local ActorIdxList = self[ActorConfig.TileDataKey][X][Y]
					for i = 1, #ActorIdxList do
						local ActorData = self.CurMapEditCfg[ActorConfig.MapEditCfgKey][ActorIdxList[i]]
						if ActorData then
							local MapEditorID = ActorData[ActorConfig.MapEditorIDKey]
							ClientVisionMgr:ClientActorLeaveVision(MapEditorID, ActorConfig.ActorType)
						end
					end
				end
			end
		end

		self[ActorConfig.TileDataKey] = {}
	end

	self.CurMapEditCfg = nil
end

--切图前清理Actor
function ClientVisionMgr:Clear()
	print("ClientVisionMgr:Clear Actors")

	for _, ActorConfig in pairs(MapEditorActorConfig) do
		for _, EntityID in pairs(self.MapEditorIDToEntityID[ActorConfig.ActorType]) do
			self:DestoryClientActor(EntityID, ActorConfig.ActorType)
		end

		self.MapEditorIDToEntityID[ActorConfig.ActorType] = {}
		self.ClientActorNeedServerEntityID[ActorConfig.ActorType] = {}
	end

    self.EntityIDToEditorID = {}
end

--private
--先进去就创建出来，后续再搞视野以及通用各种种植物的事情  todo
function ClientVisionMgr:OnMapLoaded()
    self.CurMapEditCfg = _G.MapEditDataMgr:GetMapEditCfg()
    if (self.CurMapEditCfg == nil) then
        return
    end
	print("ClientVisionMgr:OnMapLoaded")

	-- local NpcList = self.CurMapEditCfg.NpcList
	-- if NpcList then
	-- 	for i = #NpcList, 1, -1 do
	-- 		local NpcInfo = NpcList[i]
	-- 		if not NpcInfo.IsHide then
	-- 			table.remove(NpcList, i)
	-- 		end
	-- 	end
	-- end

	-- local EObjList = self.CurMapEditCfg.EObjList
	-- if EObjList then
	-- 	for i = #EObjList, 1, -1 do
	-- 		local EObjInfo = EObjList[i]
	-- 		if not EObjInfo.IsHide then
	-- 			table.remove(EObjList, i)
	-- 		end
	-- 	end
	-- end

    ClientActorFactory:OnMapLoaded(self.CurMapEditCfg)

    if not self.TickTimerHandler then
        self.TickTimerHandler = self:RegisterTimer(self.VisionTick, 0, 1, 0)
    end
	-- self:LoadPickItems()
	-- ClientActorFactory:LoadPickItem(self.CurMapEditCfg)

	--不读地图表了
	-- local CurrMapTableCfg = _G.PWorldMgr:GetCurrMapTableCfg()
	-- if CurrMapTableCfg then
	-- 	self.ViewSize = CurrMapTableCfg.VisionSize
	-- 	if not self.ViewSize or self.ViewSize <= 0 then
	-- 		self.ViewSize = 3000
	-- 	end
	-- end

	--======  纳入视野管理的，类似处理就好 ===============
	--将CurMapEditCfg.PickItemList数组转换为下面的形式
	--  [地图块索引X][地图块索引Y] = {}   --CurMapEditCfg.PickItemList数组的index列表

	self.GatherTileMinX = 100000000
	self.GatherTileMinY = 100000000
	self.GatherTileMaxX = -100000000
	self.GatherTileMaxY = -100000000

	for _, ActorConfig in pairs(MapEditorActorConfig) do
		self[ActorConfig.TileDataKey] = self[ActorConfig.TileDataKey] or {}

		local IsGather = false
		if ActorConfig.ActorType == _G.UE.EActorType.Gather then
			IsGather = true
		end
		
		if self.CurMapEditCfg[ActorConfig.MapEditCfgKey] then
			for Index, ActorInfo in ipairs(self.CurMapEditCfg[ActorConfig.MapEditCfgKey]) do
				--虚拟块索引动态生成
				local X = math.floor(ActorInfo[ActorConfig.PointKey].X / self.MapVirtualTileSize)
				local Y = math.floor(ActorInfo[ActorConfig.PointKey].Y / self.MapVirtualTileSize)
				
				if IsGather then
					if X < self.GatherTileMinX then
						self.GatherTileMinX = X
					end

					if X > self.GatherTileMaxX then
						self.GatherTileMaxX = X
					end

					if Y < self.GatherTileMinY then
						self.GatherTileMinY = Y
					end

					if Y > self.GatherTileMaxY then
						self.GatherTileMaxY = Y
					end
				end
				
				self[ActorConfig.TileDataKey][X] = self[ActorConfig.TileDataKey][X] or {}
				self[ActorConfig.TileDataKey][X][Y] = self[ActorConfig.TileDataKey][X][Y] or {}
		
				local TileDataTable = self[ActorConfig.TileDataKey][X][Y]
		
				table.insert(TileDataTable, Index)
			end
		end

		-- FLOG_INFO("Gather IdxRange: (MinX:%d, MinY:%d, MaxX:%d, MaxY:%d)",
		-- 	self.GatherTileMinX, self.GatherTileMinY, self.GatherTileMaxX, self.GatherTileMaxY)
	end
	
	self:EnableTick(true)
	self:VisionTick()
end

--private
--服务器也是二维的
function ClientVisionMgr:IsOutViewSquareDistance(MajorPos, Point, ViewSquareDistance)
	local XLen = MajorPos.x - Point.X
	local YLen = MajorPos.Y - Point.Y
	local SquareDistance = XLen * XLen + YLen * YLen

	if SquareDistance > ViewSquareDistance then
		return true
	end

	return false
end

--private
function ClientVisionMgr:VisionTick()
	if not self.CurMapEditCfg then
		-- FLOG_ERROR("ClientVisionMgr VisionTick CurMapEditCfg Error")
		return
	end

	if self.bNoTick then
		return
	end

	local MajorActor = MajorUtil.GetMajor()

	if not MajorActor or not UWorldMgr then
		return
	end

	self.OriginLocation = UWorldMgr:GetOriginLocation()

	local MajorPos = MajorActor:FGetActorLocation()
	MajorPos.X = MajorPos.X + self.OriginLocation.X
	MajorPos.Y = MajorPos.Y + self.OriginLocation.Y
	self.MajorTileX = math.floor(MajorPos.X / self.MapVirtualTileSize)
	self.MajorTileY = math.floor(MajorPos.Y / self.MapVirtualTileSize)
	local bGatherProf = MajorUtil.IsGatherProf()

	--遍历该地图块上的所有 客户端视野管理的类型
	for _, ActorConfig in pairs(MapEditorActorConfig) do
		--采集点的比较特殊，小地图上的采集点图标不是按视野的，是比视野大比较多的范围
		if ActorConfig.ActorType == _G.UE.EActorType.Gather and bGatherProf then
			local TileOffset = math.ceil(ActorConfig.MiniMapViewSize / self.MapVirtualTileSize)
			local SquareDistance = ActorConfig.MiniMapViewSize * ActorConfig.MiniMapViewSize
			for X = self.MajorTileX - TileOffset, self.MajorTileX + TileOffset do
				for Y = self.MajorTileY - TileOffset, self.MajorTileY + TileOffset do
					if self[ActorConfig.TileDataKey][X] and self[ActorConfig.TileDataKey][X][Y] then
						local ActorIdxList = self[ActorConfig.TileDataKey][X][Y]
						for i = 1, #ActorIdxList do
							local ActorData = self.CurMapEditCfg[ActorConfig.MapEditCfgKey][ActorIdxList[i]]
							if ActorData then
								if self:IsOutViewSquareDistance(MajorPos, ActorData[ActorConfig.PointKey], SquareDistance) then
									--离开小地图
									_G.GatherMgr:GatherLeaveMiniMap(ActorData)
								else
									--进入小地图
									_G.GatherMgr:GatherEnterMiniMap(ActorData)
								end
							end
						end
					end
				end
			end
		end

		local VirtualTileOffset = math.ceil(ActorConfig.ViewSize / self.MapVirtualTileSize)
		local ViewSquareDistance = ActorConfig.ViewSize * ActorConfig.ViewSize
		for X = self.MajorTileX-VirtualTileOffset, self.MajorTileX+VirtualTileOffset do
			for Y = self.MajorTileY-VirtualTileOffset, self.MajorTileY+VirtualTileOffset do
				if self[ActorConfig.TileDataKey][X] and self[ActorConfig.TileDataKey][X][Y] then
					local ActorIdxList = self[ActorConfig.TileDataKey][X][Y]
					for i = 1, #ActorIdxList do
						local ActorData = self.CurMapEditCfg[ActorConfig.MapEditCfgKey][ActorIdxList[i]]
						if ActorData then
							local MapEditorID = ActorData[ActorConfig.MapEditorIDKey]
							if self:IsOutViewSquareDistance(MajorPos, ActorData[ActorConfig.PointKey], ViewSquareDistance) then
								--离开视野
								ClientVisionMgr:ClientActorLeaveVision(MapEditorID, ActorConfig.ActorType)
							elseif not ActorData.bFutureVersion then --nil:要进行读表刷新为true/false   true：不创建  false：正常创建的
								--进入视野 (如果不满足条件了，会自动释放掉离开视野)
								self:ClientActorEnterVision(ActorData, ActorConfig.ActorType)
								-- local EntityID = self.MapEditorIDToEntityID[ActorConfig.ActorType][MapEditorID]
								-- if not EntityID then
								-- 	self:ClientActorEnterVision(ActorData, ActorConfig.ActorType)
								-- end
							end
						else
							FLOG_ERROR("ClientVisionMgr ActorType(%d) index(%d) is error", ActorConfig.ActorType, i)
						end
					end
				end
			end
		end
	end
end

--基于BaseActor找ActorType类型的ListID
function ClientVisionMgr:GetActorMapEditInfo(ListID, ActorType, BaseActor)
	if not self.CurMapEditCfg or not BaseActor or not UWorldMgr then
		return
	end

	self.OriginLocation = UWorldMgr:GetOriginLocation()

	local MajorPos = BaseActor:FGetActorLocation()
	MajorPos.X = MajorPos.X + self.OriginLocation.X
	MajorPos.Y = MajorPos.Y + self.OriginLocation.Y
	self.MajorTileX = math.floor(MajorPos.X / self.MapVirtualTileSize)
	self.MajorTileY = math.floor(MajorPos.Y / self.MapVirtualTileSize)

	--遍历该地图块上的所有 客户端视野管理的类型
	for _, ActorConfig in pairs(MapEditorActorConfig) do
		if ActorConfig.ActorType == ActorType then
			for X = self.MajorTileX-1, self.MajorTileX+1 do
				for Y = self.MajorTileY-1, self.MajorTileY+1 do
					if self[ActorConfig.TileDataKey][X] and self[ActorConfig.TileDataKey][X][Y] then
						local ActorIdxList = self[ActorConfig.TileDataKey][X][Y]
						for i = 1, #ActorIdxList do
							local ActorData = self.CurMapEditCfg[ActorConfig.MapEditCfgKey][ActorIdxList[i]]
							if ActorData then
								local MapEditorID = ActorData[ActorConfig.MapEditorIDKey]
								if MapEditorID == ListID then
									return ActorData
								end
							end
						end
					end
				end
			end
		end
	end

	return nil
end

--进入视野
--public
function ClientVisionMgr:ClientActorEnterVision(ActorInfo, ActorType)
	ClientActorFactory:ClientActorEnterVision(ActorInfo, ActorType)
end

---OnGameEventMajorCreate
---@param Params FEventParams
function ClientVisionMgr:OnGameEventMajorCreate(Params)
	-- local EntityID = Params.ULongParam1
	-- local RoleID = ActorUtil.GetRoleIDByEntityID(EntityID)
end

--private
function ClientVisionMgr:OnGameEventPWorldMapEnter(Params)
	-- self:EnableTick(true)
	self:ReadVisionWhitelistForPWorld(Params.CurrPWorldResID)
end

function ClientVisionMgr:OnGameEventPWorldMapExit(Params)
	-- FLOG_INFO("ClientVisionMgr:OnGameEventPWorldMapExit", Params)
	self:EnableTick(false)
	self:Clear()
end

function ClientVisionMgr:OnGameEventLoginRes(Params)
    if Params.bReconnect and not _G.StoryMgr:SequenceIsPlaying() then
		self:Clear()
		self:VisionTick()
    end
end

--private
function ClientVisionMgr:OnGameEventPWorldExit(Params)
	-- FLOG_INFO("ClientVisionMgr:OnGameEventPWorldExit", Params)
	self:Clear()
end

--public
function ClientVisionMgr:GetMapEditorIDByEntityID(EntityID)
	return self.EntityIDToEditorID[EntityID]
end

--必须传入MapEditorActorType，不同类型的MapEditorID可能相同
--public
function ClientVisionMgr:GetEntityIDByMapEditorID(MapEditorID, MapEditorActorType)
	if not MapEditorActorType then
		FLOG_ERROR("ClientVisionMgr GetEntityIDByMapEditorID need MapEditorActorType ")
		return
	end

	return self.MapEditorIDToEntityID[MapEditorActorType][MapEditorID]
end

--private
function ClientVisionMgr:DestoryClientActor(EntityID, MapEditorActorType)
	if not EntityID then
		return
	end

	-- lua侧不要抛视野事件，统一在C++侧处理，防止抛重复
	--离开视野的事件
	-- local Params = _G.EventMgr:GetEventParams()
	-- Params.BoolParam1 = false
	-- Params.ULongParam1 = EntityID
	
	-- local AttrComp = ActorUtil.GetActorAttributeComponent(EntityID)
	-- if AttrComp then
	-- 	Params.IntParam1 = AttrComp:GetActorType()
	-- 	Params.IntParam2 = AttrComp.ResID
	-- end
	-- _G.EventMgr:SendCppEvent(EventID.VisionLeave, Params)
	-- _G.EventMgr:SendEvent(EventID.VisionLeave, Params)

    ClientActorFactory:DestoryClientActor(EntityID, MapEditorActorType)

	local MapEditorID = self.EntityIDToEditorID[EntityID]
	if not MapEditorID then
		FLOG_WARNING("MapEditorID is nil")
		return 
	end

	self.EntityIDToEditorID[EntityID] = nil
	if MapEditorActorType then
		local TempTable = self.MapEditorIDToEntityID[MapEditorActorType]
		if (TempTable ~= nil) then
			_G.FLOG_INFO("ClientVisionMgr destroy actor ok (MapEditorID:%d)", MapEditorID)
			TempTable[MapEditorID] = nil
		end
	else
		for _, ActorConfig in pairs(MapEditorActorConfig) do
			local TempTable = self.MapEditorIDToEntityID[ActorConfig.ActorType]
			if TempTable ~= nil and TempTable[MapEditorID] == EntityID then
				_G.FLOG_INFO("ClientVisionMgr destroy actor ok (MapEditorID:%d)", MapEditorID)
				TempTable[MapEditorID] = nil
				break
			end
		end
	end
end

--public
function ClientVisionMgr:ClientActorLeaveVision(MapEditorID, MapEditorActorType)
	local EntityID = self:GetEntityIDByMapEditorID(MapEditorID, MapEditorActorType)

	if EntityID and EntityID > 0 then
		self:DestoryClientActor(EntityID, MapEditorActorType)
	end
end


--采集物的视野逻辑    运行时用不到
function ClientVisionMgr:LoadPickItems()
	if not self.CurMapEditCfg or not self.CurMapEditCfg.PickItemList then
		FLOG_ERROR("ClientVisionMgr LoadPickItem Error")
		return
	end

    for _, Gather in ipairs(self.CurMapEditCfg.PickItemList) do
		ClientActorFactory:LoadOnePickItem(Gather)
    end
end


--获取的只能是当前地图的MapEditorID，跨地图的会有重复，也取不到
--public
function ClientVisionMgr:GetEditorDataByEditorID(MapEditorID, ActorType)
	if not self.CurMapEditCfg then
		return nil
	end

	local ActorConfig = MapEditorActorConfig[ActorType]
	if ActorConfig then
		local ActorInfoList = self.CurMapEditCfg[ActorConfig.MapEditCfgKey] or {}
		for _, ActorInfo in ipairs(ActorInfoList) do
			if ActorInfo[ActorConfig.MapEditorIDKey] == MapEditorID then
				return ActorInfo
			end
		end
	end

	return nil
end

--private
function ClientVisionMgr:NotNeedServerEntityID(ActorType, MapEditorID, ResID)
	if nil == self.ClientActorNeedServerEntityID[ActorType]
	or 0 == (MapEditorID or 0)
	or 0 == (ResID or 0) then
		return true
	end

	local bNeedServerEntityID = self.ClientActorNeedServerEntityID[ActorType][MapEditorID]
	if nil == bNeedServerEntityID then
		bNeedServerEntityID = UActorManager:IsClientActorNeedServerEntityID(ActorType or EActorType.MaxType, MapEditorID, ResID)
		self.ClientActorNeedServerEntityID[ActorType][MapEditorID] = bNeedServerEntityID
	end

	return not bNeedServerEntityID
end

--第2个参数可以不传，然后根据MapEditorID去查找
--private
function ClientVisionMgr:DoClientActorEnterVision(MapEditorID, MapEditorData, ActorConfig, ResID)
    --_G.FLOG_INFO("ClientVisionMgr DoClientActorEnterVision MapEditorID:%d", MapEditorID)
	if (MapEditorID == nil) then
		_G.FLOG_ERROR("DoClientActorEnterVision 失败，传入的 MapEditorID 为空，请检查")
		return nil
	end
	if (ActorConfig == nil) then
		_G.FLOG_ERROR("DoClientActorEnterVision 失败，传入的 ActorConfig 为空，请检查")
		return nil
	end
	local ActorType = ActorConfig.ActorType
	local EntityID = self.MapEditorIDToEntityID[ActorType][MapEditorID]

	MapEditorData = MapEditorData or self:GetEditorDataByEditorID(EntityID, ActorConfig.ConfigType)

	if not EntityID then
		if self:NotNeedServerEntityID(ActorType, MapEditorID, ResID)
		or UActorManager:IsListIDPreAllocated(MapEditorID) then
			EntityID = ClientActorFactory:CreateClientActor(MapEditorID, MapEditorData, ActorConfig)
		else
			_G.FLOG_ERROR("ClientVisionMgr Error %d", MapEditorID)
		end
	elseif ActorType ~= _G.UE.EActorType.Gather then
		_G.FLOG_INFO("ClientVisionMgr %d-%d", MapEditorID, EntityID)
	end

	if EntityID then
		self.MapEditorIDToEntityID[ActorType][MapEditorID] = EntityID
		self.EntityIDToEditorID[EntityID] = MapEditorID
	end

	return EntityID
end

function ClientVisionMgr:CheckGatherPointCanPick(ActorIdxList)
	for i = 1, #ActorIdxList do
		local Data = self.CurMapEditCfg.PickItemList[ActorIdxList[i]]

		local bCan, bReadDB = _G.GatherMgr:GatherCanPick(Data, self.CurMapEditCfg.MapID, true)

		if bReadDB then
			self.CheckGatherPointCnt = self.CheckGatherPointCnt + 1
		end

		if bCan then
			return Data
		end
	end

	return nil
end

function ClientVisionMgr:FindNearestGatherPointOutVision()
	if not self.CurMapEditCfg then
		FLOG_ERROR("ClientVisionMgr CurMapEditCfg nil")
		return nil
	end

	if not self.CurMapEditCfg.PickItemList or #self.CurMapEditCfg.PickItemList == 0 then
		FLOG_WARNING("not config PickItemList")
		return nil
	end

	local MajorActor = MajorUtil.GetMajor()
	if not MajorActor or not UWorldMgr then
		return nil
	end

	self.OriginLocation = UWorldMgr:GetOriginLocation()

	local MajorPos = MajorActor:FGetActorLocation()
	MajorPos.X = MajorPos.X + self.OriginLocation.X
	MajorPos.Y = MajorPos.Y + self.OriginLocation.Y
	self.MajorTileX = math.floor(MajorPos.X / self.MapVirtualTileSize)
	self.MajorTileY = math.floor(MajorPos.Y / self.MapVirtualTileSize)

	local ActorConfig = MapEditorActorConfig.Gather
	local VirtualTileOffset = math.ceil(ActorConfig.ViewSize / self.MapVirtualTileSize)

	local MaxForCount = math.max(self.MajorTileX - self.GatherTileMinX, self.GatherTileMaxX - self.MajorTileX)
	local MaxForCountY = math.max(self.MajorTileY - self.GatherTileMinY, self.GatherTileMaxY - self.MajorTileY)
	if MaxForCountY > MaxForCount then
		MaxForCount = MaxForCountY
	end

	FLOG_INFO("Gather FindNearestGatherPoint MaxForCount:%d, GatherCnt:%d, MajorTileX=%d, MajorTileY=%d"
		, MaxForCount, #self.CurMapEditCfg.PickItemList, self.MajorTileX, self.MajorTileY)

	self.CheckGatherPointCnt = 0

	--水平方向检测
	local function CheckGatherPointH(MinTileX, MaxTileX, TileY)
		if MinTileX > MaxTileX then
			return nil
		end

		-- FLOG_INFO("GatherH X: %d -> %d, y: %d", MinTileX, MaxTileX, TileY)
		for idx = MinTileX, MaxTileX do
			if self.GatherTileData[idx] and self.GatherTileData[idx][TileY] then
				local Data = self:CheckGatherPointCanPick(self.GatherTileData[idx][TileY])
				if Data then
					FLOG_INFO("Gather =====  TileX:%d, TileY:%d", idx, TileY)
					return Data
				end
			end
		end

		return nil
	end
	
	--垂直方向检测
	local function CheckGatherPointV(MinTileY, MaxTileY, TileX)
		if MinTileY > MaxTileY then
			return nil
		end

		-- FLOG_INFO("GatherV y: %d -> %d, X: %d", MinTileY, MaxTileY, TileX)
		for idx = MinTileY, MaxTileY do
			if self.GatherTileData[TileX] and self.GatherTileData[TileX][idx] then
				local Data = self:CheckGatherPointCanPick(self.GatherTileData[TileX][idx])
				if Data then
					FLOG_INFO("Gather =====  TileX:%d, TileY:%d", TileX, idx)
					return Data
				end
			end
		end
		
		return nil
	end

	-- local IdxList = {}
	for index = -1, MaxForCount do
		-- IdxList = {}
		local XMin = self.MajorTileX - VirtualTileOffset - index
		local XMax = self.MajorTileX + VirtualTileOffset + index
		local YMin = self.MajorTileY - VirtualTileOffset - index
		local YMax = self.MajorTileY + VirtualTileOffset + index

		local X = math.ceil((XMax - XMin) / 4)
		local Y = math.ceil((YMax - YMin) / 4)
		-- FLOG_INFO("Gather For Count：%d XMin：%d, XMax:%d, YMin:%d, YMax:%d, X/4=%d, Y/4=%d"
		-- 	, index + 2, XMin, XMax, YMin, YMax,  X, Y)

		--4条边上中间的一部分
		local Data = CheckGatherPointH(XMin + X, XMax - X, YMin)
		if Data then return Data end

		Data = CheckGatherPointH(XMin + X, XMax - X, YMax)
		if Data then return Data end
		
		Data = CheckGatherPointV(YMin + Y, YMax - Y, XMin)
		if Data then return Data end
		
		Data = CheckGatherPointV(YMin + Y, YMax - Y, XMax)
		if Data then return Data end

		--上下边水平方向的左右两段
		Data = CheckGatherPointH(XMin, XMin + X - 1, YMin)
		if Data then return Data end

		Data = CheckGatherPointH(XMax - X + 1, XMax, YMin)
		if Data then return Data end

		Data = CheckGatherPointH(XMin, XMin + X - 1, YMax)
		if Data then return Data end

		Data = CheckGatherPointH(XMax - X + 1, XMax, YMax)
		if Data then return Data end

		--左右边的上下两段
		Data = CheckGatherPointV(YMin, YMax + Y - 1, XMin)
		if Data then return Data end
		
		Data = CheckGatherPointV(YMax - Y + 1, YMax, XMin)
		if Data then return Data end
		
		Data = CheckGatherPointV(YMin, YMax + Y - 1, XMax)
		if Data then return Data end
		
		Data = CheckGatherPointV(YMax - Y + 1, YMax, XMax)
		if Data then return Data end
	end

	return nil
end

function ClientVisionMgr:CheckVersionByGlobalVersion(VersionStr)
	return UE.UVersionMgr.IsBelowOrEqualGameVersion(VersionStr)
end

function ClientVisionMgr:EnableTick(bEnable)
	-- FLOG_INFO("ClientVisionMgr:EnableTick %s", tostring(bEnable))
	self.bNoTick = not bEnable
end

function ClientVisionMgr:ReadVisionWhitelistForPWorld(PWorldResID)
	local Result = VisionPworldMonsterWhitelistCfg:FindCfgByKey(PWorldResID)
	if Result then
		self.VisionWhitelist = Result.MustShowMonsterResID
	end
end

function ClientVisionMgr:GetIsInMonsterWhitelist(ResID)
	local bIn = false
	if self.VisionWhitelist then
		bIn = table.contain(self.VisionWhitelist,ResID)
	end
	return bIn
end

return ClientVisionMgr