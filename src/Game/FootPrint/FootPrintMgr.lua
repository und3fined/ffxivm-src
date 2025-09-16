--
-- Author: alex
-- Date: 2024-02-28 15:21
-- Description:足迹系统
--

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local EventID = require("Define/EventID")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local UIViewID = require("Define/UIViewID")
local UIViewMgr = require("UI/UIViewMgr")
local FootPrintVM = require("Game/FootPrint/FootPrintVM")
local FootPrintItemCfg = require("TableCfg/FootMarkRecordCfg")
local MapRegionCfg = require("TableCfg/MapRegionCfg")
local FootPrintRegionCfg = require("TableCfg/FootMarkRegionCfg")
local MapRegionIconCfg = require("TableCfg/MapRegionIconCfg")
local FootPrintMapWorldCfg = require("TableCfg/FootPrintMapWorldCfg")
local FootPrintDefine = require("Game/FootPrint/FootPrintDefine")
local PWorldCfg = require("TableCfg/PworldCfg")
local CrystalPortalCfg = require("TableCfg/TeleportCrystalCfg")
--local EObjCfg = require("TableCfg/EobjCfg")
local MapUtil = require("Game/Map/MapUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local TimeUtil = require("Utils/TimeUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local ModuleID = ProtoCommon.ModuleID
local SaveKey = require("Define/SaveKey")
--local HUDType = require("Define/HUDType")
local CS_CMD = ProtoCS.CS_CMD
local SUB_MSG_ID = ProtoCS.CS_FOOT_MARK_CMD
local FootPrint_Filter_Type = ProtoRes.FootMarkType
local AreaProgressStatus = FootPrintDefine.AreaProgressStatus
local MapType = ProtoRes.pworld_type
local TELEPORT_CRYSTAL_TYPE = ProtoRes.TELEPORT_CRYSTAL_TYPE

local FLOG_ERROR = _G.FLOG_ERROR



local PWorldMgr
local MapEditDataMgr
local SaveMgr
local RedDotMgr
local FogMgr
local CrystalPortalMgr
local ModuleOpenMgr

---@class FootPrintMgr : MgrBase
---@field FootPrintTableCfg table<number|number|CfgBase>@Region/Map/cfg
local FootPrintMgr = LuaClass(MgrBase)

function FootPrintMgr:OnInit()
    self.FootPrintTableCfg = {}
    self.CacheParentTypAnim = {} -- 需要播放点数变化动画的数据
end

function FootPrintMgr:OnBegin()
    PWorldMgr = _G.PWorldMgr
    FogMgr = _G.FogMgr
    MapEditDataMgr = _G.MapEditDataMgr
    SaveMgr = _G.UE.USaveMgr
    RedDotMgr = require("Game/CommonRedDot/RedDotMgr")
    CrystalPortalMgr = PWorldMgr:GetCrystalPortalMgr()
    ModuleOpenMgr = _G.ModuleOpenMgr
    self:LoadLastAddPointDataFromLocalDevice()
    self.CurLightRegionID = nil -- 当前点亮过程中的RegionID
    --self.AllCompleteRegion = nil

    --- 二期优化
    self.RegionFootPrintInfo = {} -- 地域具体足迹条目信息服务器数据
    self.LastSelectedRegion = nil -- 上一个选中的地域
    self.LastSelectedParentType = nil -- 上一个选中的分类类型
    self.bNeedPlayAnimIn = true -- 区域选择界面是否需要播放AnimIn
end

function FootPrintMgr:OnEnd()
	--self.FootPrintServerInfos = nil
    self:SaveLastAddPointDataInLocalDevice()
    --self.AllCompleteRegion = nil
    self.RegionFootPrintInfo = nil
    self.bRegionInfoSevUpdated = nil
    self.bNeedPlayAnimIn = true
end

function FootPrintMgr:OnShutdown()
    self.FootPrintTableCfg = nil
    self.CacheParentTypAnim = nil
end

function FootPrintMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FOOT_MARK, SUB_MSG_ID.CS_FOOT_MARK_CMD_PULL, self.OnNetMsgGetFootmarkSync)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FOOT_MARK, SUB_MSG_ID.CS_FOOT_MARK_CMD_REGION_ACHIEVE, self.OnNetMsgReceiveFootMarkRegionAward)
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FOOT_MARK, SUB_MSG_ID.CS_FOOT_MARK_CMD_RECORD_UPDATE, self.OnNetMsgFootMarkCompleteNotify)
end

function FootPrintMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
end

function FootPrintMgr:OnRegisterTimer()
    
end

function FootPrintMgr:OnGameEventLoginRes(_)
    if _G.DemoMajorType ~= 0 then
        return
    end

    --local bOpen = ModuleOpenMgr:CheckOpenState(ModuleID.)
    self:SendMsgGetFootmark()
end

--- 将当前角色数据缓存入本地设备
function FootPrintMgr:SaveLastAddPointDataInLocalDevice()
    local CacheAnimScoreList = self.CacheParentTypAnim
    if CacheAnimScoreList == nil or next(CacheAnimScoreList) == nil then
        SaveMgr.SetString(SaveKey.FootPrintCompleteItemID, "", true)
        return
    end

    local StrToSave
    for RegionID, RegionCache in pairs(CacheAnimScoreList) do
        if not StrToSave then
            StrToSave = tostring(RegionID)
        else
            StrToSave = string.format("%s|%s", StrToSave, tostring(RegionID))
        end
        
        for Typ, Score in pairs(RegionCache) do
            StrToSave = string.format("%s,%s,%s", StrToSave, tostring(Typ), tostring(Score))
        end
    end
   
    if StrToSave == nil then
        return
    end
    SaveMgr.SetString(SaveKey.FootPrintCompleteItemID, StrToSave, true)
end

--- 将本地设备数据加载到内存中
function FootPrintMgr:LoadLastAddPointDataFromLocalDevice()
    self.CacheParentTypAnim = {}
    local CacheList = self.CacheParentTypAnim
    local StrLoaded = SaveMgr.GetString(SaveKey.FootPrintCompleteItemID, "", true)
    if StrLoaded == "" then
        return
    end
    local RegionStrList = string.split(StrLoaded, '|')
    for _, RegionStr in ipairs(RegionStrList) do
        local CacheAnimStrList = string.split(RegionStr, ',')
        local RegionID = tonumber(CacheAnimStrList[1])
        if RegionID then
            local RegionLoadInfo = {}
            for Index = 2, #CacheAnimStrList, 2 do
                RegionLoadInfo[tonumber(CacheAnimStrList[Index])] = tonumber(CacheAnimStrList[Index + 1])
            end
            CacheList[RegionID] = RegionLoadInfo
        end
    end
end

--- 清空内存数据
function FootPrintMgr:ClearLastItemCompleteData(RegionID)
    local CacheParentTypAnim = self.CacheParentTypAnim
    if not CacheParentTypAnim then
        return
    end
    local RegionCache = CacheParentTypAnim[RegionID]
    if not RegionCache then
        return
    end
    CacheParentTypAnim[RegionID] = nil
end

--- 根据条目ID获取服务器信息
---@param ItemID number@足迹条目ID
---@return table @{FootPrintNum, AccomplishTime}
function FootPrintMgr:GetTheSevInfoByItemID(ItemID)
    if not ItemID or type(ItemID) ~= "number" then
        return
    end

    local ItemCfg = FootPrintItemCfg:FindCfgByKey(ItemID)
    if not ItemCfg then
        return
    end
    local SevInfos = self.RegionFootPrintInfo
    if not SevInfos then
        return
    end
    local RegionID = ItemCfg.RegionID or 0
    local SevInfo = SevInfos[RegionID]
    if not SevInfo then
        return
    end

    return SevInfo[ItemID]
end

--- 获取对应足迹条目实际获得的足迹点数
---@param ItemID number@足迹ItemID
function FootPrintMgr:GetTheScoreByItemID(ItemID)
    local ItemSevInfo = self:GetTheSevInfoByItemID(ItemID)
    if not ItemSevInfo then
        return 0
    end

    local Targets = ItemSevInfo.Targets
    if not Targets then
        return 0
    end

    local ItemCfg = FootPrintItemCfg:FindCfgByKey(ItemID)
    if not ItemCfg then
        return 0
    end

    local TargetsCfg = ItemCfg.Targets
    if not TargetsCfg then
        return 0
    end
    local TargetScore = 0
    for _, Target in ipairs(Targets) do
        local FinishTime = Target.FinishTime
        if FinishTime and FinishTime > 0 then
            local TargetScoreCfg = table.find_by_predicate(TargetsCfg, function(E) return E.Target == Target.Target end)
            if TargetScoreCfg then
                TargetScore = TargetScore + TargetScoreCfg.Score or 0
            end
        end
    end
    return TargetScore
end

--- 根据地域ID获取地域已积累的足迹点数
function FootPrintMgr:GetRegionScoreByRegionID(RegionID)
    if not RegionID or type(RegionID) ~= "number" then
        return 0
    end
    local SevInfos = self.RegionFootPrintInfo
    if not SevInfos then
        return 0
    end

    local SevInfo = SevInfos[RegionID]
    if not SevInfo or not next(SevInfo) then
        return 0
    end
    
    local Ret = 0
    for ID, _ in pairs(SevInfo) do
        local ItemScore = self:GetTheScoreByItemID(ID)
        Ret = Ret + ItemScore
    end
    return Ret
end

--- 根据地域ID和筛选大类枚举获取对应分类已积累的足迹点数
---@param RegionID number@地域id
---@param ParentType FootPrint_Filter_Type@
function FootPrintMgr:GetParentTypeScore(RegionID, ParentType)
    if not RegionID or type(RegionID) ~= "number" then
        return 0
    end
    local RegionFootPrintInfo = self.RegionFootPrintInfo
    if not RegionFootPrintInfo then
        return 0
    end

    local SingleRegionInfo = RegionFootPrintInfo[RegionID]
    if not SingleRegionInfo then
        return 0
    end

    local Ret = 0
    for ID, _ in pairs(SingleRegionInfo) do
        local ItemParentType = FootPrintItemCfg:FindValue(ID, "Typ")
        if ItemParentType == ParentType then
            local ItemScore = self:GetTheScoreByItemID(ID)
            Ret = Ret + ItemScore
        end
    end
    return Ret
end

--- 根据地图ID和筛选大类枚举获取对应缓存已增长的分数
---@param MapID number@地图id
---@param ParentType FootPrint_Filter_Type
function FootPrintMgr:GetParentTypeScoreAdded(RegionID, ParentType)
    if not RegionID or type(RegionID) ~= "number" then
        return 0
    end
    local CacheParentTypAnim = self.CacheParentTypAnim
    if not CacheParentTypAnim then
        return 0
    end

    local RegionCache = CacheParentTypAnim[RegionID]
    if not RegionCache then
        return 0
    end
    
    return RegionCache[ParentType] or 0
end

--- 更新已完成未播放特效的足迹条目ID列表
---@param RecordSev CsRecordOne@服务器结构
function FootPrintMgr:UpdateHistoryRegionParentTypeScore(RecordSev)
    local RecordId = RecordSev.RecordID
    local CurValue = RecordSev.CurValue
    local Targets = RecordSev.Targets
    if not RecordId or not CurValue or not Targets then
        return
    end

    local RecordCfg = FootPrintItemCfg:FindCfgByKey(RecordId)
    if not RecordCfg then
        return
    end

    local RegionId = RecordCfg.RegionID
    local Typ = RecordCfg.Typ
    local TargetCfgs = RecordCfg.Targets
    if not RegionId or not Typ or not TargetCfgs then
        return
    end

    local CacheParentTypAnim = self.CacheParentTypAnim or {}
    local ClientSevRecord = self:GetTheSevInfoByItemID(RecordId)

    local RegionCache = CacheParentTypAnim[RegionId] or {}

    local function AddNewTargetScore(Target)
        if CurValue >= Target.Target then
            local TypCacheScore = RegionCache[Typ] or 0
            local CfgTarget = table.find_by_predicate(TargetCfgs, function(E) return E.Target == Target.Target end)
            if CfgTarget then
                RegionCache[Typ] = TypCacheScore + CfgTarget.Score
            end
        end
    end
    if not ClientSevRecord then
        for _, Target in ipairs(Targets) do
            AddNewTargetScore(Target)
        end
    else
        local OldSevTargets = ClientSevRecord.Targets
        if not OldSevTargets then
            for _, Target in ipairs(Targets) do
                AddNewTargetScore(Target)
            end
        else
            for _, Target in ipairs(Targets) do
                local NewTarget = Target.Target
                if NewTarget and not table.find_by_predicate(OldSevTargets, function(E) return E.Target == NewTarget end) then
                    AddNewTargetScore(Target)
                end
            end
        end
    end
    CacheParentTypAnim[RegionId] = RegionCache
    self.CacheParentTypAnim = CacheParentTypAnim
end

--- 更新足迹红点数据情况
function FootPrintMgr:UpdateBottleGetRewardRedDotState(RecordSev)
    local RecordId = RecordSev.RecordID
    if not RecordId then
        return
    end
    local ItemCfg = FootPrintItemCfg:FindCfgByKey(RecordId)
    if not ItemCfg then
        return
    end

    local RegionID = ItemCfg.RegionID
    if not RegionID then
        return
    end
    
    if self:IsRegionLighted(RegionID) then
        return
    end

    local ActualScore = self:GetRegionScoreByRegionID(RegionID)
    if ActualScore <= 0 then
        return
    end

    local RegionCfg = FootPrintRegionCfg:FindCfgByKey(RegionID)
    if not RegionCfg then
        return
    end

    local CfgScore = RegionCfg.TargetScore or 0
    if ActualScore >= CfgScore then
        self:AddBottleGetRewardRedDotInternal(RegionID)
    end
end

--- 添加新的足迹进度(此处数据增加需要跟客户端已有数据对比，避免额外获取分数)
---@param RecordOne CsRecordOne@服务器结构
function FootPrintMgr:AddFootMarkRecordProcess(RecordOne)
    local ID = RecordOne.RecordID
    if not ID then
        return
    end
    local CurValue = RecordOne.CurValue or 0
    local Targets = RecordOne.Targets
    local ClientCacheSev = self.RegionFootPrintInfo or {}
    local RecordCfg = FootPrintItemCfg:FindCfgByKey(ID)
    if RecordCfg and ClientCacheSev then
        local RegionID = RecordCfg.RegionID
        local RegionValue = ClientCacheSev[RegionID] or {}
        local ItemInfo = RegionValue[ID] or {}
        local OldTargetsGot = self:TargetAchieveIndexs(ItemInfo.FootPrintNum or 0, ItemInfo.Targets)
        local CurTargetsGot = self:TargetAchieveIndexs(CurValue, Targets)
        local NewScoresCot = {}
        for _, Index in ipairs(CurTargetsGot) do
            local bOldExist = table.contain(OldTargetsGot, Index)
            if not bOldExist then
                table.insert(NewScoresCot, Index)
            end
        end
        local CfgTargets = RecordCfg.Targets
        if CfgTargets then
            for _, Index in ipairs(NewScoresCot) do
                local RegionPoint = RegionValue.FinishFootprintNum or 0
                local CfgTarget = CfgTargets[Index]
                if CfgTarget then
                    local Score = CfgTarget.Score or 0
                    RegionValue.FinishFootprintNum = RegionPoint + Score 
                end
            end
        end
        ItemInfo.FootPrintNum = CurValue
        ItemInfo.Targets = Targets
        RegionValue[ID] = ItemInfo
        ClientCacheSev[RegionID] = RegionValue
    end
    self.RegionFootPrintInfo = ClientCacheSev
end

--- 显示系统通知
---@param RecordOne CsRecordOne@服务器结构
function FootPrintMgr:ShowNtfTip(RecordOne)
    local ID = RecordOne.RecordID
    if not ID then
        return
    end

    local ItemCfg = FootPrintItemCfg:FindCfgByKey(ID)
    if not ItemCfg then
        return
    end

    local RegionId = ItemCfg.RegionID
    if not RegionId then
        return
    end

    local CurTargets = RecordOne.Targets
    if not CurTargets then
        return
    end

    local CfgTargets = ItemCfg.Targets
    if not CfgTargets then
        return
    end

    local CurValue = RecordOne.CurValue or 0

    local function ShowNewTargetTip(Target)
        local TargetNum = Target.Target
        if CurValue >= TargetNum then
            --local RegionID = ItemCfg.RegionID
            --local RegionName = MapUtil.GetRegionName(RegionID)
            --local TitleContent = string.format(LSTR(320011), RegionName)
            --local ValueText = string.format(ItemCfg.CountName, TargetNum)
            local SubTitleContent = string.format(ItemCfg.DetailText, TargetNum)
            --MsgTipsUtil.ShowInfoTextTips(1, TitleContent, SubTitleContent)
            MsgTipsUtil.ShowFootPrintTips(SubTitleContent)
        end
    end

    local ClientSevRecord = self:GetTheSevInfoByItemID(ID)
    if not ClientSevRecord then
        for _, CurTarget in ipairs(CurTargets) do
            ShowNewTargetTip(CurTarget)
        end
    else
        local OldTargets = ClientSevRecord.Targets
        if not OldTargets then
            for _, CurTarget in ipairs(CurTargets) do
                ShowNewTargetTip(CurTarget)
            end
        else
            for _, CurTarget in ipairs(CurTargets) do
                local NewTarget = CurTarget.Target
                if NewTarget and not table.find_by_predicate(OldTargets, function(E) return E.Target == NewTarget end) then
                    ShowNewTargetTip(CurTarget)
                end
            end
        end
    end
end

------ 足迹系统V2 ------

--- 拉取足迹数据
function FootPrintMgr:SendMsgGetFootmark()
    local MsgID = CS_CMD.CS_CMD_FOOT_MARK
    local SubMsgID = SUB_MSG_ID.CS_FOOT_MARK_CMD_PULL

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.Pull = {}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

---同步服务器足迹信息
function FootPrintMgr:OnNetMsgGetFootmarkSync(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("OnNetMsgGetFootmarkSync: MsgBody is nil")
        return
    end
    local SevFootMarkInfo = MsgBody.Pull
    if nil == SevFootMarkInfo then
        return
    end

    local RegionSevInfo = self.RegionFootPrintInfo or {}
    local RegionSevs = SevFootMarkInfo.regions
    if RegionSevs then
        for _, RegionSev in ipairs(RegionSevs) do
            local RegionID = RegionSev.RegionID
            if RegionID then
                local AchieveTime = RegionSev.AchieveTime or 0
                local RegionValue = RegionSevInfo[RegionID] or {}
                RegionValue.AccomplishTime = AchieveTime
                RegionSevInfo[RegionID] = RegionValue
            end
        end
    end
    self.RegionFootPrintInfo = RegionSevInfo
   
    local RecordSevs = SevFootMarkInfo.Records
    if RecordSevs then
        for _, RecordSev in ipairs(RecordSevs) do
            self:AddFootMarkRecordProcess(RecordSev)
        end
    end
    
    --- 更新领奖红点
    for RegionId, RegionSev in pairs(RegionSevInfo) do
        if not self:IsRegionLighted(RegionId) then
            local RegionCfg = FootPrintRegionCfg:FindCfgByKey(RegionId)
            if RegionCfg then
                local SevScore = RegionSev.FinishFootprintNum or 0
                local TargetScore = RegionCfg.TargetScore or 0
                if SevScore >= TargetScore then
                    self:AddBottleGetRewardRedDotInternal(RegionId)
                end
            end
        end
    end
end

--- 点亮并领取地图奖励
---@param RegionID number@地域id
function FootPrintMgr:SendMsgReceiveFootMarkRegionAwardReq(RegionID)
    local MsgID = CS_CMD.CS_CMD_FOOT_MARK
    local SubMsgID = SUB_MSG_ID.CS_FOOT_MARK_CMD_REGION_ACHIEVE

    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.RegionAchieve = {
        RegionID = RegionID
    }
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- 点亮地域足迹领取奖励
function FootPrintMgr:OnNetMsgReceiveFootMarkRegionAward(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("OnNetMsgReceiveFootMarkRegionAward: MsgBody is nil")
        return
    end
    local ReceiveRegionAward = MsgBody.RegionAchieve
    if nil == ReceiveRegionAward then
        return
    end

    local RegionIDGetReward = ReceiveRegionAward.RegionID
    local SevInfo = self:GetTheRegionSevInfo(RegionIDGetReward)
    if not SevInfo then
        return
    end
    SevInfo.AccomplishTime = ReceiveRegionAward.AchieveTime
    self.CurLightRegionID = RegionIDGetReward
    FootPrintVM:OnNotifyMapRewardReceived(RegionIDGetReward)
    self:RemoveBottleGetRewardRedDotInternal(RegionIDGetReward) -- 领完奖去除红点
end

--- 足迹条目完成通知
function FootPrintMgr:OnNetMsgFootMarkCompleteNotify(MsgBody)
    if nil == MsgBody then
        FLOG_ERROR("OnNetMsgFootMarkCompleteNotify: MsgBody is nil")
        return
    end

    local FootprintNotify = MsgBody.RecordUpdate
    if not FootprintNotify then
        return
    end

    local Records = FootprintNotify.record
    if not Records or not next(Records) then
        return
    end

    for _, Record in ipairs(Records) do
        self:ShowNtfTip(Record)
        self:UpdateHistoryRegionParentTypeScore(Record)
        self:UpdateBottleGetRewardRedDotState(Record)
        self:AddFootMarkRecordProcess(Record)
    end
end

--- 足迹达到的目标数
---@param CurValue number@当前获取的统计项数值
---@param Targets table<CsTargetOne>
function FootPrintMgr:TargetAchieveIndexs(CurValue, Targets)
    if not Targets then
        return {}
    end
    local Rlt = {}
    for Index, Target in ipairs(Targets) do
        local Num = Target.Target
        if Num and Num > 0 and CurValue >= Num then
            table.insert(Rlt, Index)
        end
    end
    return Rlt
end

--- 是否需要显示其他地域红点
---@param RegionID number@地域ID
function FootPrintMgr:IsNeedShowOtherRegionRedDot(RegionID)
    local RegionCfgs = FootPrintRegionCfg:FindAllCfg("1=1")
    if not RegionCfgs then
        return
    end
    for _, RegionCfg in ipairs(RegionCfgs) do
        local RegionCfgID = RegionCfg.RegionID
        if RegionCfgID and RegionCfgID ~= RegionID then
            local bCanLightRedShow = RedDotMgr:FindRedDotNodeByName(string.format("%s/%s", FootPrintDefine.RedDotBaseName, tostring(RegionCfgID)))
            if bCanLightRedShow then
                return true
            end
        end
    end
end

------ 足迹系统V2 End ------

------ 外部调用接口 ------
--- 创建左侧地域页签（优先选中角色所在地图，默认选中第一个，用于UIView）
function FootPrintMgr:MakeTheRegionData()
    local RegionCfgs = FootPrintRegionCfg:FindAllCfg("1=1")
    if not RegionCfgs then
        return
    end
    local RegionIDList = {}
    for _, RegionCfg in ipairs(RegionCfgs) do
        table.insert(RegionIDList, RegionCfg.RegionID)
    end
    local ListData = {}
    table.sort(RegionIDList, function(A, B) return A < B end)
    for _, RegionID in ipairs(RegionIDList) do
        local RegionIconCfg = MapRegionIconCfg:FindCfgByKey(RegionID)
        if RegionIconCfg then
            local Data = {
                RegionID = RegionID,
                Name = RegionIconCfg.Name,
                bMajorAtThisMap = self:IsMajorAtThisRegion(RegionID),
                IsRegionUnlock = self:IsRegionUnlock(RegionID),
                --CompleteIcon = RegionIconCfg.Icon,
                bLighted = self:IsRegionLighted(RegionID),
                CompleteTimeText = self:GetCompleteTimeText(RegionID),
                ActualScore = self:GetRegionActualScore(RegionID),
            }
            table.insert(ListData, Data)
        end
    end
   
	return ListData
end

--- 此地域是否有解锁项
---@param RegionID number@地域ID
---@param ParentType FootPrint_Filter_Type@父分类页签
function FootPrintMgr:IsTheParentTypeHaveUnlockItem(RegionID, ParentType)
    if not RegionID or type(RegionID) ~= "number" then
        return false
    end
    local RegionFootPrintInfo = self.RegionFootPrintInfo
    if not RegionFootPrintInfo then
        return false
    end

    local SingleRegionInfo = RegionFootPrintInfo[RegionID]
    if not SingleRegionInfo then
        return false
    end

    for ID, ItemInfo in pairs(SingleRegionInfo) do
        local ItemCfg = FootPrintItemCfg:FindCfgByKey(ID)
        if ItemCfg then
            local ItemParentType = ItemCfg.Typ or 0
            if ItemParentType == ParentType then
                local CurValue = ItemInfo.FootPrintNum or 0
                local TargetsCfg = ItemCfg.Targets or {}
                local UnlockPercentsCfg = ItemCfg.UnlockPercents or {}
                for Index, Target in ipairs(TargetsCfg) do
                    local TargetNum = Target.Target or 0
                    if TargetNum > 0 then
                        if CurValue / TargetNum * 100 >= (UnlockPercentsCfg[Index] or 0) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

--- 选择具体地域显示
---@param RegionID number@地域ID
function FootPrintMgr:UpdateTheRegionDetail(RegionID, bOpenPanel)
    if not RegionID or type(RegionID) ~= "number" then
        return
    end

    local ParentTypeActualScoreList = {}
    for index = FootPrint_Filter_Type.FootMarkType_Normal, FootPrint_Filter_Type.FootMarkType_Explore do
        ParentTypeActualScoreList[index] = {
            ActualScore = self:GetParentTypeScore(RegionID, index),
            ScoreAdded = self:GetParentTypeScoreAdded(RegionID, index)
        }
    end

    self:ClearLastItemCompleteData(RegionID)
    
    local RegionInfo = {
        RegionID = RegionID,
        ActualScore = self:GetRegionScoreByRegionID(RegionID),
        ParentTypeActualScoreList = ParentTypeActualScoreList,
    }
    FootPrintVM:SelectTheRegion(RegionInfo)

    local function OpenDetailPanel()
        -- 默认选择第一个有解锁项的筛选大类(放到回调中调用默认选中逻辑，必须放在所有UIView逻辑结束之后)
        local IndexToSelect = FootPrint_Filter_Type.FootMarkType_Normal
        for Index = FootPrint_Filter_Type.FootMarkType_Normal, FootPrint_Filter_Type.FootMarkType_Explore do
            if self:IsTheParentTypeHaveUnlockItem(RegionID, Index) then
                IndexToSelect = Index
                break
            end
        end

        self:SelectTheParentType(IndexToSelect)
    end

    if bOpenPanel then
        self.bNeedPlayAnimIn = true
        FootPrintVM:SetAllRegionItemPlayAnimInState(true)
        UIViewMgr:ShowView(UIViewID.FootPrintDataPanelView, {Data = FootPrintVM.RegionContentVM})
        OpenDetailPanel()
    end
end

function FootPrintMgr:ClearLastSelectedData()
    self.LastSelectedRegion = nil
    self.LastSelectedParentType = nil
end

--- 选择具体筛选大类
function FootPrintMgr:SelectTheParentType(ParentType)
    if not ParentType then
        return
    end

    local RegionVM = FootPrintVM.RegionContentVM
    if not RegionVM then
        return
    end

    local CurSelectedRegionID = RegionVM.RegionID
    if not CurSelectedRegionID then
        return
    end

    local LastSelectedRegion = self.LastSelectedRegion
    local LastSelectedParentType = self.LastSelectedParentType
    if CurSelectedRegionID == LastSelectedRegion and ParentType == LastSelectedParentType then
        return -- 当地域与分类类型均一致时不进行刷新判断
    end

    self.LastSelectedRegion = CurSelectedRegionID
    self.LastSelectedParentType = ParentType

    local ParentTypeSevInfo = {
        ParentType = ParentType,
        TypeItemsSevInfo = {},
    }

    local TypeExistCheckMap = {}
    local TargetItemCfgs = FootPrintItemCfg:FindAllCfg(string.format("RegionID = %d AND Typ = %d", CurSelectedRegionID, ParentType))
    if TargetItemCfgs then
        for _, ItemCfg in ipairs(TargetItemCfgs) do
            if ItemCfg then
                local ID = ItemCfg.ID
                local TargetDetail = ItemCfg.Targets
                --local UnlockPercents = ItemCfg.UnlockPercents
                if ID and TargetDetail then
                    local TypeInfoData = TypeExistCheckMap[ID] or {}
                    TypeInfoData.TypeID = ID
                    local ItemSevInfos = TypeInfoData.ItemSevInfos or {}
                    for Index, Target in ipairs(TargetDetail) do
                        local CfgTargetNum = Target.Target
                        if CfgTargetNum > 0 then
                            local LinkKeyStr = string.format("P%dC%d", ID, Index)
                            local ItemInfoData = {
                                StrKey = LinkKeyStr,
                                Key = tonumber(LinkKeyStr),
                                ItemID = ID,
                                TargetNum = CfgTargetNum or 0,
                            }
                        
                            local ItemInfo = self:GetTheSevInfoByItemID(ID)
                            if not ItemInfo then
                                ItemInfoData.NumComplete = 0
                            else
                                ItemInfoData.NumComplete = ItemInfo.FootPrintNum or 0
                                local Targets = ItemInfo.Targets
                                local TargetSev = table.find_by_predicate(Targets, function(E) return E.Target == CfgTargetNum end)
                                if TargetSev then
                                    ItemInfoData.AccomplishTime = TargetSev.FinishTime
                                end
                            end
                            table.insert(ItemSevInfos, ItemInfoData)
                        end
                    end
                    TypeInfoData.ItemSevInfos = ItemSevInfos
                    TypeExistCheckMap[ID] = TypeInfoData
                end
            end
        end
    end
   
    ParentTypeSevInfo.TypeItemsSevInfo = table.values(TypeExistCheckMap)
    FootPrintVM:SelectTheParentType(ParentTypeSevInfo)
end

--- 打开足迹主界面
function FootPrintMgr:OpenFootPrintMainPanel(bNewRule)
    local bSceneLimit = PWorldMgr:CurrIsInSingleDungeon() or PWorldMgr:CurrIsInDungeon()
    if bSceneLimit then
        MsgTipsUtil.ShowTipsByID(370000)
        return
    end

    if not bNewRule then
        UIViewMgr:ShowView(UIViewID.FootPrintMainPanelView)
    else
        --- 如果直接打开地域详情界面则地域VM数据在此处创建
        local ListData = FootPrintMgr:MakeTheRegionData()
        if not ListData then
            return
        end
        FootPrintVM:UpdateRegionList(ListData)

        local CurMapID = PWorldMgr:GetCurrMapResID()
        if not CurMapID then
            return
        end

        local RegionID = MapUtil.GetMapRegionID(CurMapID)
        if not RegionID then
            return
        end
    
        if not FootPrintMgr:IsRegionUnlock(RegionID) then
            UIViewMgr:ShowView(UIViewID.FootPrintMainPanelView)
            return
        end
    
        FootPrintMgr:UpdateTheRegionDetail(RegionID, true)
    end
end

--- 添加足迹地域可领奖励红点
---@param RegionID number@地域ID
function FootPrintMgr:AddBottleGetRewardRedDotInternal(RegionID)
    if not RegionID or type(RegionID) ~= "number" then
        return
    end
    RedDotMgr:AddRedDotByName(string.format("%s/%s", FootPrintDefine.RedDotBaseName, tostring(RegionID)))
end

--- 去除足迹地图可领奖励红点
---@param MapID number@地图ID
function FootPrintMgr:RemoveBottleGetRewardRedDotInternal(RegionID)
    if not RegionID or type(RegionID) ~= "number" then
        return
    end
   
    RedDotMgr:DelRedDotByName(string.format("%s/%s", FootPrintDefine.RedDotBaseName, tostring(RegionID)))
end


------ 二期UI调整 ------
--- 地域地图是否解锁
function FootPrintMgr:IsRegionUnlock(RegionID)
    local MapList = MapRegionCfg:FindAllCfg(string.format("RegionID = %d", RegionID))
    if not MapList or not next(MapList) then
        return
    end
   
   for _, Cfg in ipairs(MapList) do
        local MapID = Cfg.MapID
        local WorldId = FootPrintMapWorldCfg:FindValue(MapID, "WorldID")
        local WorldType = PWorldCfg:FindValue(WorldId, "Type")
        if MapType.PWORLD_CATEGORY_MAIN_CITY == WorldType then
            local Cfgs = CrystalPortalCfg:FindAllCfg(string.format("MapID = %d AND Type = %d", MapID, TELEPORT_CRYSTAL_TYPE.TELEPORT_CRYSTAL_ACROSSMAP))
            for _, Cfg in ipairs(Cfgs) do
                if CrystalPortalMgr:IsExistActiveCrystal(Cfg.ID) then
                    return true
                end
            end
        elseif MapType.PWORLD_CATEGORY_FIELD == WorldType then
            if FogMgr:IsAnyActivate(MapID) then
                return true
            end
        end
    end

    return false
end

--- 地域是否已点亮
function FootPrintMgr:IsRegionLighted(RegionID)
    local Sev = self:GetTheRegionSevInfo(RegionID)
    if not Sev then
        return
    end

    local AccomplishTime = Sev.AccomplishTime or 0 
    return AccomplishTime > 0
end

--- 获取地域点亮时间
function FootPrintMgr:GetCompleteTimeText(RegionID)
    local Sev = self:GetTheRegionSevInfo(RegionID)
    if not Sev then
        return
    end

    local AccomplishTime = Sev.AccomplishTime
    if AccomplishTime and AccomplishTime > 0 then
        local TimeStr = TimeUtil.GetTimeFormat("%Y/%m/%d", AccomplishTime)
        return LocalizationUtil.GetTimeForFixedFormat(TimeStr)
    end
end

--- 获取地域实际获得的足迹点数
function FootPrintMgr:GetRegionActualScore(RegionID)
    local Sev = self:GetTheRegionSevInfo(RegionID)
    if not Sev then
        return
    end

    return Sev.FinishFootprintNum
end

--- 获取主角是否在当前地域
function FootPrintMgr:IsMajorAtThisRegion(RegionID)
    if not RegionID then
        return
    end
    local CurMapID = PWorldMgr:GetCurrMapResID()
    if not CurMapID then
        return
    end

    local RegionIDOfMap = MapUtil.GetMapRegionID(CurMapID)
    if not RegionIDOfMap then
        return
    end

    return RegionIDOfMap == RegionID
end

--- 根据地域ID获取缓存地域信息
---@param ItemID number@足迹条目ID
function FootPrintMgr:GetTheRegionSevInfo(RegionID)
    local RegionSevs = self.RegionFootPrintInfo
    if not RegionSevs or not next(RegionSevs) then
        return
    end
    return RegionSevs[RegionID]
end

------ 二期UI调整 END ------


return FootPrintMgr