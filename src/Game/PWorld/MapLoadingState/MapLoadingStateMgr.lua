--
-- Author: haialexzhou
-- Date: 2024-12-26
-- Description:副本地图加载状态管理

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")

--主要的加载阶段
local LoadMapState = require("Game/PWorld/MapLoadingState/LoadMapState")
local LoadMapEditCfgState = require("Game/PWorld/MapLoadingState/LoadMapEditCfgState")
local LoadSubLevelInSequenceState = require("Game/PWorld/MapLoadingState/LoadSubLevelInSequenceState")
local LoadMapFinishState = require("Game/PWorld/MapLoadingState/LoadMapFinishState")
local SendReadyState = require("Game/PWorld/MapLoadingState/SendReadyState")
local EnterMapFinishState = require("Game/PWorld/MapLoadingState/EnterMapFinishState")

--顺序：LoadMap-》LoadMapEditCfg-》LoadSublevelsInAutoSequence-》LoadMapFinish--SendGetMapData-》SendReady-》EnterMapFinish

---@class MapLoadingStateMgr : MgrBase
local MapLoadingStateMgr = LuaClass(MgrBase)

function MapLoadingStateMgr:OnInit()
    self.CurrentStateBoj = nil
    self.LoadMapStateObj = LoadMapState.New()
    self.LoadMapEditCfgStateObj = LoadMapEditCfgState.New()
    self.LoadSubLevelInSequenceStateObj = LoadSubLevelInSequenceState.New()
    self.LoadMapFinishStateObj = LoadMapFinishState.New()
    self.SendReadyStateObj = SendReadyState.New()
    self.EnterMapFinishStateObj = EnterMapFinishState.New()
end

function MapLoadingStateMgr:OnEnd()
    self.CurrentStateBoj = nil
    self.LoadMapStateObj = nil
    self.LoadMapEditCfgStateObj = nil
    self.LoadSubLevelInSequenceStateObj = nil
    self.LoadMapFinishStateObj = nil
    self.SendReadyStateObj = nil
    self.EnterMapFinishStateObj = nil
end

--加载地图
function MapLoadingStateMgr:LoadMap(MapResID)
    if (self.LoadMapStateObj) then
        self.LoadMapStateObj.MapResID = MapResID
        self:ChangeState(self.LoadMapStateObj)
    end
end

--加载地图数据
function MapLoadingStateMgr:LoadMapEditCfg(MapResID)
    if (self.LoadMapEditCfgStateObj) then
        self.LoadMapEditCfgStateObj.MapResID = MapResID
        self:ChangeState(self.LoadMapEditCfgStateObj)
    end
end

--加载邻近地图数据回调
function MapLoadingStateMgr:OnLoadAdjacentMapEditCfg(BodyBuffer)
    if (self.LoadMapEditCfgStateObj) then
        self.LoadMapEditCfgStateObj:OnLoadAdjacentMapEditCfg(BodyBuffer)
    end
end

function MapLoadingStateMgr:OnLoadFestivalMapEditCfg(BodyBuffer)
    if (self.LoadMapEditCfgStateObj) then
        self.LoadMapEditCfgStateObj:OnLoadFestivalMapEditCfg(BodyBuffer)
    end
end

--加载地图数据回调
function MapLoadingStateMgr:OnLoadMapEditCfg(BodyBuffer)
    if (self.LoadMapEditCfgStateObj) then
        self.LoadMapEditCfgStateObj:OnLoadMapEditCfg(BodyBuffer)
    end

    self:LoadSublevelsInAutoSequence()
end


--加载进地图后自动播放的Sequence用到的子level
function MapLoadingStateMgr:LoadSublevelsInAutoSequence()
    if (self.LoadSubLevelInSequenceStateObj) then
        self:ChangeState(self.LoadSubLevelInSequenceStateObj)
    end
end

--加载地图完成, 初始化数据和创建Major
function MapLoadingStateMgr:LoadMapFinish()
    if (self.LoadMapFinishStateObj) then
        self:ChangeState(self.LoadMapFinishStateObj)
    end
end

--发送Seady给服务器
function MapLoadingStateMgr:SendReady()
    if (self.SendReadyStateObj) then
        self:ChangeState(self.SendReadyStateObj)
    end
end

--进入地图完成
function MapLoadingStateMgr:EnterMapFinish()
    self:SendReady()

    if (self.EnterMapFinishStateObj) then
        self:ChangeState(self.EnterMapFinishStateObj)
    end
end

function MapLoadingStateMgr:ChangeState(NewStateObj)
    --加个判断，否则Exit会重置前面最新的赋值
    if (self.CurrentStateBoj ~= nil and self.CurrentStateBoj ~= NewStateObj) then
        self.CurrentStateBoj:ExitState()
    end

    self.CurrentStateBoj = NewStateObj
    
    if (self.CurrentStateBoj) then
        self.CurrentStateBoj:EnterState()
    end
end

return MapLoadingStateMgr