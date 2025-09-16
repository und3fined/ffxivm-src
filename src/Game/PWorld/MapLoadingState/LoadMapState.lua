local LuaClass = require("Core/LuaClass")
local LoadingStateBase = require("Game/PWorld/MapLoadingState/LoadingStateBase")
local PathMgr = require("Path/PathMgr")

--切地图
local LoadMapState = LuaClass(LoadingStateBase, true)

function LoadMapState:Ctor()
    self.MapResID = 0
end

function LoadMapState:EnterState()
    if (self.MapResID == 0) then
        _G.FLOG_INFO("PWorldMgr LoadMapState:EnterState MapResID value is 0!!!!!")
        return
    end

    local UWorldMgr = _G.UE.UWorldMgr:Get()
    if (UWorldMgr ~= nil) then
        local MapResID = self.MapResID
        local MapTableCfg = _G.PWorldMgr:GetMapTableCfg(MapResID)
        if (MapTableCfg == nil) then
            _G.FLOG_WARNING("PWorldMgr LoadMapState:EnterState MapResID is error, MapResID=%d", MapResID)
            return
        end

        local LevelID = MapTableCfg.LevelID or 0
        local MapResTableCfg = _G.PWorldMgr:GetMapResTableCfg(LevelID)
        if MapResTableCfg == nil then
            _G.FLOG_WARNING("PWorldMgr LoadMapState:EnterState LevelID is error, LevelID=%d", LevelID)
            return
        end

        local NewMapPath = MapResTableCfg.PersistentLevelPath
        if (string.isnilorempty(NewMapPath)) then
            _G.FLOG_WARNING("PWorldMgr LoadMapState:EnterState PersistentLevelPath is error, LevelID=%d", LevelID)
            return
        end

        -- 检测到关卡资源缺失，上报给后台，由后台把角色传送回原来的地图
        if "A" ~= MapResTableCfg.PackageName and  _G.CommonUtil.ShouldDownloadRes() then
            _G.FLOG_WARNING("PWorldMgr LoadMapState:EnterState level resource is not downloaded, MapResID=%d LevelID=%d NewMapPath=%s", MapResID, LevelID, NewMapPath)

            _G.PWorldMgr:SendLackOfResource()
            _G.MsgTipsUtil.ShowTips(_G.LSTR("场景资源不存在"))

            _G.PWorldMgr:SetShowDownloadResMsgBox()

            return
        end

        local NewMapName = PathMgr.GetCleanFilename(NewMapPath)
        if (NewMapName ~= nil and NewMapName ~= "") then
            _G.FLOG_INFO("PWorldMgr LoadMapState:EnterState NewMapName=%s", NewMapName)
            local LoadWorldReason = _G.UE.ELoadWorldReason.Normal
            _G.PWorldMgr:SetLoadWorldReason(LoadWorldReason)

            _G.WorldMsgMgr:ForceMarkLastLevelLoadCompleted()

            UWorldMgr:LoadWorld(NewMapPath, LoadWorldReason)
        end

    end
end

function LoadMapState:ExitState()
    self.MapResID = 0
end

return LoadMapState
