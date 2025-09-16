--
-- Author: zerodeng
-- Date: 2024-5-23
-- Description:自动寻路管理器
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local EventID = require("Define/EventID")
local AutoMoveTargetType = require("Define/AutoMoveTargetType")
local ProtoRes = require("Protocol/ProtoRes")
local MajorUtil = require("Utils/MajorUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
--local ProtoCS = require("Protocol/ProtoCS")
local CrystalPortalCfg = require("TableCfg/TeleportCrystalCfg")
local AutoPathMapGroupCfg = require("TableCfg/AutoPathMapGroupCfg")
local CommStatCfg = require("TableCfg/CommStatCfg")
local AutoPathMoveImpl = require("Game/PWorld/AutoPathMove/AutoPathMoveImpl")
local NavigationPathMgr = require("Game/PWorld/Navigation/NavigationPathMgr")
local NavigationConfigCfg = require("TableCfg/NavigationConfigCfg")

local TransitionType = ProtoRes.transition_type
local NavigationConfigType = ProtoRes.navigation_config_type
local ModuleType = ProtoRes.module_type

local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_INFO = _G.FLOG_INFO
local FLOG_WARNING = _G.FLOG_WARNING

---@class AutoPathMoveMgr : MgrBase
local AutoPathMoveMgr = LuaClass(MgrBase)

AutoPathMoveMgr.EMoveType = {
    None = 0,
    Crystal = 1,
    TransEdge = 2,
    Actor = 3,
    Point = 4,
    MapPath = 5 --中间状态
}

AutoPathMoveMgr.EErrorCode = {
    None = 0,           
    Invalid = 1,    --系统未开启（后台控制）
    Disabled = 2,   --开关未打开
    Closed = 3,     --系统未开放
    NoPath = 4,     --没有路径可达
    UnlockMap = 5,  --地图未解锁
    MajorDisabled = 6,  --主角限制
}

--排除的同区域传送地图，不计算传送次数
AutoPathMoveMgr.ExcludeMapsForZoneTransform = {
    1065,
    1066
}

function AutoPathMoveMgr:OnInit()
    AutoPathMoveImpl:OnInit(self)
    self.DstMapID = 0
    self.DstPos = {}
    self.TargetType = 0
    self.IsDstPosRejust = false
    self.CrystalTransMinDist = 3000
    self.AutoPathStartMinDist = 300
    self.CrystalAndSrcPosMinDist = 4000

    --开启状态，设置面板
    self.IsEnable = false

    --任意水晶解锁
    self.IsAutoPathMoveOpenState = false

    --第一个解锁
    self.IsFirstUnlock = true

    self.CacheMapUnlock = {}
    self.CacheGroupBigCrystalIDList = {}

    self.CommStatExcludeMovingList = {}

    self.MapForActivCrystal = {}
end

function AutoPathMoveMgr:OnBegin()
    --获取通用状态表-移动互斥所有状态
    local MoveStateCfg = CommStatCfg:FindCfgByKey(ProtoCommon.CommStatID.COMM_STAT_MOVING)

    for i = 1, #MoveStateCfg.Relation do
        --ID对应Index 
        if (MoveStateCfg.Relation[i] == ProtoCommon.CommStatRelation.COMM_STAT_RELATION_EXCLUDE) then
            local CommStatID = i-1
            table.insert(self.CommStatExcludeMovingList, CommStatID)
        end
    end

    local cfg = NavigationConfigCfg:FindCfgByKey(NavigationConfigType.CRYSTAL_TRANS_MIN_DIST)
    if (cfg ~= nil) then
        self.CrystalTransMinDist = cfg.Value        
    end

    cfg = NavigationConfigCfg:FindCfgByKey(NavigationConfigType.AUTOPATH_START_MIN_DIST)
    if (cfg ~= nil) then
        self.AutoPathStartMinDist = cfg.Value        
    end

    cfg = NavigationConfigCfg:FindCfgByKey(NavigationConfigType.CRYSTAL_SRC_POS_MIN_DIST)
    if (cfg ~= nil) then
        self.CrystalAndSrcPosMinDist = cfg.Value        
    end

    FLOG_INFO("AutoPathMoveMgr: CrystalTransMinDist=%d, AutoPathStartMinDist=%d", self.CrystalTransMinDist, self.AutoPathStartMinDist)

    AutoPathMoveImpl:OnBegin()
end

function AutoPathMoveMgr:OnShutdown()
    AutoPathMoveImpl:OnShutdown()

    self.DstMapID = nil
    self.DstPos = nil
    self.TargetType = nil
    self.IsDstPosRejust = nil

    self.IsEnable = nil
    self.IsAutoPathMoveOpenState = nil
    self.IsFirstUnlock = nil
    self.CacheMapUnlock = nil
    self.CacheGroupBigCrystalIDList = nil
    self.CommStatExcludeMovingList = nil
    self.MapForActivCrystal = nil
end

function AutoPathMoveMgr:OnRegisterNetMsg()
    AutoPathMoveImpl:RegisterGameNetMsg(self)
end

function AutoPathMoveMgr:OnRegisterGameEvent()
    AutoPathMoveImpl:RegisterGameEvent(self)

    --- 监听激活水晶
    --self:RegisterGameEvent(EventID.CrystalActivated, self.OnCrystalActivated)

    self:RegisterGameEvent(EventID.MajorCreate, self.OnMajorCreate)
end

--监听角色主角创建事件
function AutoPathMoveMgr:OnMajorCreate()
    --设置面板设置
    local SwitchOn = _G.LoginMgr:IsModuleSwitchOn(ModuleType.MODULE_NAVI)

    FLOG_INFO("AutoPathMoveMgr SwitchOn:%s", tostring(SwitchOn))
    _G.SettingsMgr:ShowBySaveKey("AutoPathMove", SwitchOn)
end

--开启状态，设置面板
function AutoPathMoveMgr:SetAutoPathMoveEnable(IsEnable)
    self.IsEnable = IsEnable
end

--自动寻路是否可用
function AutoPathMoveMgr:IsAutoPathMoveEnable()    
    local SwitchOn = _G.LoginMgr:IsModuleSwitchOn(ModuleType.MODULE_NAVI)
    
    if (not SwitchOn) then
        FLOG_WARNING("AutoPathMove: system is off!")
        return false, self.EErrorCode.Invalid
    end

    if (not self.IsEnable) then
        FLOG_WARNING("AutoPathMove: system set disabled!")
        return false, self.EErrorCode.Disabled
    end
    
    if (not self:IsAutoPathMoveOpen()) then
        FLOG_WARNING("AutoPathMove: system is closed!")
        return false, self.EErrorCode.Closed
    end
    
    return true
end

--主角是否可以自动寻路(各种状态，控制等)
function AutoPathMoveMgr:IsMajorAutoPathMoveEnable()
    local Major = MajorUtil.GetMajor()
    if not Major then
        return false
    end
    local MajorStatComp = Major:GetStateComponent()
    if not MajorStatComp then -- 先按照是否为nil进行判断，若后续仍有报错再添加具体的判断
        return false
    end   

    --战斗状态
    if (MajorStatComp:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT)) then
        _G.MsgTipsUtil.ShowTipsByID(40194)
        return false
    end

    --非战斗状态-(服务器)通用状态表中无法移动；（客户端）飞行状态，被控制无法移动状态，陆行鸟运行中
    --通用状态：当前状态是否同移动互斥    
    for _, Value in ipairs(self.CommStatExcludeMovingList) do
        if (MajorStatComp:IsInNetState(Value)) then            
            FLOG_INFO("AutoPathMoveMgr: can not auto move! state=%d", Value)

            _G.MsgTipsUtil.ShowTipsByID(40191)
            return false            
        end
    end

    --跳跃状态
    if (MajorUtil.IsFalling()) then
        FLOG_INFO("AutoPathMoveMgr: can not auto move! is falling state!")
        _G.MsgTipsUtil.ShowTipsByID(40191)
        return false
    end

    --摇杆移动中
    local ActorManager = _G.UE.UActorManager:Get()
    if ActorManager then
        local bLocked = ActorManager:GetVirtualJoystickIsSprintLocked()
        local Velocity = Major.CharacterMovement.Velocity:Size()

        --FLOG_INFO("AutoPathMoveMgr: Velocity=%s", tostring(Velocity))
        if (not bLocked and Velocity > 0 and not self:IsAutoPathMovingState()) then
            FLOG_INFO("AutoPathMoveMgr: can not auto move! virtual joy stick moving!")
            _G.MsgTipsUtil.ShowTipsByID(40191)
            return false
        end
    end

    --飞行状态不可寻路    
    if (Major:IsInFly()) then
        _G.MsgTipsUtil.ShowTipsByID(40190)
        return false
    end

    --陆行鸟运行中
    if _G.ChocoboTransportMgr:GetIsTransporting() then
        FLOG_INFO("AutoPathMoveMgr: can not auto move! in transporting state")

        _G.MsgTipsUtil.ShowTipsByID(40191)
        return false
    end

    --被控制无法移动状态
    local CanMove = MajorStatComp:GetActorControlState(_G.UE.EActorControllStat.CanMove)
    if (not CanMove) then
        FLOG_INFO("AutoPathMoveMgr: can not auto move! not canmove")

        _G.MsgTipsUtil.ShowTipsByID(40191)
        return false
    end

    --召唤乘骑中
    if (_G.MountMgr:IsRequestingMount()) then
        FLOG_INFO("AutoPathMoveMgr: can not auto move! in requesting mount")

        _G.MsgTipsUtil.ShowTipsByID(40191)
        return false
    end

    --技能是否可被打断
	local EntityID = MajorUtil.GetMajorEntityID()	
    local CurrentWeight = _G.SkillObjectMgr:GetCurrentSkillWeight(EntityID)
    
    if (CurrentWeight >= 0) then
        FLOG_INFO("AutoPathMoveMgr: can not auto move, currentWeight=%d", CurrentWeight)

        _G.MsgTipsUtil.ShowTipsByID(40191)
        return false
    end

    --除了主城&野外&私人，其他都不能自动寻路
    if (not (_G.PWorldMgr:CurrIsInMainCity() or _G.PWorldMgr:CurrIsInField() or _G.PWorldMgr:CurrIsInPrivateDungeon())) then        
        FLOG_INFO("AutoPathMoveMgr: can not auto move! not maincity or field! or private")
        return false
    end

    return true
end


---@param SrcMapID 源地图ID
---@param SrcPos 起始位置
---@param DstMapID 目标地图ID
---@param DstPos 目标位置
---@param TargetType 自动寻路类型（任务，地图等）
---@param IsDstPosRejust 是否需要终点偏移，true:离终点一定距离停止，false:同终点重合
---@return false, EErrorCode | true ExecMoveData
function AutoPathMoveMgr:AutoPathMove(SrcMapID, SrcPos, DstMapID, DstPos, TargetType, IsDstPosRejust)    
    local Ret, ErrorCode = self:IsAutoPathMoveEnable()
    if (not Ret) then
        FLOG_ERROR("AutoPathMove: disable!")
        return false, ErrorCode
    end

    return self:AutoPathMoveInteral(SrcMapID, SrcPos, DstMapID, DstPos, TargetType, IsDstPosRejust)
end

---@parivate 内部使用
function AutoPathMoveMgr:AutoPathMoveInteral(SrcMapID, SrcPos, DstMapID, DstPos, TargetType, IsDstPosRejust)
    local OrignSrcMapID = SrcMapID
    local OrignDstMapID = DstMapID

        --动态地图矫正
    SrcMapID = NavigationPathMgr:RejustDynamicMap(SrcMapID)
    DstMapID = NavigationPathMgr:RejustDynamicMap(DstMapID)

    if (OrignSrcMapID ~= SrcMapID or OrignDstMapID ~= DstMapID) then
        FLOG_INFO("DynamicMap,SrcMapID=%d, RejustSrcMapID=%d, DstMapID=%d, RejustDstMapID=%d", 
        OrignSrcMapID, SrcMapID, OrignDstMapID, DstMapID)
    end

    if (self:IsAutoPathMovingState() and self.DstMapID == DstMapID and self.DstPos == DstPos) then
        FLOG_INFO("AutoPathMoveMgr: same dstmapid and dstpos!")
        return false
    end
    
    --目标地图是否开启
    local IsUnlockAutoPath = self:IsUnlockAutoPath(DstMapID)
    if (not IsUnlockAutoPath) then
        _G.MsgTipsUtil.ShowTipsByID(40193)
        return false, self.EErrorCode.UnlockMap
    end

    --状态不可以
    if (not self:IsMajorAutoPathMoveEnable()) then        
        return false, self.EErrorCode.MajorDisabled
    end

    --距离太短
    if (SrcMapID == DstMapID) then
        local UESrcPos = _G.UE.FVector(SrcPos.X, SrcPos.Y, SrcPos.Z)
        local UEDstPos = _G.UE.FVector(DstPos.X, DstPos.Y, DstPos.Z)

        local Distance = _G.UE.FVector.Dist(UESrcPos, UEDstPos) 
        if (Distance < self.AutoPathStartMinDist) then
            FLOG_INFO("AutoPathMove: SrcPos is nearest to DstPos")
            return false
        end
    end

    --table={
    --    {type=CrystalTrans, Data={CrystalID=1, FromMapID=1001, ToMapID=1002} }
    --    {type=MapPath, Data={MapID=1001, Paths={{1,2,4}, {2,3,4}}} }
    --}
    self.DstMapID = DstMapID
    self.DstPos = DstPos
    self.TargetType = TargetType
    self.IsDstPosRejust = IsDstPosRejust

    local TempMoveData = nil

    if (SrcMapID == DstMapID) then
        --0，同地图
        TempMoveData = self:GenerateSameMapPathData(SrcMapID, SrcPos, DstPos)
    else
        TempMoveData = self:GenerateDifferentMapPathData(SrcMapID, SrcPos, DstMapID, DstPos)
    end

    --_G.UE.FProfileTag.StaticBegin("AutoPathMoveMgr:AutoPathMove 3-----")
    if (TempMoveData == nil or #TempMoveData == 0) then
        FLOG_ERROR("AutoPathMove: No path generated!")
        return false, self.EErrorCode.NoPath
    end
    --_G.UE.FProfileTag.StaticEnd()

    --转换可执行寻路数据
    --_G.UE.FProfileTag.StaticBegin("AutoPathMoveMgr:AutoPathMove 2-----")
    local ExecMoveData = self:ConvertToExecMoveData(TempMoveData, IsDstPosRejust)
    local CacheExecMoveData = table.clone(ExecMoveData)
    --_G.UE.FProfileTag.StaticEnd()

    local TLogData = {SrcMapID=OrignSrcMapID, SrcPos=SrcPos, DstMapID=OrignDstMapID, DstPos=DstPos}

    --执行自动寻路单元
    AutoPathMoveImpl:Start(ExecMoveData, DstMapID, DstPos, TargetType, TLogData)

    return true, CacheExecMoveData
end

--给测试组提供接口
function AutoPathMoveMgr:AutoPathMoveForTest(SrcMapID, SrcPos, DstMapID, DstPos, TargetType, IsDstPosRejust)
    --跳过服务器检查
    if (not self.IsEnable) then
        FLOG_WARNING("AutoPathMove: system set disabled!")
        return false, self.EErrorCode.Disabled
    end

    if (not self:IsAutoPathMoveOpen()) then
        FLOG_WARNING("AutoPathMove: system is closed!")
        return false, self.EErrorCode.Closed
    end

    return self:AutoPathMoveInteral(SrcMapID, SrcPos, DstMapID, DstPos, TargetType, IsDstPosRejust)
end

--CBT2测试需求
--不同地图路径生成
function AutoPathMoveMgr:GenerateDifferentMapPathData(SrcMapID, SrcPos, DstMapID, DstPos)
    --返回数据包
    local RetMoveDataTable = {}

    --Path1:水晶直接传送到目的地图
    local ShortestCrystalID, TransPos = self:GetShortestActivatedCrystalID(DstMapID, DstPos, false)
    if (ShortestCrystalID ~= 0) then        
        --1，水晶传送过去的路径长度
        self:InsertCrystalMoveData(ShortestCrystalID, SrcMapID, DstMapID, RetMoveDataTable)

        --同地图寻路过去
        local SameMapMoveData = self:GenerateSameMapPathData(DstMapID, TransPos, DstPos)
        if (SameMapMoveData == nil) then
            return RetMoveDataTable
        end

        table.insert(RetMoveDataTable, SameMapMoveData[1])        

        --2，如果是相邻地图，需要加入比较             
        local MapPathsTemp = NavigationPathMgr:FindMapPaths(SrcMapID, SrcPos, DstMapID, DstPos)
        if (MapPathsTemp ~= nil and #MapPathsTemp > 0) then
            local LinekNum = 0
            
            for _, Value in pairs(MapPathsTemp) do
                if (Value.Type == NavigationPathMgr.EMapPathType.MapLink) then
                    LinekNum = LinekNum + 1
                elseif (Value.Paths ~= nil) then
                    for _, Path in pairs(Value.Paths) do
                        if ((Path.TransType == TransitionType.TRANSITION_NPC
                            or Path.TransType == TransitionType.TRANSITION_EOBJ)
                            and not table.contain(self.ExcludeMapsForZoneTransform, Value.MapID)) then
                            LinekNum = LinekNum + 1
                        end
                    end
                end
            end
    
            FLOG_INFO("AutoPathMoveMgr: LinekNum=%d", LinekNum)
    
            if (LinekNum == 1) then
                local FullPathMoveDataTable, _ = self:GenerateDifferentMapMoveData(SrcMapID, SrcPos, DstMapID, DstPos)    
                if (FullPathMoveDataTable ~= nil and #FullPathMoveDataTable > 0 ) then
                    --原路径长度
                    local MinDistance = self:GetFullMapPathsDist(SameMapMoveData)
    
                    local TempDistance = self:GetFullMapPathsDist(FullPathMoveDataTable)
                    if (TempDistance < MinDistance) then
                        --删除原记录
                        _G.TableTools.ClearTable(RetMoveDataTable)
        
                        for _, OneData in ipairs(FullPathMoveDataTable) do
                            table.insert(RetMoveDataTable, OneData)
                        end                
                    end
                end
            end
        end

        return RetMoveDataTable
    end
    
    local MapPathsTemp = NavigationPathMgr:FindMapPaths(SrcMapID, SrcPos, DstMapID, DstPos)
    if (MapPathsTemp == nil or #MapPathsTemp == 0) then
        FLOG_INFO("AutoPathMoveMgr: MapPathsTemp is nil")
        return RetMoveDataTable
    end

    --Path2:没有直接水晶过去，但源地图到目标地图中间有水晶可传递
    local AllFullPaths = self:GetAllFullPaths(SrcMapID, DstMapID)
    if (AllFullPaths == nil or #AllFullPaths == 0) then
        --提示无法寻路
        _G.MsgTipsUtil.ShowTipsByID(40195)
        return RetMoveDataTable
    end
    
    --存在多条最短路径，开始比较路径长度
    local MinDistance = 10000000    
    local MinMovaData = {}
    local CrystalTransData = {Valid = false}

    for _, FullPath in ipairs(AllFullPaths) do
        if (#FullPath == 2 or (#FullPath > 2 and not self:IsMapExistActiveCrystal(FullPath[2])) ) then
            --路径没有激活水晶
            local FullPathMoveDataTable, LinkMapNum = self:GenerateDifferentMapMoveData(SrcMapID, SrcPos, DstMapID, DstPos)    
            if (FullPathMoveDataTable ~= nil and #FullPathMoveDataTable > 0 ) then                        
                local TempDistance = self:GetFullMapPathsDist(FullPathMoveDataTable)
                if (TempDistance < MinDistance) then
                    MinDistance = TempDistance
                    MinMovaData = FullPathMoveDataTable

                    CrystalTransData.Valid = false
                end
            end
        elseif (#FullPath > 2 and self:IsMapExistActiveCrystal(FullPath[2]) ) then
            --地图有激活水晶
            local AllActiveCrystalTable = {}
            self:GetAllActiveCrystalID(FullPath[2], AllActiveCrystalTable)
            if (#AllActiveCrystalTable > 0) then
                for _, CrystalID in ipairs(AllActiveCrystalTable) do
                    local Pos = self:GetCrystalTransPos(CrystalID)
                    
                    local FullPathMoveDataTable, LinkMapNum = self:GenerateDifferentMapMoveData(FullPath[2], Pos, DstMapID, DstPos)    
                    local TempDistance = self:GetFullMapPathsDist(FullPathMoveDataTable)
                    if (TempDistance < MinDistance) then
                        MinDistance = TempDistance
                        MinMovaData = FullPathMoveDataTable

                        CrystalTransData.Valid = true
                        CrystalTransData.CrystalID = CrystalID
                        CrystalTransData.SrcMapID = SrcMapID
                        CrystalTransData.DstMapID = FullPath[2]

                        --这里原来的逻辑是先传送到大水晶，然后再内部传递到小水晶。现在可直接传送到小水晶，所有修改水晶传送ID，同时删除地图内水晶传送
                        if (#FullPathMoveDataTable > 1 and FullPathMoveDataTable[1].Type == self.EMoveType.MapPath
                            and #FullPathMoveDataTable[1].Data.Paths > 1 
                            and FullPathMoveDataTable[1].Data.Paths[1].TransType == TransitionType.TRANSITION_Crystal) then
                            --传送到其他水晶，替换当前水晶
                            CrystalTransData.CrystalID = FullPathMoveDataTable[1].Data.Paths[1].CrystalID

                            --删除这条水晶传送路径
                            table.remove(FullPathMoveDataTable[1].Data.Paths, 1)
                        end
                    end
                end
            end
        end
    end

    if (CrystalTransData.Valid) then
        --水晶传送
        self:InsertCrystalMoveData(CrystalTransData.CrystalID, CrystalTransData.SrcMapID, 
        CrystalTransData.DstMapID, RetMoveDataTable)
    end

    for _, OneData in ipairs(MinMovaData) do
        table.insert(RetMoveDataTable, OneData)
    end

    return RetMoveDataTable
end

--获取所有可用的路径：1，纯走路径；2，水晶传送路径
function AutoPathMoveMgr:GetAllFullPaths(SrcMapID, TargetMapID)
    self.MinSuccessPathLength = 10000
    self.SuccessPaths = {}

    self.MinSuccessPathLength_Crystral = 10000
    self.SuccessPaths_Crystral = {}

    if (NavigationPathMgr:CheckConditionChanged()) then
        --清理下缓存，条件有变化，缓存可能失效
        NavigationPathMgr:CacheOneFrameDataClear()
    end

    local InputMapPath = {}

    self:FindAllMapPaths(SrcMapID, TargetMapID,InputMapPath)
    
    if (self.MinSuccessPathLength < self.MinSuccessPathLength_Crystral) then
        return self.SuccessPaths
    elseif (self.MinSuccessPathLength > self.MinSuccessPathLength_Crystral) then
        return self.SuccessPaths_Crystral
    else
        --相等，且不为空
        if (#self.SuccessPaths ~= 0 and #self.SuccessPaths_Crystral ~= 0) then            
            return table.merge_table(self.SuccessPaths, self.SuccessPaths_Crystral)
        else
            return nil
        end
    end
end


function AutoPathMoveMgr:FindAllMapPaths(SrcMapID, TargetMapID, InputMapPath)
    table.insert(InputMapPath, 1, TargetMapID)    

    --从子节点查找父节点
    local ParentMaps = NavigationPathMgr:GetMapTreeParentMaps(TargetMapID)
    
    if (ParentMaps ~= nil) then
        --是否找到目标地图
        local IsFind = false
        for _, MapID in ipairs(ParentMaps) do
            if (MapID == SrcMapID) then
                if (#InputMapPath + 1 <= self.MinSuccessPathLength) then
                    local TempPath = table.clone(InputMapPath)
                    table.insert(TempPath, 1, MapID)

                    self.MinSuccessPathLength = #TempPath

                    --add path
                    table.insert(self.SuccessPaths, TempPath)
                end                

                IsFind = true
            elseif (self:IsMapExistActiveCrystal(MapID)) then
                --是否有水晶传送
                if (#InputMapPath + 2 <= self.MinSuccessPathLength_Crystral) then
                    local TempPath = table.clone(InputMapPath)

                    table.insert(TempPath, 1, MapID)
                    table.insert(TempPath, 1, SrcMapID)

                    self.MinSuccessPathLength_Crystral = #TempPath

                    --add path
                    table.insert(self.SuccessPaths_Crystral, TempPath)
                end          
                
                IsFind = true
            end            
        end
        
        if (IsFind) then
            return
        end

        --递归遍历:当前路径小于最小路径才需要做
        if (#InputMapPath < math.min(self.MinSuccessPathLength, self.MinSuccessPathLength_Crystral)) then
            for _, MapID in ipairs(ParentMaps) do
                --剔除已经找过的地图，避免死循环
                local FindItem, _ = table.find_item(InputMapPath, MapID)

                if (FindItem == nil) then
                    local TempPath = table.clone(InputMapPath)
                    self:FindAllMapPaths(SrcMapID, MapID, TempPath)
                end
            end
        else
            --FLOG_INFO("NavigationPath FindAllPaths: more length! 2")
            InputMapPath = nil
        end
    else
        --叶子节点
        if (SrcMapID == TargetMapID) then
            --是否最短路径
            if (#InputMapPath <= self.MinSuccessPathLength) then
                self.MinSuccessPathLength = #InputMapPath

                --add path
                table.insert(self.SuccessPaths, InputMapPath)
            else
                --FLOG_INFO("NavigationPath FindAllPaths: more length! 0")
                InputMapPath = nil
            end

        elseif (self:IsMapExistActiveCrystal(TargetMapID)) then
            --是否有水晶传送
            if (#InputMapPath + 1 <= self.MinSuccessPathLength_Crystral) then
                table.insert(InputMapPath, 1, SrcMapID)
                self.MinSuccessPathLength_Crystral = #InputMapPath

                --add path
                table.insert(self.SuccessPaths_Crystral, InputMapPath)
            end               
        else
            --delete
            InputMapPath = nil
        end
    end
end


--同地图处理路径数据生成
function AutoPathMoveMgr:GenerateSameMapPathData(MapID, SrcPos, DstPos)

    local NewSrcPos = SrcPos
    local CrystalOnePath = nil

    --激活水晶即可（不区分大小水晶）
    local ShortestCrystalID, TransPos, MinDistance = self:GetShortestActivatedCrystalID(MapID, DstPos, false)
    if (ShortestCrystalID ~= 0) then
        --重新计算新路径
        local PointList = AutoPathMoveImpl:GetCrystalPointList(ShortestCrystalID, DstPos)
        if (PointList ~= nil) then
            local TempDist = 0
            for i = 1, #PointList-1 do
                TempDist = TempDist + _G.UE.FVector.Dist(PointList[i], PointList[i+1])
            end

            MinDistance = TempDist

            FLOG_INFO("AutoPathMoveMgr: use server pointlist!")
        end

        --比较水晶路径长度和直接走过去长度
                    
        local UEStartPos = _G.UE.FVector(SrcPos.X, SrcPos.Y, SrcPos.Z)
        local UEEndPos = _G.UE.FVector(TransPos.X, TransPos.Y, TransPos.Z)
        local CrystalAndSrcPosDistance = _G.UE.FVector.Dist(UEStartPos, UEEndPos)

        local SrcDistance = self:GetMapPosDistance(MapID, SrcPos, DstPos)
        if (SrcDistance > MinDistance and SrcDistance - MinDistance >= self.CrystalTransMinDist and CrystalAndSrcPosDistance >= self.CrystalAndSrcPosMinDist) then
            --30米以上传送,且离水晶超过40米
            NewSrcPos = TransPos

            CrystalOnePath = {}
            CrystalOnePath.StartPos = SrcPos
            CrystalOnePath.EndPos = TransPos
            CrystalOnePath.TransType = TransitionType.TRANSITION_Crystal
            CrystalOnePath.CrystalID = ShortestCrystalID
        end
    end

    --计算路径
    local TempMapPaths = NavigationPathMgr:FindMapPaths(MapID, NewSrcPos, MapID, DstPos)
    if (TempMapPaths == nil or #TempMapPaths == 0) then
        FLOG_ERROR("AutoPathMoveMgr:GenerateSameMapPathData no path find!")
        --_G.UE.FProfileTag.StaticEnd()
        return nil
    end

    --深拷贝，下面有插入操作，避免污染源数据
    local MapPaths = table.deepcopy(TempMapPaths)

    --地图内水晶传送数据，插入最前面
    if (CrystalOnePath ~= nil) then
        table.insert(MapPaths[1].Paths, 1, CrystalOnePath)
    end

    local RetMoveData = {}
    self:InsertMapPathMoveData(MapPaths, RetMoveData)

    --_G.UE.FProfileTag.StaticEnd()

    return RetMoveData
end

--[[不同地图基础路径生成，基本格式：地图内路径->地图间传送->地图内路径
    返回移动数据MoveData=
    {
        {
            Type = EMoveType.MapPath
            Data = MapPathData
        },
        {
            Type = EMoveType.Crystal
            Data = CrystalData
        },
    }
--]]
function AutoPathMoveMgr:GenerateDifferentMapMoveData(SrcMapID, SrcPos, DstMapID, DstPos)
    local RetMoveDataTable = {}

    local MapPathsTemp = NavigationPathMgr:FindMapPaths(SrcMapID, SrcPos, DstMapID, DstPos)

    if (MapPathsTemp == nil or #MapPathsTemp == 0) then
        FLOG_ERROR("GenerateDifferentMapMoveData no path find!")
        return RetMoveDataTable, 0
    end
    
    local MapPaths = {}
    local MapLinkTable = {}

    for _, Value in ipairs(MapPathsTemp) do
        if (Value.Type == NavigationPathMgr.EMapPathType.MapInside) then
           table.insert(MapPaths, Value)
        elseif (Value.Type == NavigationPathMgr.EMapPathType.MapLink) then
            table.insert(MapLinkTable, Value)
        end                    
    end

    if (#MapPaths <= 1) then
        FLOG_ERROR("GenerateDifferentMapMoveData path error! num=%d", #MapPaths)
        return RetMoveDataTable, 0
    end

    --每个地图重新计算自动寻路数据    
    for i = 1, #MapPaths - 1 do
        local MapPath = MapPaths[i]
        local MapID = MapPath.MapID
        local Paths = MapPath.Paths
        local TempSrcPos = Paths[1].StartPos
        local TempDstPos = Paths[#Paths].EndPos

        --重新计算路径
        local TempMoveData = self:GenerateSameMapPathData(MapID, TempSrcPos, TempDstPos)
        if (TempMoveData == nil or #TempMoveData == 0) then
            FLOG_ERROR("GenerateDifferentMapMoveData map=%d, SrcPos=%s, DstPos=%s no path data!", 
            MapID, table.tostring(TempSrcPos), table.tostring(TempDstPos))
            return RetMoveDataTable, 0
        end

        table.insert(RetMoveDataTable, TempMoveData[1])

        --插入地图间链接
        local NextMapPath = MapPaths[i + 1]
        local NextMapID = NextMapPath.MapID
        local MapLinkInfo = 
            table.find_by_predicate(
            MapLinkTable,
            function(A)
                return A.FromMapID == MapID and A.ToMapID == NextMapID
            end
        )


        if MapLinkInfo ~= nil then
            if (MapLinkInfo.LinkType == TransitionType.TRANSITION_NPC or
                    MapLinkInfo.LinkType == TransitionType.TRANSITION_EOBJ)
            then
                self:InsertActorMoveData(
                    MapLinkInfo.FromMapID,
                    MapLinkInfo.ToMapID,
                    MapLinkInfo.ToMapPos,
                    MapLinkInfo.LinkData.ActorResID,
                    MapLinkInfo.LinkData.InteractiveID,
                    RetMoveDataTable
                )
            elseif (MapLinkInfo.LinkType == TransitionType.TRANSITION_EDGE) then
                self:InsertEdgeMoveData(
                    MapLinkInfo.FromMapID,
                    MapLinkInfo.FromMapPos,
                    MapLinkInfo.ToMapID,
                    MapLinkInfo.ToMapPos,
                    RetMoveDataTable
                )
            else
                FLOG_ERROR("No LinkType:%d", MapLinkInfo.LinkType)
            end
        else
            FLOG_ERROR("MapLinkinfo is nil mapid:%d, nextmapid:%d", MapID, NextMapID)
        end
    end

    --插入最后一个地图
    local MapPath = MapPaths[#MapPaths]
    local MapID = MapPath.MapID
    local Paths = MapPath.Paths
    local TempSrcPos = Paths[1].StartPos
    local TempDstPos = Paths[#Paths].EndPos

    --重新计算路径,考虑同地图水晶传送
    local TempMoveData = self:GenerateSameMapPathData(MapID, TempSrcPos, TempDstPos)
    table.insert(RetMoveDataTable, TempMoveData[1])


    return RetMoveDataTable, #MapLinkTable
end

--转换为可执行寻路数据
function AutoPathMoveMgr:ConvertToExecMoveData(MoveDataTable, IsDstPosRejust)
    local ExecMoveData = {}
    local LastPointMoveData = nil

    for _, MoveData in ipairs(MoveDataTable) do
        if (MoveData.Type == self.EMoveType.MapPath) then
            --MapPath数据需要拆开（地图内有NPC传送，水晶传送，目标点移动）
            local MapID = MoveData.Data.MapID
            for i = 1, #MoveData.Data.Paths do
                local MapPathInfo = MoveData.Data.Paths[i]
                if (MapPathInfo.ActorResID ~= nil and MapPathInfo.ActorResID ~= 0) then
                    self:InsertActorMoveData(
                        MapID,
                        MapID,
                        MapPathInfo.EndPos,
                        MapPathInfo.ActorResID,
                        MapPathInfo.InteractiveID,
                        ExecMoveData)
                elseif (MapPathInfo.CrystalID ~= nil and MapPathInfo.CrystalID ~= 0) then
                    self:InsertCrystalMoveData(MapPathInfo.CrystalID, MapID, MapID, ExecMoveData)
                else    
                    --记录是否传送水晶后发起的移动                
                    local StartCrystalID = 0
                    if (i > 1) then
                        StartCrystalID = MoveData.Data.Paths[i-1].CrystalID
                    end
                    LastPointMoveData = self:InsertPointMoveData(MapID, MapPathInfo.StartPos, MapPathInfo.EndPos, StartCrystalID, ExecMoveData)
                end
            end
        else
            table.insert(ExecMoveData, MoveData)
        end
    end

    --终点是否偏移
    if (LastPointMoveData ~= nil) then
        LastPointMoveData.Data.IsDstPosRejust = IsDstPosRejust
    end

    return ExecMoveData
end

function AutoPathMoveMgr:InsertEdgeMoveData(SrcMapID, SrcPos, DstMapID, DstPos, RetData)
    local NewMoveData = {}
    local DaiData = {}
    DaiData.FromMapID = SrcMapID
    DaiData.SrcPos = SrcPos
    DaiData.ToMapID = DstMapID
    DaiData.DstPos = DstPos

    NewMoveData.Type = self.EMoveType.TransEdge
    NewMoveData.Data = DaiData

    table.insert(RetData, NewMoveData)
end

function AutoPathMoveMgr:InsertPointMoveData(MapID, StartPos, EndPos, StartCrystalID, RetData)
    local IsNPCPosition,NPCPos,InteractionRange = NavigationPathMgr.IsNPCPosition(EndPos)

    local NewMoveData = {}
    local PointData = {}
    PointData.MapID = MapID
    PointData.SrcPos = StartPos
    PointData.DstPos = EndPos    
    PointData.StartCrystalID = StartCrystalID    
    PointData.IsDstPosRejust = (not IsNPCPosition)         --NPC不需要偏移，其他点需要做偏移    
    PointData.NPCPos = NPCPos
    PointData.InteractionRange = InteractionRange

    NewMoveData.Type = self.EMoveType.Point
    NewMoveData.Data = PointData
    table.insert(RetData, NewMoveData)

    return NewMoveData
end

--NPC, Eobj支持不同地图传送，例如电梯NPC
function AutoPathMoveMgr:InsertActorMoveData(FromMapID, ToMapID, TransPos, ActorResID, InteractiveID, RetData)
    local NewMoveData = {}
    local ActorData = {}
    ActorData.FromMapID = FromMapID
    ActorData.ToMapID = ToMapID
    ActorData.ActorResID = ActorResID
    ActorData.InteractiveID = InteractiveID
    ActorData.TransPos = TransPos

    NewMoveData.Type = self.EMoveType.Actor
    NewMoveData.Data = ActorData
    table.insert(RetData, NewMoveData)
end

function AutoPathMoveMgr:InsertCrystalMoveData(CrystalID, FromMapID, ToMapID, RetData)
    --水晶传送
    local OneData = {}
    local CrystalData = {}
    CrystalData.CrystalID = CrystalID
    CrystalData.FromMapID = FromMapID
    CrystalData.ToMapID = ToMapID
    CrystalData.TransPos = self:GetCrystalTransPos(CrystalID)

    OneData.Type = self.EMoveType.Crystal
    OneData.Data = CrystalData

    table.insert(RetData, OneData)
end

function AutoPathMoveMgr:InsertMapPathMoveData(MapPaths, RetData)
    --水晶传送
    for _, MapPath in ipairs(MapPaths) do
        local OneData = {}
        OneData.Type = self.EMoveType.MapPath
        OneData.Data = MapPath

        table.insert(RetData, OneData)
    end
end

---获取目标地图离目标点最近水晶（激活的大小水晶都可）
---@return CrystalID
---@return TransPos 水晶传送落地位置
---@return MinDistance 最短距离
function AutoPathMoveMgr:GetShortestActivatedCrystalID(DstMapID, DstPos, IsBigCrystal)
    local CrystalPortalMgr = _G.PWorldMgr:GetCrystalPortalMgr()
    local MinDistance = 100000000
    local ShortestCrystalID = 0
    local TransPos = nil
    --_G.UE.FProfileTag.StaticBegin("AutoPathMoveMgr:GetShortestActivatedCrystalID 0-----")
    local CrystalCfgsByMap = CrystalPortalCfg:FindAllCfg(string.format("MapID = %d", DstMapID))
    --_G.UE.FProfileTag.StaticEnd()

    if (CrystalCfgsByMap ~= nil and #CrystalCfgsByMap > 0) then
        for _, CrystalCfg in ipairs(CrystalCfgsByMap) do
            local IsActivated = CrystalPortalMgr:IsExistActiveCrystal(CrystalCfg.CrystalID)
            if
                (IsActivated and CrystalCfg.DisplayOrder > 0 and
                    (not IsBigCrystal or CrystalCfg.Type == ProtoRes.TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP))
             then
                --可行走距离
                local Distance = self:GetMapPosDistance(DstMapID, CrystalCfg.Pos[1], DstPos)
                if (Distance < MinDistance) then
                    MinDistance = Distance
                    ShortestCrystalID = CrystalCfg.CrystalID
                    TransPos = CrystalCfg.Pos[1]
                end
            end
        end
    end

    return ShortestCrystalID, TransPos, MinDistance
end

--地图是否有激活水晶
function AutoPathMoveMgr:IsMapExistActiveCrystal(MapID)
    if (self.MapForActivCrystal[MapID] ~= nil) then
        return true
    end

    local CrystalPortalMgr = _G.PWorldMgr:GetCrystalPortalMgr()            
    local CrystalCfgsByMap = CrystalPortalCfg:FindAllCfg(string.format("MapID = %d", MapID))    

    if (CrystalCfgsByMap ~= nil and #CrystalCfgsByMap > 0) then
        for _, CrystalCfg in ipairs(CrystalCfgsByMap) do
            local IsActivated = CrystalPortalMgr:IsExistActiveCrystal(CrystalCfg.CrystalID)
            if (IsActivated) then
                self.MapForActivCrystal[MapID] = true
                return true
            end            
        end
    end

    return false
end

function AutoPathMoveMgr:GetAllActiveCrystalID(MapID, RetAllActiveCrystalTable)
    local CrystalPortalMgr = _G.PWorldMgr:GetCrystalPortalMgr()            
    local CrystalCfgsByMap = CrystalPortalCfg:FindAllCfg(string.format("MapID = %d", MapID))    

    if (CrystalCfgsByMap ~= nil and #CrystalCfgsByMap > 0) then
        for _, CrystalCfg in ipairs(CrystalCfgsByMap) do
            local IsActivated = CrystalPortalMgr:IsExistActiveCrystal(CrystalCfg.CrystalID)
            if (IsActivated) then
                table.insert(RetAllActiveCrystalTable, CrystalCfg.CrystalID)
            end            
        end
    end
end

---同地图俩点距离计算
---存在区域，需要将所有路径长度相加
function AutoPathMoveMgr:GetMapPosDistance(MapID, SrcPos, DstPos)
    local MapPaths = NavigationPathMgr:FindMapPaths(MapID, SrcPos, MapID, DstPos)
    if (MapPaths == nil or #MapPaths == 0) then
        FLOG_ERROR("Map=%d src:%s, dst:%s no path!", MapID, tostring(SrcPos), tostring(DstPos))
        return 0
    end

    local Distance = self:GetMapPathsDistance(MapPaths[1].Paths)

    return Distance
end

function AutoPathMoveMgr:GetFullMapPathsDist(MoveDataTable)
    --[[table=
    --{
        Type = EMoveType.MapPath
        Data = {MapID, Paths={{StartPos,EndPos, TransType == TransitionType.TRANSITION_INVALID}}
        }
    --]]
    --_G.UE.FProfileTag.StaticBegin("AutoPathMoveMgr:GetFullMapPathsDist 1-----")

    local Distance = 0
    for _, MoveData in ipairs(MoveDataTable) do
        if (MoveData.Type == self.EMoveType.MapPath) then
            local MapPath = MoveData.Data
            Distance = Distance + self:GetMapPathsDistance(MapPath.Paths)
        end
    end
    --_G.UE.FProfileTag.StaticEnd()

    return Distance
end

function AutoPathMoveMgr:GetMapPathsDistance(PathsTable)
    --_G.UE.FProfileTag.StaticBegin("AutoPathMoveMgr:GetMapPathsDistance 1-----")

    local Distance = 0
    for _, Path in ipairs(PathsTable) do
        if (Path.TransType == TransitionType.TRANSITION_INVALID) then
            --跨区域的路径通过传送到达，忽略
            local UEStartPos = _G.UE.FVector(Path.StartPos.X, Path.StartPos.Y, Path.StartPos.Z)
            local UEEndPos = _G.UE.FVector(Path.EndPos.X, Path.EndPos.Y, Path.EndPos.Z)
            Distance = Distance + _G.UE.FVector.Dist(UEStartPos, UEEndPos)
        end
    end

    --_G.UE.FProfileTag.StaticEnd()

    return Distance
end


--地图是否解锁自动寻路(只判断水晶)
--TODO:逻辑修改，只判断地图入口是否开启
function AutoPathMoveMgr:IsUnlockAutoPath(MapID)
    --TODO:入口开启
    return true
end

---获取水晶传送后位置
function AutoPathMoveMgr:GetCrystalTransPos(CrystalID)
    local FindCfg = CrystalPortalCfg:FindCfg(string.format("CrystalID = %d", CrystalID))
    if (FindCfg == nil) then
        return nil
    end

    --取第一个
    local Pos = FindCfg.Pos[1]

    return Pos
end


--自动寻路系统是否开放了:解锁了任意一个非现世回廊大水晶
--CBT2:使用道具开放
function AutoPathMoveMgr:IsAutoPathMoveOpen()    
    --TODO：道具开放    
    if (_G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleAutoNavi)) then
        return true
    else        
        return false
    end    
end

--继续自动寻路
function AutoPathMoveMgr:ResumeAutoPathMove()
    --需要地图上显示指引线
    _G.WorldMapMgr:StartMapAutoPathMove(self.DstMapID, self.DstPos, self.TargetType, self.IsDstPosRejust)
end

--------------GM测试----------------
function AutoPathMoveMgr:GMTestAutoPathMove(DstMapID, DstPos)
    if (DstMapID == 0) then
        DstMapID = 12001
        DstPos = {X = -1815, Y = -194, Z = 8380}
        --DstPos = NavigationPathMgr.GetNavigationPosByNpcID(DstMapID, 1001285)
    end

    --获取主角位置
    local Major = _G.UE.UActorManager:Get():GetMajor()
    if (Major ~= nil) then
        local MajorPos = Major:FGetActorLocation()
        local MapID = _G.PWorldMgr:GetCurrMapResID()

        FLOG_INFO(
            "GM TestAutoPathMove: SrcMapID:%d, SrcPos:%s; DstMapID:%d, DstPos:%s",
            MapID,
            tostring(MajorPos),
            DstMapID,
            table.tostring(DstPos)
        )
        
        self:AutoPathMoveForTest(MapID, MajorPos, DstMapID, DstPos, AutoMoveTargetType.Task, true)            
    end
end
-----------------------对外接口begin------------------
function AutoPathMoveMgr:IsAutoPathMovingState()
    return AutoPathMoveImpl:IsAutoPathMovingState()
end

function AutoPathMoveMgr:IsAutoPathMoving(DstMapID, DstPos)
    return AutoPathMoveImpl:IsAutoPathMovingByMap(DstMapID, DstPos)
end

function AutoPathMoveMgr:StopAutoPathMoving()
    AutoPathMoveImpl:Stop()
end

--判断地图能否自动寻路（开关设置，以及水晶判断）
function AutoPathMoveMgr:CanAutoPathMoveForMap(MapID)
    local Result, _ = self:IsAutoPathMoveEnable()
    if (not Result) then
        return false
    end
    
    return self:IsUnlockAutoPath(MapID)
end
---
--[[
    地图系统使用接口
--]]
---@param SrcMapID 源地图ID
---@param SrcPos 起始位置
---@param DstMapID 目标地图ID
---@param DstPos 目标位置
---@param TargetType 寻路目标类型（任务，地图等）
---@param IsDstPosRejust 是否需要终点偏移，true:离终点一定距离停止，false:同终点重合
---@return bool,table 成功：true, MapPathPathTable{{MapID=1,SrcPos={1,1,1},DstPos={2,2,2}}}, 失败：false, EErrorCode
function AutoPathMoveMgr:AutoPathMoveForMapSystem(SrcMapID, SrcPos, DstMapID, DstPos, TargetType, IsDstPosRejust)    
    local Result, RetData = self:AutoPathMove(SrcMapID, SrcPos, DstMapID, DstPos, TargetType, IsDstPosRejust)
    if (Result == false) then            
        --RetData is ErrorCode
        return false, RetData
    end    

    --sussess, RetData is ExecMoveData
    local ExecMoveData = RetData
    local RetMapPathTable = {}
    for _, MoveData in ipairs(ExecMoveData) do
        if (MoveData.Type == self.EMoveType.Point) then
            local OneData = {}
            OneData.MapID = MoveData.Data.MapID
            OneData.SrcPos = MoveData.Data.SrcPos
            OneData.DstPos = MoveData.Data.DstPos

            table.insert(RetMapPathTable, OneData)
        end
    end

    return true, RetMapPathTable
end

-----------------------对外接口end------------------
---
return AutoPathMoveMgr
