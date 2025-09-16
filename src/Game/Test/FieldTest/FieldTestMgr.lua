local ProtoRes = require ("Protocol/ProtoRes")
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local MajorUtil = require("Utils/MajorUtil")
local AudioUtil = require("Utils/AudioUtil")
local NpcCfg = require("TableCfg/NpcCfg")
local MonsterCfg = require("TableCfg/MonsterCfg")
local GatherPointCfg = require("TableCfg/GatherPointCfg")
local FateMainCfgTable = require("TableCfg/FateMainCfg")
local FateGeneratorCfg = require("TableCfg/FateGeneratorCfg")
local ActiontimelinePathCfg = require("TableCfg/ActiontimelinePathCfg")
local FateDefine = require("Game/Fate/FateDefine")
local WeatherCfg = require("TableCfg/WeatherCfg")
local QuestChapterCfg = require("TableCfg/QuestChapterCfg")
local MapCfg = require("TableCfg/MapCfg")
local FishLocationCfg = require("TableCfg/FishLocationCfg")
local ProtoEnumAlias = require("Protocol/ProtoEnumAlias")
local AetherCurrentCfg = require("TableCfg/AetherCurrentCfg")
local DiscoverNoteCfg = require("TableCfg/DiscoverNoteCfg")
local WildBoxMoundCfg = require("TableCfg/WildBoxMoundCfg")

local table_to_string = _G.table_to_string
local GMMgr = _G.GMMgr
local UE = _G.UE
local PWorldMgr = _G.PWorldMgr
local GatherMgr = _G.GatherMgr
local WildBoxMoundMgr = _G.WildBoxMoundMgr
local MapEditDataMgr = _G.MapEditDataMgr
local DiscoverNoteMgr


---@class FieldTestMgr : MgrBase
local FieldTestMgr = LuaClass(MgrBase)

function FieldTestMgr:OnInit()
	self.DataTypeDefine = {
		NPC = 1,
		Monster = 2,
		Gather = 3,
		Fate = 4,
		SoundFX = 5,
		Weather = 6,
		Chocobo = 7,
		Teleport = 8,
		Fish = 9,
		Aether = 10,
		DiscoverNote = 11,
		WildBox = 12,
	}
	self:Reset()
end

function FieldTestMgr:OnBegin()
	GMMgr = _G.GMMgr
	PWorldMgr = _G.PWorldMgr
	GatherMgr = _G.GatherMgr
	WildBoxMoundMgr = _G.WildBoxMoundMgr
	MapEditDataMgr = _G.MapEditDataMgr
	DiscoverNoteMgr = _G.DiscoverNoteMgr
end

function FieldTestMgr:OnEnd()
	GMMgr = nil
	PWorldMgr = nil
	GatherMgr = nil
	WildBoxMoundMgr = nil
	MapEditDataMgr = nil
end

--切图的时候会清空的
function FieldTestMgr:Reset()
	self.NpcDataList = {}
	self.MonsterDataList = {}
end

function FieldTestMgr:OnShutdown()
	self:Reset()
end

function FieldTestMgr:OnRegisterNetMsg()
end

function FieldTestMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.GMReceiveRes, self.OnGMReceiveRes)
end

--目前自动化测试的协议 和 debug工具（地图资源检测）才会过来
function FieldTestMgr:GetNpcMonsterResByGM()
	GMMgr:ReqGM1("cell map entities")
end

function FieldTestMgr:OnGMReceiveRes(MsgBody)
    local Result = table_to_string(MsgBody)
	if string.find(Result, "Cmd=map") then

		local index = string.find(Result, "cell:")
		if index then
			Result = string.sub(Result, index)
		end
		local Lines = string.split(Result, "\n")

		self.NpcDataList = self:GetNpcDataList(Lines)
		self.MonsterDataList = self:GetMonsterDataList(Lines)

		local FieldTestPanelView = _G.UIViewMgr:FindView(_G.UIViewID.FieldTestPanel)
		if FieldTestPanelView then
			FieldTestPanelView:OnGMReceiveRes()
		end
	end
end

---Npc数据
function FieldTestMgr:GetNpcDataList(Lines)
	local DataList = {}

	local Temp = NpcCfg:FindAllCfg()
	local AllCfg = {}
	for _, V in pairs(Temp) do
		if V.ID > 0 then
			AllCfg[V.ID] = V
		end
	end

	local Npcs = {}

	if #Lines > 1 then
		--第一行不要
		--1783875388966319543-2.1004222 pos:(2193 -9736 720) grid:4.2 hp:1/1 camp:0 [法尔穆尔]
		--1040801577874496406-2.1001709 pos:(-24047,8561,1870) grid:0.5 hp:1/1 camp:0 [可可比格]
		--4982197955776765-6.1001709 pos:(-24047 8561 1870) dir:336 grid:0.4 camp:0 [可可比格]
		for i = 2, #Lines do
			local Array = string.split(Lines[i], " ")
			local EntityID, Type, ID = self:GetEntityAndTypeAndID(Array[1])
			--if Type == 2 then
				if AllCfg[ID] then
					local Npc = {}
					Npc.ID = ID
					Npc.EntityID = EntityID
					if string.find(Array[2], ",") ~= nil then
						Npc.Point = self:GetPoint(Array[2])
					else
						Npc.Point = self:GetPointMulti(Array[2], Array[3], Array[4])
					end
					if not Npcs[ID] then
						Npcs[ID] = {}
					end
					table.insert(Npcs[ID], Npc)
				end
			--end
		end
	end

	--整合，同id在视野范围内的
	for _, V in pairs(Npcs) do
		local NpcData = V[1]
		local NpcTableCfg = AllCfg[NpcData.ID]
		if NpcTableCfg and NpcTableCfg.IsHideModel == 0 then
			---@class FieldTestItemData
			---@field ID number
			---@field Index number
			---@field EntityID number
			---@field Point table<float, float, float>
			---@field Name string
			---@field Num number
			---@field Type number
			---@field Children table<FieldTestItemData>
			local Data = {}
			Data.ID = NpcData.ID
			Data.Point = NpcData.Point
			Data.EntityID = NpcData.EntityID
			Data.Name = NpcTableCfg.Name
			Data.Num = 1
			Data.Type = self.DataTypeDefine.NPC
			Data.Behavior = NpcTableCfg.Behavior
			local Cfg = ActiontimelinePathCfg:FindCfgByKey(NpcTableCfg.IdleTimeline)
			Data.IdleTimelinePath = Cfg ~= nil and Cfg.Filename or ""

			---Children Data
			Data.Children = {}
			for i = 1, #V do
				NpcData = V[i]
				local ChildData = {}
				ChildData.ID = NpcData.ID
				ChildData.EntityID = NpcData.EntityID
				ChildData.Index = i
				ChildData.Point = NpcData.Point
				ChildData.Name = NpcTableCfg.Name
				ChildData.Num = #V
				ChildData.Type = self.DataTypeDefine.NPC
				ChildData.Behavior = NpcTableCfg.Behavior
				local ChildCfg = ActiontimelinePathCfg:FindCfgByKey(NpcTableCfg.IdleTimeline)
				ChildData.IdleTimelinePath = ChildCfg ~= nil and ChildCfg.Filename or ""
				table.insert(Data.Children, ChildData)
			end

			table.insert(DataList, Data)
		end
	end

	local MapCfg = MapEditDataMgr:GetMapEditCfg()
	local NPCList = MapCfg.NpcList
	for _, NPC in pairs(NPCList or {}) do
		if NPC.IsQuestObj then
			local CanCreateNPC = _G.QuestMgr:CanCreateQuestNpc(NPC.NpcID)
			if CanCreateNPC then
				local NPCCfg = AllCfg[NPC.NpcID]
				if NpcCfg then
					local Data = {}
					Data.ID = NPC.NpcID
					Data.Point = NPC.BirthPoint
					Data.EntityID = _G.ClientVisionMgr:GetEntityIDByMapEditorID(NPC.ListId, _G.MapEditorActorConfig.Npc.ActorType)
					Data.Name = NPCCfg.Name
					Data.Num = 1
					Data.Type = self.DataTypeDefine.NPC
					Data.Behavior = NPCCfg.Behavior
					local Cfg = ActiontimelinePathCfg:FindCfgByKey(NPCCfg.IdleTimeline)
					Data.IdleTimelinePath = Cfg ~= nil and Cfg.Filename or ""
					table.insert(DataList, Data)
				end
			end
		end
	end

	return DataList
end

---怪物数据
function FieldTestMgr:GetMonsterDataList(Lines)
	local DataList = {}

	local Temp = MonsterCfg:FindAllCfg()
	local AllCfg = {}
	for _, V in pairs(Temp) do
		if V.ID > 0 then
			AllCfg[V.ID] = V
		end
	end

	--先收集id和位置，借鉴npc的逻辑，后面优化可以统一
	---@type table<number, table> table<monsterID, monsterData>
	local Monsters = {}

	if #Lines > 1 then
		---第一行不要
		--1788379017060974996-2.12003280 pos:(-33077 -78173 1499) grid:10.4 hp:373/373 camp:3 [笑蟾蜍]
		for i = 2, #Lines do
			local Array = string.split(Lines[i], " ")
			local EntityID, Type, ID = self:GetEntityAndTypeAndID(Array[1])
			--if Type == 2 then
				--过滤其他数据
				if AllCfg[ID] then
					local Monster = {}
					Monster.ID = ID
					Monster.EntityID = EntityID
					if string.find(Array[2], ",") ~= nil then
						Monster.Point = self:GetPoint(Array[2])
					else
						Monster.Point = self:GetPointMulti(Array[2], Array[3], Array[4])
					end
					if #Array >= 11 then
						Monster.ListID = self:GetListID(Array[9])
					end
					if not Monsters[ID] then
						Monsters[ID] = {}
					end
					table.insert(Monsters[ID], Monster)
				end
			--end
		end
	end

	--整合，同id在视野范围内的
	for _, V in pairs(Monsters) do
		local MonsData = V[1]
		local Data = {}
		Data.ID = MonsData.ID
		Data.Point = MonsData.Point
		Data.EntityID = MonsData.EntityID
		local MonsTableCfg = AllCfg[MonsData.ID]
		if MonsTableCfg then
			Data.Name = MonsTableCfg.Name
		else
			Data.Name = ""
		end
		Data.Num = 1
		Data.Type = self.DataTypeDefine.Monster

		if MonsData.ListID then
			local MonsterData = MapEditDataMgr:GetMonsterByListID(MonsData.ListID)
			if (MonsterData ~= nil) then
				Data.NormalAI = MonsterData.NormalAI
			end
		end

		---Children Data
		Data.Children = {}
		for i = 1, #V do
			MonsData = V[i]
			local ChildData = {}
			ChildData.ID = MonsData.ID
			ChildData.EntityID = MonsData.EntityID
			ChildData.Index = i
			ChildData.Point = MonsData.Point
			if MonsData.ListID then
				local MonsterData = MapEditDataMgr:GetMonsterByListID(MonsData.ListID)
				if (MonsterData ~= nil) then
					ChildData.NormalAI = MonsterData.NormalAI
				end
			end
			if MonsTableCfg then
				ChildData.Name = MonsTableCfg.Name
			else
				ChildData.Name = ""
			end
			ChildData.Num = #V
			ChildData.Type = self.DataTypeDefine.Monster
			table.insert(Data.Children, ChildData)
		end

		table.insert(DataList, Data)
	end

	return DataList
end

---采集数据
function FieldTestMgr:GetGatherDataList()
	local DataList = {}

	local MapEditCfg = MapEditDataMgr:GetMapEditCfg()
	if not MapEditCfg or not MapEditCfg.PickItemList then
		return
	end

	local GatherList = {}
	for i = 1, #MapEditCfg.PickItemList do
		table.insert(GatherList, MapEditCfg.PickItemList[i])
	end
	table.sort(GatherList, function(l, r)
		return l.ResID > r.ResID
	end)

	local MapResID = PWorldMgr:GetCurrMapResID()

	local Temp = GatherPointCfg:FindAllCfg(string.format("MapID=%d", MapResID))
	if not Temp then
		return
	end

	local ProfID = MajorUtil.GetMajorProfID()
	local AllCfg = {}
	for i = 1, #Temp do
		local Cfg = Temp[i]
		-- 判断当前职业匹配采集物
		if GatherMgr:IsCanGatherByProf(Cfg.GatherType, ProfID) then
			AllCfg[Cfg.ID] = Cfg
		end
	end

	--FLOG_ERROR("PickItemList=".._G.LuaPanda.serializeTable(GatherList))

	for _, V in pairs(GatherList) do
		local Cfg = AllCfg[V.ResID]
		if Cfg then
			local Data = {}
			Data.ID = Cfg.ID
			Data.Point = V.Point
			Data.Name = Cfg.Name
			local OnePrivateGather = GatherMgr:FindPrivateGather(V.ListId, MapResID)
			if OnePrivateGather then
				Data.Num = OnePrivateGather.PickCountLeft
			else
				Data.Num = 0
			end
			Data.Type = self.DataTypeDefine.Gather

			table.insert(DataList, Data)
		end
	end
	return DataList
end

---Fate数据
function FieldTestMgr:GetFateDataList()
	local DataList = {}

	local FateIDs = FateGeneratorCfg:FindAllCfg(string.format("MapID=%d", PWorldMgr:GetCurrMapResID()))
	local AllCfg = {}
	for i = 1, #FateIDs do
		local Cfg = FateMainCfgTable:FindCfgByKey(FateIDs[i].ID)
		if Cfg then
			table.insert(AllCfg, Cfg)
		end
	end

	for _, V in pairs(AllCfg) do
		local Data = {}
		Data.ID = V.ID
		if V.TriggerNPCLocation ~= "" then
			local Location = FateDefine.ParseLocation(V.TriggerNPCLocation)
			if Location then
				Data.Point = {X = Location.X, Y = Location.Y, Z = Location.Z}
			end
		else
			local Location = FateDefine.ParseLocation(V.Range)
			if Location then
				Data.Point = {X = Location.X, Y = Location.Y, Z = Location.Z}
			end
		end
		Data.Name = V.Name
		Data.Num = 1
		Data.Type = self.DataTypeDefine.Fate

		table.insert(DataList, Data)
	end
	return DataList
end

---音效数据
function FieldTestMgr:GetSoundEffDataList()
	local DataList = {}
	local SoundList = AudioUtil.GetAllEnvSound()

	-- for i = 1, #SoundList do
	-- 	table.insert(AllCfg, SoundList[i])
	-- end

	for index, v in pairs(SoundList) do
		local Data = {}
		Data.ID = tonumber(string.sub(v.SEElementName, 3, -2))
		Data.Name = string.format("EnvSound_%s",  string.sub(v.SEElementName, 3, -2))
		Data.SoundName = v.SEElementName
		Data.MinRange = v.MinRange
		Data.MaxRange = v.MaxRange
		Data.Volume = v.Volume
		local Position = v.Position
		Data.Point = {X = math.floor(Position.X), Y = math.floor(Position.Y), Z = math.floor(Position.Z)}
		Data.RangeVolume = v.RangeVolume
		Data.SoundSubType = v.SoundSubType
		Data.SoundType = v.SoundType
		Data.SoundPath = v.SoundEventPath
		Data.Num = 1
		Data.Type = self.DataTypeDefine.SoundFX
		table.insert(DataList, Data)
	end
	return DataList
end

---天气数据
function FieldTestMgr:GetWeatherDataList()
	local DataList = {}

	local WeatherID = _G.UE.UEnvMgr:Get():GetCurrentWeather()
	local WeatherName = WeatherCfg:GetWeatherName(tonumber(WeatherID))

	local EnvSetActors = _G.UE.UEnvMgr:Get():GetEnvSetActors()
	for i = 1, EnvSetActors:Length() do
		local EnvSet = EnvSetActors[i]
		local Data = {}
		Data.ID = WeatherID
		Data.Name = WeatherName
		local EnvRes = self:GetEnvAndRes(EnvSet)
		local WeatherEnv = EnvRes.WeatherEnv
		if WeatherEnv == "global" then
			Data.WeatherType = "global"
		else
			Data.WeatherType = "local"
		end
		Data.WeatherEnv = WeatherEnv
		Data.WeatherRes = EnvRes.WeatherRes
		Data.Point = EnvRes.Point
		Data.Num = 1
		Data.Type = self.DataTypeDefine.Weather
		table.insert(DataList, Data)
	end
	return DataList
end

function FieldTestMgr:GetEnvAndRes(EnvAndRes)
	local Array = string.split(EnvAndRes, ":")
	if #Array >= 5 then
		local Point = {X = Array[3], Y = Array[4], Z = Array[5]}
		return {WeatherEnv = Array[1], WeatherRes = Array[2], Point = Point}
	else
		return {WeatherEnv = "", WeatherRes = ""}
	end
end

-- 陆行鸟数据
function FieldTestMgr:GetChocoboNPCDataList()
	local DataList = {}
	local MapEditCfg = MapEditDataMgr:GetMapEditCfg()

	--获取当前地图所有运输陆行鸟NPC
	if MapEditCfg.NpcList then
		for _, V in ipairs(MapEditCfg.NpcList) do
			if _G.NpcMgr:IsChocoboNpcByListID(V.ListId) then
				---@type ChocoboTransportPoint
				local Data = {}
				Data.Point = {X = math.floor(V.BirthPoint.X), Y = math.floor(V.BirthPoint.Y), Z = math.floor(V.BirthPoint.Z)}
				Data.Num = 1
				Data.Type = self.DataTypeDefine.Chocobo
				Data.ID = V.NpcID
				local Cfg = NpcCfg:FindCfgByKey(V.NpcID)
				Data.Name = Cfg.Name
				table.insert(DataList, Data)
			end
		end
	end
	return DataList
end

function FieldTestMgr:GetMapTaskList()
	-- 任务列表
	local TaskList = {}
	local MapResID = PWorldMgr:GetCurrMapResID()
	local Temp = QuestChapterCfg:FindAllCfg(string.format("MapID=%d", MapResID))
	if Temp then
		for _, V in pairs(Temp) do
			local Data = {}
			Data.ID = V.id
			Data.Name = V.QuestName
			Data.StartQuestID = V.StartQuest
			Data.Num = 1
			Data.Type = self.DataTypeDefine.Chocobo
			table.insert(TaskList, Data)
		end
	end
	return TaskList
end

-- 编辑器数据
-- 传送带数据 & 钓场数据
function FieldTestMgr:GetMapEditDataList()
	local DataList = {}
	local FishLocationDataList = {}
	local MapEditCfg = MapEditDataMgr:GetMapEditCfg()

	local AreaList = MapEditCfg.AreaList
	local Name = "Unknown"
	local Map = MapCfg:FindCfgByKey(MapEditCfg.MapID)
    if Map then
        Name = Map.DisplayName
	end
	if AreaList then
		local ExitRangeDataList = {}
		local PopRangePositionList = {}
		local FishDataList = {}
		for _, Area in ipairs(AreaList) do
			-- 传送带
			if Area.FuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_EXIT then
				local Data = {}
				local Position = nil
				if (Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_BOX) then
					Data.Box = Area.Box
					Data.Position = _G.UE.FVector(Area.Box.Center.X, Area.Box.Center.Y, Area.Box.Center.Z)
				elseif (Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_CYLINDER) then
					Data.Cylinder = Area.Cylinder
					Data.Position = _G.UE.FVector(Area.Cylinder.Start.X, Area.Cylinder.Start.Y, Area.Cylinder.Start.Z)
				end
				Data.Num = 1
				Data.Type = self.DataTypeDefine.Teleport
				Data.ID = Area.ID
				Data.Name = Name
				table.insert(ExitRangeDataList, Data)
			-- PopRange
			elseif Area.FuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_POP then
				local Position = nil
				if (Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_BOX) then
					Position = _G.UE.FVector(Area.Box.Center.X, Area.Box.Center.Y, Area.Box.Center.Z)
				elseif (Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_CYLINDER) then
					Position = _G.UE.FVector(Area.Cylinder.Start.X, Area.Cylinder.Start.Y, Area.Cylinder.Start.Z)
				end
				if Position then
					table.insert(PopRangePositionList, Position)
				end
			-- 钓场
			elseif Area.FuncType == ProtoRes.area_func_type.AREA_FUNC_TYPE_GIMMICK then
				local Data = {}
				local GimmickData = Area.Gimmick
				-- 渔场区域
				if GimmickData.Type == ProtoRes.gimmick_type.GIMMICK_TYPE_FISHING then
					local Position = nil
					if (Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_BOX) then
						Data.Box = Area.Box
						Data.Position = _G.UE.FVector(Area.Box.Center.X, Area.Box.Center.Y, Area.Box.Center.Z)
					elseif (Area.ShapeType == ProtoRes.area_shape_type.AREA_SHAPE_TYPE_CYLINDER) then
						Data.Cylinder = Area.Cylinder
						Data.Position = _G.UE.FVector(Area.Cylinder.Start.X, Area.Cylinder.Start.Y, Area.Cylinder.Start.Z)
					end
					Data.Num = 1
					Data.Type = self.DataTypeDefine.Fish
					Data.AreaID = Area.ID
					local FishAreaID = GimmickData.GimmickKey
					local FishLocation = FishLocationCfg:FindCfgByKey(FishAreaID)
					Data.ID = FishAreaID
					Data.Name = FishLocation.Name
					Data.FishLocationTye = ProtoEnumAlias.GetAlias(ProtoRes.FISH_LOCATION_TYPE, FishLocation.LocationType)
					table.insert(FishDataList, Data)
        		end
			end
		end
		-- 计算距离每个exitrange最近的poprange
		for _, ExitRangeData in pairs(ExitRangeDataList) do
			local Position = ExitRangeData.Position
			if Position then
				local MinDist = nil
				local MinPos = ExitRangeData.Position
				for _, PopRangePosition in ipairs(PopRangePositionList) do
					local Dist = _G.UE.FVector.Dist(PopRangePosition, Position)
					if nil == MinDist then
						MinDist = Dist
						MinPos = PopRangePosition
					elseif Dist < MinDist then
						MinDist = Dist
						MinPos = PopRangePosition
					end
				end
				ExitRangeData.Point = {X = math.floor(MinPos.X), Y = math.floor(MinPos.Y), Z = math.floor(MinPos.Z)}
				table.insert(DataList, ExitRangeData)
			end
		end
		-- 计算距离每个钓场最近的poprange
		for _, FishData in pairs(FishDataList) do
			local Position = FishData.Position
			if Position then
				local MinDist = nil
				local MinPos = FishData.Position
				for _, PopRangePosition in ipairs(PopRangePositionList) do
					local Dist = _G.UE.FVector.Dist(PopRangePosition, Position)
					if nil == MinDist then
						MinDist = Dist
						MinPos = PopRangePosition
					elseif Dist < MinDist then
						MinDist = Dist
						MinPos = PopRangePosition
					end
				end
				FishData.Point = {X = math.floor(MinPos.X), Y = math.floor(MinPos.Y), Z = math.floor(MinPos.Z)}
				table.insert(FishLocationDataList, FishData)
			end
		end
	end
	self.ExitRangeDataList = DataList
	self.FishLocationDataList = FishLocationDataList
	return DataList, FishLocationDataList
end

-- 风脉泉数据
function FieldTestMgr:GetAetherDataList()
	local DataList = {}
	local Name = "Unknown"
	local MapID = PWorldMgr:GetCurrMapResID()
	local Map = MapCfg:FindCfgByKey(MapID)
    if Map then
        Name = Map.DisplayName
	end
	local AetherDataList = AetherCurrentCfg:FindAllCfg(string.format("MapID=%d", MapID))
	if AetherDataList then
		for _, V in pairs(AetherDataList) do
			if V.CurrentType == ProtoRes.WindPulseSpringActivateType.Interact then
				local Data = {}
				Data.ID = V.PointID
				Data.Name = Name
				local MapEditorID = V.ListID
				Data.AreaID = MapEditorID
				if MapEditorID then
					local EObjData = MapEditDataMgr:GetEObjByListID(MapEditorID)
					if EObjData then
						Data.Point = {X = math.floor(EObjData.Point.X), Y = math.floor(EObjData.Point.Y), Z = math.floor(EObjData.Point.Z)}
					end
				end
				Data.Num = 1
				Data.Type = self.DataTypeDefine.Aether
				table.insert(DataList, Data)
			end
		end
	end
	return DataList
end

-- 探索笔记数据
function FieldTestMgr:GetDiscoverDataList()
	local DataList = {}
	local Name = "Unknown"
	local MapID = PWorldMgr:GetCurrMapResID()
	local Map = MapCfg:FindCfgByKey(MapID)
    if Map then
        Name = Map.DisplayName
	end
	local DiscoverDataList = DiscoverNoteCfg:FindAllCfg(string.format("MapID=%d", MapID))
	if DiscoverDataList then
		for _, V in pairs(DiscoverDataList) do
			local Data = {}
			local NoteID = V.ID
			Data.ID = NoteID
			local BaseName = V.Shorthand or "未知"
			if DiscoverNoteMgr:IsNotePointUnderPerfectCondByNoteID(NoteID) then
				Data.Name = string.format("%s State:完美", BaseName)
			else
				Data.Name = string.format("%s State:普通", BaseName)
			end
			
			local EobjResID = V.EobjID
			Data.AreaID = V.AreaID
			if EobjResID then
				local EObjData = MapEditDataMgr:GetEObjByResID(EobjResID)
				if EObjData then
					Data.Point = {X = math.floor(EObjData.Point.X), Y = math.floor(EObjData.Point.Y), Z = math.floor(EObjData.Point.Z)}
				end
			end
			Data.Num = 1
			Data.Type = self.DataTypeDefine.DiscoverNote
			table.insert(DataList, Data)
		end
	end
	return DataList
end

--- 野外宝箱数据
function FieldTestMgr:GetWildBoxDataList()
	local DataList = {}

	local MapID = PWorldMgr:GetCurrMapResID()
	local SearchCondition = string.format("MapID=%d", MapID)
	local WildBoxMoundFindCfgs = WildBoxMoundCfg:FindAllCfg(SearchCondition)
    for _, Cfg in ipairs(WildBoxMoundFindCfgs or {}) do
		local Data = {}
		Data.ID = Cfg.EmptyListID
		Data.Name = WildBoxMoundMgr:IsBoxOpened(MapID, Cfg.EmptyListID) and "已开" or "未开"
		Data.Num = 1
		Data.Type = self.DataTypeDefine.WildBox
        local EObj = _G.MapEditDataMgr:GetEObjByListID(Cfg.EmptyListID)
        if EObj then
			Data.Point = {
				X = math.floor(EObj.Point.X),
				Y = math.floor(EObj.Point.Y),
				Z = math.floor(EObj.Point.Z),
			}
        end
		table.insert(DataList, Data)
    end
	
	return DataList
end

function FieldTestMgr:GetEntityAndTypeAndID(Line)
	local List = string.split(Line, "-")
	local ids = string.split(List[2], '.')
	return tonumber(List[1]), tonumber(ids[1]), tonumber(ids[2])
end

function FieldTestMgr:GetPoint(XYZ)
	local Array = string.split(XYZ, ",")
	local S1 = string.gsub(Array[1], "pos:%(", "")
	local S2 = Array[2]
	local S3 = string.gsub(Array[3], "%)", "")
	return {X = tonumber(S1), Y = tonumber(S2), Z = tonumber(S3)}
end

function FieldTestMgr:GetPointMulti(X, Y, Z)
	local S1 = string.gsub(X, "pos:%(", "")
	local S2 = Y
	local S3 = string.gsub(Z, "%)", "")
	return {X = tonumber(S1), Y = tonumber(S2), Z = tonumber(S3)}
end

function FieldTestMgr:GetListID(Line)
	local ListID = string.gsub(Line, "id:", "")
	return tonumber(ListID)
end

function FieldTestMgr:DebugGetMapResIDList(TypeName)
	local DataList = {}
	if TypeName == "npc" then
		DataList = self.NpcDataList
	elseif TypeName == "monster" then
		DataList = self.MonsterDataList
	end

	local ResIDArray = UE.TArray(UE.uint32)
	-- ResIDArray:Add(11)
	-- ResIDArray:Add(12)
	for index = 1, #DataList do
		ResIDArray:Add(DataList[index].ID)
	end

	return ResIDArray
end

function FieldTestMgr:DebugGetMapResPosList(TypeName, ResID)
	local DataList = {}
	if TypeName == "npc" then
		DataList = self.NpcDataList
	elseif TypeName == "monster" then
		DataList = self.MonsterDataList
	end

	local Points = UE.TArray(UE.FVector)
	if not DataList then
		return Points
	end
	for index = 1, #DataList do
		local DataItem = DataList[index]
		if DataItem.ID == ResID then
			for j = 1, #DataItem.Children do
				local Point = DataItem.Children[j].Point
				Points:Add(UE.FVector(Point.X, Point.Y, Point.Z))
			end
		end
	end

	return Points
end

function FieldTestMgr:DebugGetMapResName(TypeName, ResID)
	local DataList = {}
	if TypeName == "npc" then
		DataList = self.NpcDataList
	elseif TypeName == "monster" then
		DataList = self.MonsterDataList
	end

	for index = 1, #DataList do
		local DataItem = DataList[index]
		if DataItem.ID == ResID then
			return DataItem.Name
		end
	end

	return ""
end

return FieldTestMgr
