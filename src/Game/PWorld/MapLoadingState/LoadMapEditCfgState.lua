local LuaClass = require("Core/LuaClass")
local LoadingStateBase = require("Game/PWorld/MapLoadingState/LoadingStateBase")
local ProtoBuff = require("Network/ProtoBuff")
local MapCfg = require("TableCfg/MapCfg")

local LoadMapEditCfgState = LuaClass(LoadingStateBase, true)

function LoadMapEditCfgState:Ctor()
    self.MapResID = 0
end

function LoadMapEditCfgState:EnterState()
    if (self.MapResID == 0) then
        _G.FLOG_INFO("PWorldMgr LoadMapEditCfgState:EnterState MapResID value is 0!!!!!")
        return
    end

    --加载关卡编辑器数据， 加载后从c++调用lua函数OnLoadMapEditCfg
    local PWorldMgrInstance = _G.UE.UPWorldMgr:Get()
    PWorldMgrInstance:LoadMapEditCfg(self.MapResID)
end

function LoadMapEditCfgState:OnLoadMapEditCfg(BodyBuffer)
    local _ <close> =  _G.CommonUtil.MakeProfileTag("OnLoadMapEditCfg")
	local MapEditCfg = ProtoBuff:Decode("mapedit.MapEditCfg", BodyBuffer)
    if (MapEditCfg ~= nil) then
        _G.FLOG_INFO("PWorldMgr LoadMapEditCfgState:OnLoadMapEditCfg MapEditCfg.MapID:%d self.MapResID:%d", MapEditCfg.MapID, self.MapResID)

        _G.MapEditDataMgr:InitMapEditCfg(MapEditCfg)
        _G.QuestTrackMgr:OnMapEditCfgLoaded(MapEditCfg)

        local PWorldDynDataMgr = _G.PWorldMgr:GetPWorldDynDataMgr()
        PWorldDynDataMgr:Init()

        --加载所有相邻地图的编辑器地图数据，并缓存
        self:LoadAdjacentMapEditCfgs(MapEditCfg)
    end
end

function LoadMapEditCfgState:LoadAdjacentMapEditCfgs(MapEditCfg)
    local _ <close> =  _G.CommonUtil.MakeProfileTag("LoadAdjacentMapEditCfgs")
    _G.MapEditDataMgr:ClearAdjacentMapEditCfg()
    local PWorldMgrInstance = _G.UE.UPWorldMgr:Get()
    local TransPointList = MapEditCfg.TransPointList
    for _, TransPoint in ipairs(TransPointList) do
        if (#TransPoint.TransTargetList > 0) then
            local TransTarget = TransPoint.TransTargetList[1]
            if (TransTarget ~= nil) then
                local MapTableCfg = MapCfg:FindCfgByKey(TransTarget.TargetMapID)
                if (MapTableCfg and MapTableCfg.MapEditFile) then
                    local MapEditFile = MapTableCfg.MapEditFile
                    if string.len(MapEditFile) > 0 then
                        FLOG_INFO("LoadAdjacentMapEditCfg: mapid:%d, %s", TransTarget.TargetMapID, MapEditFile)
                        PWorldMgrInstance:LoadAdjacentMapEditCfg(MapEditFile)
                    end
                end
            end
        end
    end
end

--加载相邻地图的关卡编辑器的地图数据
function LoadMapEditCfgState:OnLoadAdjacentMapEditCfg(BodyBuffer)
    local _ <close> =  _G.CommonUtil.MakeProfileTag("OnLoadAdjacentMapEditCfg")
	local MapEditCfg = ProtoBuff:Decode("mapedit.MapEditCfg", BodyBuffer)
    if (MapEditCfg ~= nil) then
        _G.MapEditDataMgr:InitAdjacentMapEditCfg(MapEditCfg)
        _G.QuestTrackMgr:OnMapEditCfgLoaded(MapEditCfg)
    end
end

function LoadMapEditCfgState:OnLoadFestivalMapEditCfg(BodyBuffer)
    local _ <close> =  _G.CommonUtil.MakeProfileTag("OnLoadFestivalMapEditCfg")
    local MapEditCfg = ProtoBuff:Decode("mapedit.MapEditCfg", BodyBuffer)
    if (MapEditCfg ~= nil) then
        _G.MapEditDataMgr:InitFestivalMapEditCfg(MapEditCfg)
        _G.QuestTrackMgr:TryInitQuestParams(MapEditCfg.MapID)
    end
end

function LoadMapEditCfgState:ExitState()
    self.MapResID = 0
end

return LoadMapEditCfgState