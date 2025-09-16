
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActorUtil = require("Utils/ActorUtil")
-- local ProtoCS = require("Protocol/ProtoCS")
-- local ProtoCommon = require("Protocol/ProtoCommon")
local QuestMgr = require("Game/Quest/QuestMgr")
local AetherCurrentsMgr = require("Game/AetherCurrent/AetherCurrentsMgr")
local MapQuestObjMgr = require("Game/PWorld/MapQuestObj/MapQuestObjMgr")
local DiscoverNoteMgr = require("Game/SightSeeingLog/DiscoverNoteMgr")
local MysteryMerchantMgr = require("Game/MysterMerchant/MysterMerchantMgr")
local MoveConfig = require("Define/MoveConfig")
local FateMgr = require("Game/Fate/FateMgr")
local NpcCfg = require("TableCfg/NpcCfg")
local GatherPointCfg = require("TableCfg/GatherPointCfg")
local WildBoxMoundMgr = require("Game/WildBoxMound/WildBoxMoundMgr")
local GoldSauserMgr = nil
local ClientActorFactory = ClientActorFactory or {}

local EActorType = _G.UE.EActorType

local UActorManager = nil
local UWorldMgr = nil
local UMoveSyncMgr = nil

local ClientVisionMgr = nil
local GatherMgr = nil
local FLOG_INFO = nil
local FLOG_ERROR = nil

--对应于MapEditCfg中的那些，有需要的新增
--因为MapEditCfg中不同的类型，可能MapEditorID是相同的
--视野最好不是20米的倍数，比如30,50米
_G.MapEditorActorConfig = _G.MapEditorActorConfig or {
    Gather = {
		ActorType=EActorType.Gather, ViewSize = 4200, MiniMapViewSize = 11000,
		TileDataKey = "GatherTileData", MapEditCfgKey="PickItemList",
		MapEditorIDKey="ListId", ResIDKey="ResID", PointKey="Point", DirKey="Dir",
		ConfigType = "Gather",
	},

	--种植的Npc中IsQuestObj为true的是客户端npc；服务器也认这个
    Npc = {
		ActorType=EActorType.Npc, ViewSize = 5000,
		TileDataKey = "ClientNpcTileData", MapEditCfgKey="NpcList",
		MapEditorIDKey="ListId", ResIDKey="NpcID", PointKey="BirthPoint", DirKey="BirthDir",
		ConfigType = "Npc",
	},

    EObj = {
		ActorType=EActorType.EObj, ViewSize = 7000,
		TileDataKey = "EObjNpcTileData", MapEditCfgKey="EObjList",
		MapEditorIDKey="ID", ResIDKey="ResID", PointKey="Point", DirKey="Dir",
		ConfigType = "EObj",
	},
}

local MapEditorActorConfig = _G.MapEditorActorConfig

function ClientActorFactory:Init()
    if UActorManager == nil then
        UActorManager = _G.UE.UActorManager.Get()
    end

    if UWorldMgr == nil then
        UWorldMgr = _G.UE.UWorldMgr.Get()
    end

    if UMoveSyncMgr == nil then
		UMoveSyncMgr = _G.UE.UMoveSyncMgr:Get()
    end

	if (GoldSauserMgr == nil) then
		GoldSauserMgr = _G.GoldSauserMgr
	end
	
	ClientVisionMgr = _G.ClientVisionMgr
	GatherMgr = _G.GatherMgr
	FLOG_INFO = _G.FLOG_INFO
	FLOG_ERROR = _G.FLOG_ERROR

	--[NpcID, true/false]
	self.QuestNpcMap = {}
	self.WildBoxNpcMap = {}
end

function ClientActorFactory:UnInit()
	self.CurMapEditCfg = nil
end

function ClientActorFactory:OnMapLoaded(CurMapEditCfg)
	self.CurMapEditCfg = CurMapEditCfg
	
	self.QuestNpcMap = {}
	self.WildBoxMap = {}

	local NpcList = self.CurMapEditCfg.NpcList
	if NpcList then
		for index = 1, #NpcList do
			local NpcID = NpcList[index].NpcID
			local Cfg = NpcCfg:FindCfgByKey(NpcID)
			if Cfg then
				if Cfg.IsQuestObj == 1 then --为true才是任务npc
					self.QuestNpcMap[NpcID] = true
				elseif ProtoRes.NPC_TYPE.WILDBOX == Cfg.Type then --野外宝箱
					self.WildBoxMap[NpcID] = true
				end
			end
		end
	end
end

function ClientActorFactory:ClientActorEnterVision(ActorInfo, ActorType)
	if ActorType == EActorType.Gather then
		self:LoadOnePickItem(ActorInfo, ActorType)
	elseif ActorType == EActorType.Npc then
		self:LoadOneNpc(ActorInfo, ActorType)
	elseif ActorType == EActorType.EObj then
		self:LoadOneEObj(ActorInfo, ActorType)
	end
end

--========================================  视野扩展Actor ================================

--其他类型也需要一个类似接口，这个没办法通用
function ClientActorFactory:LoadOnePickItem(Gather, ActorType)
	local ResID = Gather.ResID
	local MapEditorID = Gather.ListId

	if Gather.bFutureVersion == nil then
		local Cfg = GatherPointCfg:FindCfgByKey(ResID)
		if Cfg then
			if not ClientVisionMgr:CheckVersionByGlobalVersion(Cfg.Version) then
				Gather.bFutureVersion = true
	
				return
			else
				Gather.bFutureVersion = false
			end
		end
	elseif Gather.bFutureVersion == true then
		return
	end

	local EntityID = ClientVisionMgr:GetEntityIDByMapEditorID(MapEditorID, ActorType)
	-- if EntityID then
	-- 	--已经创建过实体，不用走下面的逻辑，减少点tick成本
	-- 	return
	-- end

	if self.CurMapEditCfg then
		if GatherMgr:GatherCanPick(Gather, self.CurMapEditCfg.MapID) then
			-- FLOG_INFO("ClientVisionMgr LoadOnePickItem MapEditorID:%d, ResID:%d", MapEditorID, ResID)
			ClientVisionMgr:DoClientActorEnterVision(MapEditorID, Gather, MapEditorActorConfig.Gather)
		else
			--不满足条件了，会自动释放掉离开视野
			ClientVisionMgr:DestoryClientActor(EntityID, ActorType)
		end
	end
end

function ClientActorFactory:LoadOneNpc(Npc, ActorType)
	local NpcID = Npc.NpcID
	local MapEditorID = Npc.ListId
	
	if Npc.bFutureVersion == nil then
		local Cfg = NpcCfg:FindCfgByKey(NpcID)
		if Cfg then
			if not ClientVisionMgr:CheckVersionByGlobalVersion(Cfg.VersionName) then
				Npc.bFutureVersion = true
	
				return
			else
				Npc.bFutureVersion = false
			end
		end
	elseif Npc.bFutureVersion == true then
		return
	end

	local EntityID = ClientVisionMgr:GetEntityIDByMapEditorID(MapEditorID, ActorType)
	if EntityID then
        --已经创建过实体，不用走下面的逻辑，减少点tick成本
		return
	end

	if Npc.IsHide then
		-- local Cfg = NpcCfg:FindCfgByKey(NpcID)
		if self.QuestNpcMap[NpcID] then --IsQuestObj为true才是任务npc
			if QuestMgr:CanCreateQuestNpc(NpcID) or MapQuestObjMgr.GMForceLoadAllNpc then
				ClientVisionMgr:DoClientActorEnterVision(MapEditorID, Npc, MapEditorActorConfig.Npc, NpcID)
			else
				--不满足条件了，会自动释放掉离开视野;   这里相当于保障的一步，理论上可以不用这个代码的（外部会自己调用离开视野的接口ClientActorLeaveVision，进行释放）
				ClientVisionMgr:DestoryClientActor(EntityID, ActorType)
			end
		elseif self.WildBoxMap[NpcID] then --野外宝箱
			if WildBoxMoundMgr:CanShowNPC(self.CurMapEditCfg.MapID, MapEditorID) then
				ClientVisionMgr:DoClientActorEnterVision(MapEditorID, Npc, MapEditorActorConfig.Npc, NpcID)
			end
		else
			if (_G.GoldSauserMgr:IsCurGameSignUpNpc(Npc.ListId)) then
				if _G.GoldSauserMgr:CanCreateGoldSauserNpc(Npc.ListId) then
					local NpcEntityID = ClientVisionMgr:DoClientActorEnterVision(MapEditorID, Npc, MapEditorActorConfig.Npc, Npc.ListID)
					if (NpcEntityID == nil or NpcEntityID == 0) then
						NpcEntityID = 0
						_G.FLOG_ERROR("机遇临门出错，尝试创建当前游戏的NPC，但是创建失败，请检查, MapEditorID : %s", MapEditorID)
					end

					_G.GoldSauserMgr:SetSignUpNpcEntityID(NpcEntityID)
					_G.EventMgr:SendEvent(_G.EventID.GateOppoNpcTaskIconUpdate, { EntityID = NpcEntityID })
					FLOG_INFO("ClientVisionMgr LoadOneNpc MapEditorID:%d, npcid:%d", MapEditorID, Npc.ListId)
				end
			elseif MysteryMerchantMgr:CanCreateMerchantNPC(Npc.ListId) then
			 	ClientVisionMgr:DoClientActorEnterVision(MapEditorID, Npc, MapEditorActorConfig.Npc, Npc.ListId)
			elseif DiscoverNoteMgr:CanCreateNpc(Npc.ListId) or DiscoverNoteMgr:CanCreateHintNpc(Npc.ListId) then
				ClientVisionMgr:DoClientActorEnterVision(MapEditorID, Npc, MapEditorActorConfig.Npc, Npc.ListId)
			else
				ClientVisionMgr:DestoryClientActor(EntityID, ActorType)
			end
		end
	end
end

function ClientActorFactory:LoadOneEObj(EObj, ActorType)
	local EObjResID = EObj.ResID
	local MapEditorID = EObj.ID
	
	local EntityID = ClientVisionMgr:GetEntityIDByMapEditorID(MapEditorID, ActorType)
	if EntityID then
		--已经创建过实体，不用走下面的逻辑，减少点tick成本
		return
	end

	if not EObj.IsHide then return end -- 由服务器视野下发 

	if EObj.Type == ProtoRes.ClientEObjType.ClientEObjTypeWildBox then --野外宝箱
		-- 这里只处理空eobj，宝箱eobj在读条完成后创建
		if WildBoxMoundMgr:CanCreateEObj(self.CurMapEditCfg.MapID, MapEditorID) then
			ClientVisionMgr:DoClientActorEnterVision(MapEditorID, EObj, MapEditorActorConfig.EObj, EObjResID)
		end
	elseif EObj.Type == ProtoRes.ClientEObjType.ClientEObjTypeTask then --任务单独控制
		if QuestMgr:CanCreateEObj(EObjResID) then
			ClientVisionMgr:DoClientActorEnterVision(MapEditorID, EObj, MapEditorActorConfig.EObj, EObjResID)
		else
			--不满足条件了，会自动释放掉离开视野;   这里相当于保障的一步，理论上可以不用这个代码的（外部会自己调用离开视野的接口ClientActorLeaveVision，进行释放）
			ClientVisionMgr:DestoryClientActor(EntityID, ActorType)
		end
	elseif EObj.Type == ProtoRes.ClientEObjType.ClientEObjTypeAetherCurrent then
		if AetherCurrentsMgr:CanCreateEObj(EObjResID) then
			ClientVisionMgr:DoClientActorEnterVision(MapEditorID, EObj, MapEditorActorConfig.EObj, EObjResID)
		else
			--不满足条件了，会自动释放掉离开视野;   这里相当于保障的一步，理论上可以不用这个代码的（外部会自己调用离开视野的接口ClientActorLeaveVision，进行释放）
			ClientVisionMgr:DestoryClientActor(EntityID, ActorType)
		end
	elseif EObj.Type == ProtoRes.ClientEObjType.ClientEObjTypeDiscoverNote then
		if DiscoverNoteMgr:CanCreateEObj(EObjResID) then
		    --FLOG_INFO("ClientVisionMgr LoadOneEobj MapEditorID(DiscoverNoteMgr):%d, EObjResID:%d", MapEditorID, EObjResID)
			ClientVisionMgr:DoClientActorEnterVision(MapEditorID, EObj, MapEditorActorConfig.EObj, EObjResID)
		else
			--不满足条件了，会自动释放掉离开视野;   这里相当于保障的一步，理论上可以不用这个代码的（外部会自己调用离开视野的接口ClientActorLeaveVision，进行释放）
			--FLOG_INFO("ClientVisionMgr LoadOneEobj MapEditorID(DiscoverNoteMgr):%d, EObjResID:%d", MapEditorID, EObjResID)
			ClientVisionMgr:DestoryClientActor(EntityID, ActorType)
		end
	elseif EObj.Type == ProtoRes.ClientEObjType.ClientEObjTypeDiscoverClue then
		if DiscoverNoteMgr:CanCreateEObjClue(EObjResID) then
		    --FLOG_INFO("ClientVisionMgr LoadOneEobj MapEditorID(DiscoverNoteMgr):%d, EObjResID:%d", MapEditorID, EObjResID)
			ClientVisionMgr:DoClientActorEnterVision(MapEditorID, EObj, MapEditorActorConfig.EObj, EObjResID)
		else
			--不满足条件了，会自动释放掉离开视野;   这里相当于保障的一步，理论上可以不用这个代码的（外部会自己调用离开视野的接口ClientActorLeaveVision，进行释放）
			--FLOG_INFO("ClientVisionMgr LoadOneEobj MapEditorID(DiscoverNoteMgr):%d, EObjResID:%d", MapEditorID, EObjResID)
			ClientVisionMgr:DestoryClientActor(EntityID, ActorType)
		end
	elseif EObj.Type == ProtoRes.ClientEObjType.ClientEObjTypeFateGather then
		if FateMgr:CanCreateEObj(MapEditorID, EObjResID) then
			ClientVisionMgr:DoClientActorEnterVision(MapEditorID, EObj, MapEditorActorConfig.EObj, EObjResID)
		end
	elseif EObj.Type == ProtoCommon.EObjType.EObjTypeMerchantGather then
		if MysteryMerchantMgr:CanCreateEObj(MapEditorID, EObjResID) then
			ClientVisionMgr:DoClientActorEnterVision(MapEditorID, EObj, MapEditorActorConfig.EObj, EObjResID)
		end
	end
end


--========================================  视野扩展Actor ================================

-- ================= private =============================
--本地actor创建流程中，使用lua对属性组件填充，抛enterview的事件（也要给c++那面
--如同服务器视野那样的逻辑
function ClientActorFactory:OnClientActorInit(EntityID, bCache)
	local BaseActor = ActorUtil.GetActorByEntityID(EntityID)
	if BaseActor then
		local ActorType = BaseActor:GetActorType()
		local AttributeComp = BaseActor:GetAttributeComponent()
		--这里创建成功的，必然是 self.CurMapEditCfg.MapID这个地图内的
		--因为创建actor的时候，只会创建 self.CurMapEditCfg.MapID这个地图的，别的地图的不会创建（别的地图可能有相同的MapEditorID）
		if AttributeComp then
			--采集物
			if ActorType == EActorType.Gather then
				local Gather = GatherMgr:FindPrivateGather(AttributeComp.ListID, self.CurMapEditCfg.MapID)
				if Gather then
					--使用服务器下发的数据
					AttributeComp.PickTimesLeft = Gather.PickCountLeft
					if Gather.PickCountLeft <= 0 then
						FLOG_ERROR("ClientVisionMgr Actor Created, bug TimesLeft is zero")
					end
				else
					--默认初始数据
					AttributeComp.PickTimesLeft = GatherMgr:GetMaxGatherCount(AttributeComp.ResID)
				end
			end
		end

		-- lua侧不要抛视野事件，统一在C++侧处理，防止抛重复
		-- local Params = _G.EventMgr:GetEventParams()
		-- Params.BoolParam1 = bCache
		-- Params.ULongParam1 = EntityID

		-- if AttributeComp then
		-- 	Params.IntParam1 = AttributeComp:GetActorType()
		-- 	Params.IntParam2 = AttributeComp.ResID
		-- end
		-- _G.EventMgr:SendCppEvent(EventID.VisionEnter, Params)
		-- _G.EventMgr:SendEvent(EventID.VisionEnter, Params)
	end
end

--本地actor创建完成
function ClientActorFactory:OnClientActorCreated(EntityID, bCache)
end

-- ================= private =============================
--ClientVisionMgr使用 	--需要返回entityid
function ClientActorFactory:CreateClientActor(MapEditorID, MapEditorData, ActorConfig)
	if not MapEditorData then
		FLOG_ERROR("ClientVisionMgr CreateClientActor Error, param is nil")
		return
	end

	local ResID = MapEditorData[ActorConfig.ResIDKey]

	local BirthPoint = MapEditorData[ActorConfig.PointKey]
	local LocVec = _G.UE.FVector(BirthPoint.X, BirthPoint.Y, BirthPoint.Z)
	local Rot = _G.UE.FRotator(0, MapEditorData[ActorConfig.DirKey], 0)

	return self:DoCreateClientActor(ActorConfig.ActorType, MapEditorID, ResID, LocVec, Rot)
end

function ClientActorFactory:DestoryClientActor(EntityID, ActorType)
	if EntityID == nil then
		FLOG_ERROR("ClientVisionMgr destroy actor error: EntityID is nil")
		return
	end

	-- FLOG_INFO("ClientVisionMgr destroy actor entityID: %d", EntityID)

	local PathPoints = nil
	local NpcData = nil
	local ResID = ActorUtil.GetActorResID(EntityID)
	-- 策划暂时不配置客户端npc离场路径点，出于性能考虑先注释掉
	-- if ActorType == MapEditorActorConfig.Npc.ActorType then
	-- 	NpcData = _G.MapEditDataMgr:GetNpc(ResID)
	-- 	if NpcData ~= nil then
	-- 		local BirthPoint = NpcData.BirthPoint
	-- 		local LocVec = _G.UE.FVector(BirthPoint.X, BirthPoint.Y, BirthPoint.Z)
	-- 		PathPoints = self.GetNpcPathPoints(NpcData, LocVec, false)
	-- 	end
	-- end

	if NpcData ~= nil and PathPoints ~= nil then
		self.MakeFinishCallback(EntityID, function()
			UActorManager:RemoveClientActor(EntityID) --不要自己调用StartFadeOut，使用RemoveClientActor
			_G.EventMgr:SendEvent(_G.EventID.ClientNpcMoveEnd, { EntityID = nil, ResID = ResID })
		end)

		_G.EventMgr:SendEvent(_G.EventID.ClientNpcMoveStart, { EntityID = EntityID, ResID = ResID })

		local Speed = NpcData.DisappearSpeedLevel * (MoveConfig.SprintMinSpeed / 10)
		UMoveSyncMgr:StartClientMove(EntityID, PathPoints, Speed)
	else
		UActorManager:RemoveClientActor(EntityID)
	end
end

function ClientActorFactory:DoCreateClientActor(ActorType, MapEditorID, ResID, LocVec, Rot)
	-- 客户端NPC创建时的移动路径
	local PathPoints = nil
	local NpcData = nil
	-- 策划暂时不配置客户端npc入场路径点，出于性能考虑先注释掉
	-- if ActorType == MapEditorActorConfig.Npc.ActorType then
	-- 	NpcData = _G.MapEditDataMgr:GetNpc(ResID)
	-- 	if NpcData ~= nil then
	-- 		PathPoints = self.GetNpcPathPoints(NpcData, LocVec, true)
	-- 		if PathPoints ~= nil then
	-- 			LocVec = PathPoints:Get(1)
	-- 		end
	-- 	end
	-- end

	if NpcData ~= nil and PathPoints ~= nil then
		_G.EventMgr:SendEvent(_G.EventID.ClientNpcMoveStart, { EntityID = nil, ResID = ResID })
	end

	local EntityID = UActorManager:CreateClientActor(ActorType, MapEditorID, ResID, LocVec, Rot)

	if EntityID < 0 then
		if NpcData ~= nil and PathPoints ~= nil then
			_G.EventMgr:SendEvent(_G.EventID.ClientNpcMoveEnd, { EntityID = EntityID, ResID = ResID })
		end

		FLOG_ERROR("ClientVisionMgr CreateClientActor Error:%d", MapEditorID)
		return
	end

	if NpcData ~= nil and PathPoints ~= nil then
		self.MakeFinishCallback(EntityID, function()
			local ClientActor = ActorUtil.GetActorByEntityID(EntityID)
			if ClientActor ~= nil then
				ClientActor:SetCharacterRotationInterp(Rot, MoveConfig.RotInterpSpeed)
				_G.EventMgr:SendEvent(_G.EventID.ClientNpcMoveEnd, { EntityID = EntityID, ResID = ResID })
			end
		end)

		local Speed = NpcData.AppearSpeedLevel * (MoveConfig.SprintMinSpeed / 10)
		UMoveSyncMgr:StartClientMove(EntityID, PathPoints, Speed)
	end

    FLOG_INFO("ClientVisionMgr create actortype: %d ResID: %d entityid: %d, MapEditorID:%d, LocVec:%s"
		, ActorType, ResID, EntityID, MapEditorID, tostring(LocVec))

    return EntityID
end

function ClientActorFactory.MakeFinishCallback(EntityID, OnFinishCallback)
	local function ShellCallback(_, InEntityID)
		if EntityID ~= InEntityID then return end
		-- 延迟一会儿执行，避免在FMoveSyncPipeline::Tick()内CurrentStrategy->Tick()销毁Actor，导致破坏CurrentStrategy非空假设
		_G.TimerMgr:AddTimer(nil, OnFinishCallback, 0.1)
		UMoveSyncMgr.OnClientLocalMoveFinish:Remove(UMoveSyncMgr, ShellCallback)
	end
	UMoveSyncMgr.OnClientLocalMoveFinish:Add(UMoveSyncMgr, ShellCallback)
end

---从地图NPC数据获取路径
function ClientActorFactory.GetNpcPathPoints(NpcData, LocVec, bIsAppearPath)
	if NpcData == nil or LocVec == nil then return nil end
	local MapEditDataMgr = _G.MapEditDataMgr

	local PathData = nil
	if bIsAppearPath then
		if NpcData.AppearPathID ~= 0 then
			PathData = MapEditDataMgr:GetPath(NpcData.AppearPathID)
		end
	else
		if NpcData.DisappearPathID ~= 0 then
			PathData = MapEditDataMgr:GetPath(NpcData.DisappearPathID)
		end
	end
	if PathData == nil then return nil end

	local PathPoints = _G.UE.TArray(_G.UE.FVector)
	local PointsData = PathData.Points

	local function AddPathPointsTraverse()
		for i = 1, #PointsData do
			local Point = PointsData[i].Point
			PathPoints:Add(_G.UE.FVector(Point.X, Point.Y, Point.Z))
		end
	end

	local function AddPathPointsReverse()
		for i = #PointsData, 1, -1 do
			local Point = PointsData[i].Point
			PathPoints:Add(_G.UE.FVector(Point.X, Point.Y, Point.Z))
		end
	end

	local DistTooClose = 10.0
	if bIsAppearPath then
		AddPathPointsTraverse()
		-- 检查原路径终点和NPC位置距离，过近则去掉原路径终点
		local LastIndex = PathPoints:LastIndex()
		local Dist = _G.UE.FVector.Dist(LocVec, PathPoints:GetRef(LastIndex))
		if Dist < DistTooClose then
			PathPoints:Set(LastIndex, LocVec)
		else
			PathPoints:Add(LocVec)
		end
	else
		PathPoints:Add(LocVec)
		if NpcData.AppearPathID ~= NpcData.DisappearPathID then
			AddPathPointsTraverse()
		else -- NPC出现路径和消失路径ID相同时，调转路径点顺序
			AddPathPointsReverse()
		end
		-- 检查原路径起点和NPC位置距离，过近则去掉原路径起点
		local Dist = _G.UE.FVector.Dist(LocVec, PathPoints:GetRef(2))
		if Dist < DistTooClose then
			PathPoints:Remove(2)
		end
	end

	if PathPoints:Length() < 2 then
		return nil -- 路径点数量无法构成路径
	end

	return PathPoints
end

-- ================= private =============================

return ClientActorFactory