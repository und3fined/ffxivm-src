local LuaClass = require("Core/LuaClass")
local LoadingStateBase = require("Game/PWorld/MapLoadingState/LoadingStateBase")
local MainPanelVM = require("Game/Main/MainPanelVM")
local MajorUtil = require("Utils/MajorUtil")

--加载地图完成，初始化其他数据(地图动态数据不在这里初始化)，创建Major
local LoadMapFinishState = LuaClass(LoadingStateBase, true)

function LoadMapFinishState:Ctor()
end

function LoadMapFinishState:EnterState()
    local _ <close> =  _G.CommonUtil.MakeProfileTag("LoadMapFinishState:EnterState")

    local PWorldElevatorMgr = _G.PWorldMgr:GetPWorldElevatorMgr()
    local CrystalPortalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
    local PWorldDynDataMgr = _G.PWorldMgr:GetPWorldDynDataMgr()
    local MapQuestObjMgr = _G.PWorldMgr:GetMapQuestObjMgr()
    local PWorldMechanismDataMgr = _G.PWorldMgr:GetPWorldMechanismDataMgr()

    PWorldElevatorMgr:Init()
    MapQuestObjMgr:Init()
    CrystalPortalMgr:OnMapLoaded(_G.PWorldMgr:GetCurrMapResID())
    _G.ClientVisionMgr:OnMapLoaded()
    PWorldMechanismDataMgr:Init()

    local bChangeMap = _G.PWorldMgr:IsChangeMap()
    if (bChangeMap) then
        _G.PWorldMgr:ExecSetSOCType()
    end

    _G.WorldMsgMgr:PreLoadResources(bChangeMap)

    if (bChangeMap) then
        local CurrPWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
        if (_G.PWorldMgr:CurrIsInDungeon()) then
            _G.PWorldStageMgr:InitPWorldStageInfo(CurrPWorldResID)
            MainPanelVM:SetPWorldStageVisible(true)
        else
            _G.PWorldWarningMgr:ClearWarningGroupData()
            MainPanelVM:SetPWorldStageVisible(false)
            MainPanelVM:SetWarningSkillCDItemListVisibile(false)
        end

        local PWorldTableCfg = _G.PWorldMgr:GetPWorldTableCfg(CurrPWorldResID)
        if (PWorldTableCfg ~= nil) then
            local PWorldMgrInstance = _G.UE.UPWorldMgr:Get()
            PWorldMgrInstance:SetPWorldType(PWorldTableCfg.Type)
            PWorldMgrInstance:SetPWorldSubType(PWorldTableCfg.SubType)
        end
    end

    local FLOG_INFO = _G.FLOG_INFO
    FLOG_INFO("PWorldMgr LoadMapFinishState:EnterState bChangeMap=%s", bChangeMap)

    local LoadWorldReason = _G.PWorldMgr:GetLoadWorldReason()
    local MajorEntityID = _G.PWorldMgr:GetMajorEntityID()
    if (LoadWorldReason == _G.UE.ELoadWorldReason.RestoreNormal) then
        -- sequence结束后传送回来，不需要走后面的判断逻辑
        _G.PWorldMgr:CreateMajor()

    elseif not bChangeMap then
        local Major = MajorUtil.GetMajor()
        if Major then
            -- 同地图切换，包括：地图内传送，地图切线
            -- PWorldMapExit事件处理会清掉视野，保留主角；地图切线时，要求保持主角位置、相机等一致
            if _G.PWorldMgr:IsTransInSameMap() then
                FLOG_INFO("PWorldMgr LoadMapFinishState:EnterState trans in same map")
                if Major:IsInFly() then
                    Major:SwitchFly(false, false)
                end
                _G.PWorldMgr:SetMajorPosAndRotationToBirthPoint()
                _G.UE.UActorManager:Get():EnableMajor()
                Major:OnMajorCreate(MajorEntityID, true, true)

            elseif _G.PWorldMgr:IsChangeLine() then
                FLOG_INFO("PWorldMgr LoadMapFinishState:EnterState change line")
                Major:OnMajorCreate(MajorEntityID, true, true)

            elseif _G.PWorldMgr:IsCrossWorld() then
                FLOG_INFO("PWorldMgr LoadMapFinishState:EnterState cross world")
                Major:OnMajorCreate(MajorEntityID, true, true)

            elseif _G.PWorldMgr:IsReconnectInSameMap() then
                FLOG_INFO("PWorldMgr LoadMapFinishState:EnterState reconnect in same map")
                Major:OnMajorCreate(MajorEntityID, true, true)
            end
        else
            FLOG_INFO("PWorldMgr LoadMapFinishState:EnterState CreateMajor because major is nil")
            _G.PWorldMgr:CreateMajor()
        end
    else
        local Major = MajorUtil.GetMajor()
        if Major and _G.PWorldMgr:IsChangePhaseMap() then
            FLOG_INFO("PWorldMgr LoadMapFinishState:EnterState change phase map")
            Major:OnMajorCreate(MajorEntityID, true, true)
        else
            --Major创建和设置坐标要放到SendGetMapData之前，因为PlayerCameraManager更新ViewTarget有坐标的变化，过程会被表现出来(Loading被Hide后)
            FLOG_INFO("PWorldMgr LoadMapFinishState:EnterState CreateMajor default")
            _G.PWorldMgr:CreateMajor()
        end
    end

    _G.ActorMgr:PreCreateActors()

    --BGM的播放需要在AudioProxy即Major创建之后, 且不在副本
    if not _G.PWorldMgr:CurrIsInDungeon() then
        PWorldDynDataMgr:PlayMusicBySceneID(PWorldDynDataMgr.MapBGMusic)
    end

    PWorldDynDataMgr:LoadDynDataAfterLoadWorldFinish() --有些数据需要在createMajor之后初始化

    _G.PWorldMgr:SetMapTravelStatusFinish()
    _G.PWorldMgr:SendGetMapData()
end

function LoadMapFinishState:ExitState()
end

return LoadMapFinishState
