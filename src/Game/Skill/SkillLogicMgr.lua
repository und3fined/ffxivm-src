--chaooren
--输出日志用于测试，加了个debug开关
function SKILL_FLOG_ERROR(Msg, ...)
    if _G.SkillLogicMgr.ShowSkillDebug == true then
        FLOG_ERROR(Msg, ...)
    end
end

local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCommon = require("Protocol/ProtoCommon")
local EventID = require("Define/EventID")
local SkillBtnState = require("Game/Skill/SkillButtonStateMgr").SkillBtnState
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local SkillMainCfg = require("TableCfg/SkillMainCfg")
local PworldCfg = require("TableCfg/PworldCfg")
local SceneSkillCfg = require("TableCfg/SceneSkillCfg")
local MajorUtil = require("Utils/MajorUtil")
local SelectTargetFilter = require ("Game/Skill/SelectTarget/SelectTargetFilter")
local SlatePreTick = require("Game/Skill/SlatePreTick")

local SkillLogicData = require("Game/Skill/SkillLogicData")
local ServerSkillSyncInfo = require("Game/Skill/ServerSkillSyncInfo")
local ObjectGCType = require("Define/ObjectGCType")
local SkillCommonDefine = require("Game/Skill/SkillCommonDefine")
local SkillUtil = require("Utils/SkillUtil")
local ActorUtil = require("Utils/ActorUtil")
local ProfUtil = require("Game/Profession/ProfUtil")
local MsgTipsID = require("Define/MsgTipsID")
local CommonUtil = require("Utils/CommonUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local MainPanelVM = require("Game/Main/MainPanelVM")

local ItemCfg = require("TableCfg/ItemCfg")
local ChatDefine = require("Game/Chat/ChatDefine")

local LSTR = _G.LSTR

local USelectEffectMgr
local SkillCustomMgr
-- local SkillSystemMgr
local GetCurrSelectedTarget

---@class SkillLogicMgr : MgrBase
local SkillLogicMgr = LuaClass(MgrBase)


local ConstAffectedFlag = (2 ^ SkillBtnState.ValidStateMaxIndex) - 1
local MapType = SkillUtil.MapType

SkillLogicMgr.SkillButtonLongClickType = {
    None = 0,
    GatherSkill = 1,        --采集技能的长按
}

function SkillLogicMgr:OnInit()
    self.MajorLogicData = nil

    self.SkillTips = {}

    --[EntityID] = {SkillLogicData}
    --no major
    self.LogicDataList = {}

    --服务器下发某些技能数据时，logicData可能没有创建完成，此处临时保存主角数据
    self.MajorServerSkillSyncInfo = ServerSkillSyncInfo.New()

    self.ExtraSkillIndex = 999

    self.bShowSkillTips = true
    self.LifeSkillCDList = {}

    self.ProfSkillUnlockList = {}
    self.ProfUnLockSpectrumsID = nil

    self.SysChatMsgBattleList = {}
    self.SysChatMsgBattleTimerID = nil

    SkillCustomMgr = _G.SkillCustomMgr
    USelectEffectMgr = _G.UE.USelectEffectMgr.Get()
    GetCurrSelectedTarget = USelectEffectMgr.GetCurrSelectedTarget

    self.ReqSkillListTimerID = 0
    self.bAutoGenSkillAttack = false
end

function SkillLogicMgr:ShowSkillTipsFlag(Value)
    if Value == 0 then
        self.bShowSkillTips = false
    else
        self.bShowSkillTips = true
    end
end

function SkillLogicMgr:OnBegin()
    SlatePreTick.RegisterSlatePreTick(self, self.OnSkillProcessPreSlateTick)
end

function SkillLogicMgr:OnEnd()
    SlatePreTick.UnRegisterSlatePreTick(self, self.OnSkillProcessPreSlateTick)
end

function SkillLogicMgr:OnShutdown()
    self.LifeSkillCDList = {}
end

function SkillLogicMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SKILL_REPLACE, self.OnNetMsgCombatSkillReplace)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_SYNC_SKILL_RES, self.OnNetMsgCombatSSyncSkillRes)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_REVISE_SKILL, self.OnNetMsgCombatReviseSkill)

    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_COMBAT, ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_QUERY_SKILLLIST, self.OnNetMsgSkillQuery)
    self:RegisterGameNetMsg(ProtoCS.CS_CMD.CS_CMD_SKILL, ProtoCS.SkillSubMsg.SkillSubMsgReplace, self.OnNetMsgSkillListReplace)
end

function SkillLogicMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.SkillUpdate, self.OnSkillUpdate)
    
    self:RegisterGameEvent(EventID.ComBatStateUpdate, self.OnEventControlStateChange)
    self:RegisterGameEvent(EventID.NetStateUpdate, self.OnNetStateUpdate)
    self:RegisterGameEvent(EventID.Attr_Change_MP, self.OnMajorMPChange)
    self:RegisterGameEvent(EventID.Attr_Change_GP, self.OnMajorGPChange)
    self:RegisterGameEvent(EventID.MajorLevelUpdate, self.OnMajorLevelUpdate)

    self:RegisterGameEvent(EventID.MajorSkillCanUse, self.OnMajorSkillCanUse)

    self:RegisterGameEvent(EventID.EnterWater, self.OnGameEventStartSwimming)
	self:RegisterGameEvent(EventID.ExitWater, self.OnGameEventEndSwimming)
	self:RegisterGameEvent(EventID.MountFlyStateChange, self.OnGameEventMountFlyStateChange)

    self:RegisterGameEvent(EventID.MajorCreate, self.OnGameEventMajorCreate)
    self:RegisterGameEvent(EventID.NetworkReconnected, self.OnNetworkReconnected)
    self:RegisterGameEvent(EventID.MajorEntityIDUpdate, self.OnMajorEntityIDUpdate)
    

    self:RegisterGameEvent(EventID.MajorDead, self.OnMajorDead)
    self:RegisterGameEvent(EventID.ActorReviveNotify, self.OnActorRevive)

    --播放技能解锁动效
    self:RegisterGameEvent(EventID.ModuleOpenSkillUnLockEvent, self.OnModuleOpenSkillUnLock)

    --转发下背包物品cd，仅转发药品
    self:RegisterGameEvent(EventID.BagFreezeCD, self.OnFreezeCD)

    self:RegisterGameEvent(EventID.MajorChangeSkillWeight, self.OnMajorChangeSkillWeight)

    self:RegisterGameEvent(EventID.AttackEffectChange, self.OnGameEventAttackEffectChange)
end

function SkillLogicMgr:OnRegisterTimer()
    --技能释放埋点
    self:RegisterTimer(self.OnReportProductionSkillFlowData, 300, 300, -1)
end

function SkillLogicMgr:CreateSkillMainPanel(EntityID, bMajor, MapType, ParentSlot, ParentView, Offset)

    if ParentSlot then
        local _ <close> = CommonUtil.MakeProfileTag("SkillSystemVM:Create Skill View")
        local View = UIViewMgr:CreateViewByName(SkillCommonDefine.NewMainSkillBPName, ObjectGCType.NoCache, ParentView)
        
		if nil == View then
			FLOG_ERROR("CreateSkillMainPanel View failed, BPName=%s", SkillCommonDefine.NewMainSkillBPName)
			return
		end

        ParentSlot:AddChild(View)
        View.Slot.bAutoSize = false
        Offset = Offset or _G.UE.FVector2D(0, 0)
        View.Slot:SetPosition(Offset)
        View.Slot:SetSize(UE.FVector2D(1920, 1080))
		View:InitView()
        View:OnEntityIDUpdate(EntityID, bMajor, MapType)
        View:ViewSwitchFight()
        View:ShowView({ManualCreate = true})
        return View
    end
end

function SkillLogicMgr:CreateSkillLogicData(EntityID, bMajor)
    if EntityID == 0 then
        FLOG_WARNING("[SkillLogicMgr] CreateSkillData with EntityID 0")
    end

    local LogicData = SkillLogicData.New(EntityID, bMajor)
    if LogicData then
        if not bMajor then
            self.LogicDataList[EntityID] = LogicData
        end
    end
    return LogicData
end

function SkillLogicMgr:RemoveSkillLogicData(EntityID)
    if EntityID then
        self.LogicDataList[EntityID] = nil
    end
end

function SkillLogicMgr:GetSkillLogicData(EntityID)
    if EntityID == nil or EntityID == 0 then
        return
    end

    --优先考虑主角
    local MajorLogicData = self.MajorLogicData
    if MajorLogicData and MajorLogicData.EntityID == EntityID then
        return MajorLogicData
    end
    local LogicData = self.LogicDataList[EntityID]
    if LogicData then
        return LogicData
    else
        print(string.format("[SkillLogicMgr] %d not find, return major logic data", EntityID))
        return MajorLogicData
    end
end

function SkillLogicMgr:GetMajorSkillLogicData()
    return self.MajorLogicData
end

function SkillLogicMgr:OnNetMsgCombatReviseSkill(MsgBody)
    local SkillRevise = MsgBody.SkillRevise
    if SkillRevise.ReivseType == ProtoCS.revise_skill_type.REVISE_SKILL_SING then
        local ReviseSkillSingList = self.MajorServerSkillSyncInfo.ReviseSkillSingList
        for _, value in ipairs(SkillRevise.Uints) do
            ReviseSkillSingList[value.SkillID] = value.Value ~= -1 and value.Value or nil
        end
    elseif SkillRevise.ReivseType == ProtoCS.revise_skill_type.REVISE_SKILL_ACTION then
        local ReviseSkillActionList = self.MajorServerSkillSyncInfo.ReviseSkillActionList
        for _, value in ipairs(SkillRevise.Uints) do
            ReviseSkillActionList[value.SkillID] = value.Value ~= -1 and value.Value or nil
        end
    end
end

---------------------技能列表初始化-----------------
function SkillLogicMgr:RequireServerSkill()
    print("[SkillLogicMgr] RequireServerSkill")
    _G.MajorTriggerSkillMgr:ReqTriggerSkillList()
    self:ReqSkillAttrSyncList()
    self:ReqSkillList()
end

local ReqSkillListInterval = 5
local ReqSkillListLoopCount = 3
function SkillLogicMgr:ReqSkillList()
    print("[SkillLogicMgr] ReqSkillList")
    if not self.bIsRequiringSkillList then
        self.ReqSkillListTimerID = self:RegisterTimer(self.ReqSkillListEveryTime, ReqSkillListInterval, ReqSkillListInterval, ReqSkillListLoopCount)
        self.bIsRequiringSkillList = true
    end

    -- 因为SkillList回包处理要在CustomIndex之后, 串行请求CustomIndexMap和SkillList
    SkillCustomMgr:ReqCustomIndexMap(true, function(bSuccess, CustomIndexMap)
        if bSuccess then
            EventMgr:SendEvent(EventID.SkillCustomIndexReplace, CustomIndexMap)
        end
        local MsgID = ProtoCS.CS_CMD.CS_CMD_COMBAT
        local SubMsgID = ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_QUERY_SKILLLIST
        local MsgBody = {}
        MsgBody.Cmd = SubMsgID
        _G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
    end)


    
end

function SkillLogicMgr:ReqSkillListEveryTime()
    if self.bIsRequiringSkillList then
        self:ReqSkillList()
    else
        self:UnRegisterTimer(self.ReqSkillListTimerID)
        self.ReqSkillListTimerID = 0
    end
end

function SkillLogicMgr:ReqSkillAttrSyncList()
    local MsgID = ProtoCS.CS_CMD.CS_CMD_COMBAT
	local SubMsgID = ProtoCS.CS_COMBAT_CMD.CS_COMBAT_CMD_QUERY_SKILL_REVISE
	local MsgBody = {}
	MsgBody.Cmd = SubMsgID
	_G.GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

function SkillLogicMgr:OnNetMsgSkillQuery(MsgBody)
    local SkillList = MsgBody.SkillList
    print("[SkillLogicMgr] OnNetMsgSkillQuery\n" .. table_to_string(SkillList))

    local bPost = MainPanelVM:GetControlPanelAttrExist()
    self.bIsRequiringSkillList = false

    self:UnRegisterTimer(self.ReqSkillListTimerID)
    self.ReqSkillListTimerID = 0

    local MajorLogicData = self:GetMajorSkillLogicData()
    if MajorLogicData then
        local ActiveSkills = SkillList.activeSkills or {}
        local ProfID = MajorLogicData:GetProfID()
        local Level = MajorLogicData:GetLevel()
        local MapType = MajorLogicData:GetMapType()
        local CacheSkillList = self:GetMajorCacheSkillList(ProfID, Level, MapType)
        local ClientSkillList = CacheSkillList and CacheSkillList.SkillList or {}
        --耗时太高就分帧
        for _, value in pairs(ClientSkillList) do
            local Index = value.Index
            local ServerID = ActiveSkills[Index]
            local SkillID = ServerID ~= nil and ServerID or value.ID
            MajorLogicData:UpdateSingleSkill(Index, SkillID, true, bPost)
        end

        if SkillList.passiveSkills then
            MajorLogicData:UpdatePassiveList(SkillList.passiveSkills)
        end
    end

    if not bPost then
        MainPanelVM:SetControlPanelAttrExist(true)
    else
        --等级改变请求的技能
    end

    EventMgr:SendEvent(EventID.AllSkillUpdateFinished)
end

function SkillLogicMgr:GetMajorCacheSkillList(ProfID, Level, MapType)
    if self.MajorCacheSkillList == nil or self.MajorCacheSkillList.Level ~= Level or self.MajorCacheSkillList.MapType ~= MapType or self.MajorCacheSkillList.ProfID ~= ProfID then
        self.MajorCacheSkillList = SkillUtil.GetBaseSkillListForInit(MapType, ProfID, Level, true)
    end
    print("[SkillLogicMgr] GetMajorCacheSkillList\n" .. table_to_string(self.MajorCacheSkillList))
    return self.MajorCacheSkillList
end

function SkillLogicMgr:PostMajorUnlockSkillQueue(ProfID, OldLevel, NewLevel, IsAdvanceProf)
    local UnlockSkillList = SkillUtil.GetUnLockSkillList(ProfID, OldLevel or 0, NewLevel or 0, IsAdvanceProf)
    local MajorLogicData = self.MajorLogicData
    MajorLogicData.NotFirstSkillUnlockList = {}
    for _, value in ipairs(UnlockSkillList) do
        local SkillID = value.SkillID
        if value.bHideLearnTips == 0 then
            local SkillCfg = SkillMainCfg:FindCfgByKey(SkillID)
            if IsAdvanceProf then
                table.insert(self.ProfSkillUnlockList,  {ProfID = ProfID, SkillID = SkillID, Icon = SkillCfg.Icon, SkillName = SkillCfg.SkillName, IconJob = value.IconJob})
                table.insert(MajorLogicData.NotFirstSkillUnlockList, {SkillID = SkillID, ProfID = ProfID})
            else
                if ProfID == MajorUtil.GetMajorProfID()  then
                    table.insert(MajorLogicData.NotFirstSkillUnlockList, {SkillID = SkillID, ProfID = ProfID})
                end
                _G.ModuleOpenMgr:OnSkillUnlock(SkillCfg.Icon, SkillCfg.SkillName, value.IconJob, SkillID, ProfID)
            end      
        end
    end
    --适配一下新手引导数据结构，后续重构改成通用结构
    local Params = {}
    Params.Value = UnlockSkillList
    _G.EventMgr:SendEvent(EventID.SkillUnlock, Params)
end

function SkillLogicMgr:PostMajorUnlockSpectrum(Params)
    if nil == Params then 
        return
    end
    --当世界同步等级小于角色等级，则不播放量谱解锁动效
    if Params.NewLevel > MajorUtil.GetMajorLevel() then
        return
    end
    local CurrPWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    local bPVP = PworldCfg:FindValue(CurrPWorldResID, "CanPK")
    local CurMapType = bPVP ~= 0 and MapType.PVP or MapType.PVE
     --量谱处理
    local UnLockSpectrumsID = SkillUtil.IsUnLockSpectrums(CurMapType, Params.ProfID, Params.OldLevel, Params.NewLevel, Params.IsAdvanceProf)
    local ReplaceID = SkillUtil.GetSkillIDBySameSkill(UnLockSpectrumsID, Params.ProfID, Params.NewLevel)
    if Params.IsAdvanceProf then
        self.ProfUnLockSpectrumsID = ReplaceID
    else
        if UnLockSpectrumsID then
            _G.EventMgr:SendEvent(EventID.SpectrumsUnlock, ReplaceID)
        end
    end
end

--转职时需等动画播完再播放解锁动效
function SkillLogicMgr:PlayProfSkillUnlock()
    local MajorProfID = MajorUtil.GetMajorProfID()
    for i = #self.ProfSkillUnlockList, 1, -1 do
        if self.ProfSkillUnlockList[i].ProfID == MajorProfID then
            _G.ModuleOpenMgr:OnSkillUnlock(self.ProfSkillUnlockList[i].Icon, self.ProfSkillUnlockList[i].SkillName, self.ProfSkillUnlockList[i].IconJob, self.ProfSkillUnlockList[i].SkillID, self.ProfSkillUnlockList[i].ProfID)
            table.remove(self.ProfSkillUnlockList, i) 
        end
    end
    --量谱
    if self.ProfUnLockSpectrumsID then
        _G.EventMgr:SendEvent(EventID.SpectrumsUnlock, self.ProfUnLockSpectrumsID)
        self.ProfUnLockSpectrumsID = nil
    end
end

function SkillLogicMgr:OnMajorLevelUpdate(RoleDetail)

    local ProfID = RoleDetail.ProfID
    if ProfID ~= MajorUtil.GetMajorProfID() then
        --非主角当前职业的等级变化，技能不响应
        return
    end

    --转职或等级改变时
    --清空各种主角相关附加模块
    _G.SkillStorageMgr:BreakCurStorageSkill(false)
    _G.SkillPreInputMgr:ClearSkill()
    _G.SkillSeriesMgr:ClearQueueSkillsCache()

    local MajorLogicData = self.MajorLogicData
    if MajorLogicData == nil then
        FLOG_ERROR("[SkillLogicMgr]Invalid Skill Logic Data in MajorLevelUpdate")
        return
    end

    local SceneLevel = MajorUtil.GetMajorLevel()

    --转职过来的，这里临时清掉触发技能
    if RoleDetail.Reason ~= ProtoCS.LevelUpReason.LevelUpReasonProf then
        _G.MajorTriggerSkillMgr:HideAllTriggerSkill(true)
    end

    local ProfLevel = MajorUtil.GetMajorLevelByProf(ProfID)
    local OldProfLevel = RoleDetail.OldLevel

    local CurrPWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    local bPVP = PworldCfg:FindValue(CurrPWorldResID, "CanPK")
    local CurMapType = bPVP ~= 0 and MapType.PVP or MapType.PVE

    --判断是否开启当前特职
    local IsAdvanceProf
    if SceneLevel ~= MajorLogicData:GetLevel() or CurMapType ~= MajorLogicData:GetMapType() or ProfID ~= MajorLogicData:GetProfID() then
        if ProfID == ProfUtil.GetAdvancedProf(MajorLogicData:GetProfID()) then
            IsAdvanceProf = true
        elseif ProfID ~= MajorLogicData:GetProfID() then
            --转职前为生产职业，上报生产技能埋点数据
            local ProFunction = ProfUtil.Prof2Func(MajorLogicData:GetProfID())
            local ProFunction2 = ProfUtil.Prof2Func(ProfID)
            if (ProFunction == ProtoCommon.function_type.FUNCTION_TYPE_PRODUCTION or ProFunction == ProtoCommon.function_type.FUNCTION_TYPE_GATHER) 
                and (ProFunction2 ~= ProtoCommon.function_type.FUNCTION_TYPE_PRODUCTION and ProFunction2 ~= ProtoCommon.function_type.FUNCTION_TYPE_GATHER) then
                SkillUtil:ReportProductionSkillFlowData()
            end    
        end

        --设置量谱解锁参数要在量谱替换前面
        local UnlockSpectrumData
        if RoleDetail.Reason == ProtoCS.LevelUpReason.LevelUpReasonProf then
            if OldProfLevel and OldProfLevel > 0 then
                UnlockSpectrumData = {ProfID = ProfID, OldLevel = OldProfLevel, NewLevel = ProfLevel}
            end
        elseif IsAdvanceProf then
            UnlockSpectrumData = {ProfID = ProfID, OldLevel = OldProfLevel, NewLevel = ProfLevel, IsAdvanceProf = IsAdvanceProf}    
        end
        _G.MainProSkillMgr.UnlockSpectrumData = UnlockSpectrumData
        print(string.format("[SkillLogicMgr] MajorBaseInfo:Level %d,MapType %d,ProfID %d", SceneLevel, CurMapType, ProfID))
        MajorLogicData:SetBaseInfo(SceneLevel, CurMapType, ProfID)
        _G.MainProSkillMgr:ReqSpectrumData()
        self:RequireServerSkill()
    end

    --职业等级变化时不中断连招
    if RoleDetail.Reason ~= ProtoCS.LevelUpReason.LevelUpReasonProf then
        _G.SkillSeriesMgr:ClearSkill()
    end

     --职业等级变化时才会推送解锁
    if RoleDetail.Reason == ProtoCS.LevelUpReason.LevelUpReasonProf then
      if OldProfLevel and OldProfLevel > 0 then
        self:PostMajorUnlockSkillQueue(ProfID, OldProfLevel, ProfLevel)
      end
    elseif IsAdvanceProf then
        self:PostMajorUnlockSkillQueue(ProfID, OldProfLevel, ProfLevel, true)
    end
end

function SkillLogicMgr:OnGameEventMajorCreate()
    do
        local UIViewID = require("Define/UIViewID")
        local View = UIViewMgr:CreateView(UIViewID.SkillCancelJoyStick)
        UIViewMgr:RecycleView(View)
    end

    self.DisableSwitchToPeaceSkill = true
    local ProfID = MajorUtil.GetMajorProfID() or 0
    local Level = MajorUtil.GetMajorLevel() or 0

    if ProfID == 0 or Level == 0 then
        return
    end
    local MajorEntityID = _G.PWorldMgr.MajorEntityID

    local MajorLogicData = self:CreateSkillLogicData(MajorEntityID, true)
    self.MajorLogicData = MajorLogicData
    MajorLogicData.ServerSkillSyncInfo = self.MajorServerSkillSyncInfo

    _G.MainProSkillMgr:ReqSpectrumData()
    self:RequireServerSkill()
    
    _G.SkillSeriesMgr:ClearQueueSkillsCache()

    MainPanelVM:SetControlPanelAttrExist(false)

    -- 当前副本如果配置了玩法技能, 显示出来
    local CurrentPWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    local Cfg = SceneSkillCfg:FindCfgByKey(CurrentPWorldResID)
    if Cfg then
        _G.UIViewMgr:ShowView(_G.UIViewID.SkillExclusiveProp, {
            SkillList = Cfg.Skill,
            TipsContent = Cfg.TipsContent,
            TipsDuration = Cfg.TipsDuration
        })
    else
        _G.UIViewMgr:HideView(_G.UIViewID.SkillExclusiveProp)
    end

    local CurrPWorldResID = _G.PWorldMgr:GetCurrPWorldResID()
    local bPVP = PworldCfg:FindValue(CurrPWorldResID, "CanPK")
    local CurMapType = bPVP ~= 0 and MapType.PVP or MapType.PVE
    MajorLogicData:SetBaseInfo(Level, CurMapType, ProfID)

    -- init team skills
    _G.TeamMgr.InitMajorTeamSkills()
end

function SkillLogicMgr:OnNetworkReconnected(Params)
	if Params.bRelay == false then
        MainPanelVM:SetControlPanelAttrExist(false)
    end
    if self.bIsRequiringSkillList then
        -- 没收到技能列表的回包, 重发一次请求
        self:ReqSkillList()
    end
end

function SkillLogicMgr:OnMajorEntityIDUpdate(Params)
    self:OnEntityIDUpdate(Params.ULongParam1)
end

---------------------技能列表初始化END-----------------

---------------------技能(列表)替换-----------------

function SkillLogicMgr:OnSkillUpdate(Params)
    local LogicData = self.MajorLogicData
    if LogicData and LogicData.SkillMap[Params.SkillIndex] then
        LogicData.SkillMap[Params.SkillIndex].SkillID = Params.SkillID
        Params.EntityID = self.MajorLogicData.EntityID
        _G.EventMgr:SendEvent(EventID.SkillReplace, Params)
    end
end

--技能替换
function SkillLogicMgr:OnNetMsgCombatSkillReplace(MsgBody)
    --技能替换
    local SkillReplace = MsgBody.SkillReplace
    if SkillReplace == nil then
        return
    end

    FLOG_INFO(string.format("[SkillLogicMgr]NetMsg SkillReplace: %s", table_to_string(SkillReplace)))

    local LogicData = self.MajorLogicData
    if LogicData == nil then
        return
    end

    local SourceID = SkillReplace.SourceID
    local TargetID = SkillReplace.TargetID
    local Type = SkillReplace.Type
    local Pos = SkillReplace.Pos
    local EntityID = _G.PWorldMgr.MajorEntityID
    
    if Pos then
        local SkillInfo = LogicData.SkillMap[Pos]
        if SkillInfo then
            if SkillInfo.SkillID ~= SourceID then
                FLOG_WARNING(string.format("[SkillLogicMgr]ServerSkillID: %d not equal clientSkillID: %d, Index = %d", SourceID, SkillInfo.SkillID or 0, Pos))
            end
            --按索引替换应该考虑连招和蓄力时替换
            --替换时break掉当前index蓄力/连招
            _G.SkillSeriesMgr:ClearSkillbyIndex(Pos)
            _G.SkillStorageMgr:BreakStorageSkill(EntityID, SkillInfo.SkillID)

            if SkillInfo.SkillID ~= TargetID then
                local RawSkill = SkillInfo.SkillID
                SkillInfo.SkillID = TargetID
                SkillInfo.AffectedFlag = ConstAffectedFlag
                local Params = {SkillIndex = Pos, SkillID = TargetID, Type = Type, EntityID = EntityID, RawSkill = RawSkill}
                _G.EventMgr:SendEvent(EventID.SkillReplace, Params)
            end
        else
            LogicData:InitSkillMap(Pos, TargetID)
        end
    end
end

--技能列表替换
function SkillLogicMgr:OnNetMsgSkillListReplace(MsgBody)
    local AllList = MsgBody.SkillReplace.SkillList
    self:ServerSkillListReplace(AllList)
end

function SkillLogicMgr:ServerSkillListReplace(ServerSkillList)
    local LogicData = self.MajorLogicData
    if LogicData == nil then
        return
    end
    local ProfID = LogicData:GetProfID()
    local Level = LogicData:GetLevel()
    local MapType = LogicData:GetMapType()
    local CacheSkillList = self:GetMajorCacheSkillList(ProfID, Level, MapType)
    local ClientSkillList = CacheSkillList and CacheSkillList.SkillList or {}
    LogicData:OnServerSkillListReplace(ServerSkillList, ClientSkillList)
end

---------------------技能(列表)替换END-----------------

function SkillLogicMgr:IsSkillPress()
    local LogicData = self.MajorLogicData
    if LogicData then
        return LogicData:IsSkillPress()
    end
    return false
end

---------------------按钮状态-------------------------------

--设置全部按钮可用性(目前为通用遮罩)(如major吟唱开始时需禁用全部按钮，结束时恢复)
--使用时应考虑各种边界情况，避免因未及时恢复导致按钮不可用
--Key SkillBtnState
--Condition 设置状态的条件，false表示不可用，true表示可用，nil表示无视
function SkillLogicMgr:SetSkillButtonEnable(_, Key, Listener, Condition, Params)
    local LogicData = self.MajorLogicData
    if Condition == nil or LogicData == nil then
        return
    end
    LogicData:SetSkillButtonEnable(Key, Listener, Condition, Params)
end

function SkillLogicMgr:OnMajorSkillCanUse(Params)
    local bCanUse = Params.BoolParam1
    local EntityID = MajorUtil.GetMajorEntityID()
    self:SetSkillButtonEnable(EntityID, SkillBtnState.CanUseSkill, nil, function()
        return bCanUse
    end)
end

function SkillLogicMgr:OnMajorDead()
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    self:SetSkillButtonEnable(MajorEntityID, SkillBtnState.Dead, nil, function() return false end)
end

local SYSCHATMSGBATTLETYPE_MAJORREVIVE<const> = ChatDefine.SysChatMsgBattleType.MajorRevive
function SkillLogicMgr:OnActorRevive(Params)
    if nil == Params then
        return
    end

    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if Params.ULongParam1 == MajorEntityID then
        self:SetSkillButtonEnable(MajorEntityID, SkillBtnState.Dead, nil, function() return true end)
         --你从无法复活状态复苏了
        local ChatParams = {}
        ChatParams.ChatType = SYSCHATMSGBATTLETYPE_MAJORREVIVE
        self:PushSysChatMsgBattle(ChatParams)
        -- local Content = RichTextUtil.GetText(string.format("%s", LSTR(140091)), "d1ba8e")
	    -- _G.ChatMgr:AddSysChatMsgBattle(Content)
    end
end

function SkillLogicMgr:OnGameEventStartSwimming(Params)
    local EntityID = Params.ULongParam1
    local LogicData = self.MajorLogicData
    if LogicData and LogicData.EntityID == EntityID then
        LogicData:SetSkillButtonEnable(SkillBtnState.Swimming_Fly, nil, function(_, SkillID)
            return SkillMainCfg:FindValue(SkillID, "ValidSwimmingOrDivingOrFlying") == 1
        end)
    end
end

function SkillLogicMgr:OnGameEventEndSwimming(Params)
    local EntityID = Params.ULongParam1

    local LogicData = self.MajorLogicData
    if LogicData and LogicData.EntityID == EntityID then
        LogicData:SetSkillButtonEnable(SkillBtnState.Swimming_Fly, nil, function()
            return true
        end)
    end
end

function SkillLogicMgr:OnGameEventMountFlyStateChange(Params)
    local EntityID = Params.ULongParam1
    local bFly = Params.BoolParam1
    local LogicData = self:GetSkillLogicData(EntityID)
    if LogicData and LogicData.bMajor and EntityID == LogicData.EntityID then
        if bFly then
            LogicData:SetSkillButtonEnable(SkillBtnState.Swimming_Fly, nil, function(_, SkillID)
                return SkillMainCfg:FindValue(SkillID, "ValidSwimmingOrDivingOrFlying") == 1
            end)
        else
            LogicData:SetSkillButtonEnable(SkillBtnState.Swimming_Fly, nil, function()
                return true
            end)
        end
    end
end

function SkillLogicMgr:OnNetStateUpdate(Params)
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    if Params.ULongParam1 ~= MajorEntityID then
        return
    end
    local bCombatBit = Params.IntParam1 == ProtoCommon.CommStatID.COMM_STAT_COMBAT
    if not bCombatBit then
        return
    end
    local CurCombatState = Params.BoolParam1
    local IsCombatState = CurCombatState and 1 or 0
    SkillLogicMgr:SetSkillButtonEnable(MajorEntityID, SkillBtnState.UseStatus, nil, function(_, SkillID)
        local UseStatus = SkillMainCfg:FindValue(SkillID, "UseStatus") or 0
        local SkillUseStatueEnum = ProtoRes.skill_use_status
        if SkillUseStatueEnum.SKILL_USE_STATUS_ALL == UseStatus then
            return nil
        end
        UseStatus = UseStatus - 1
        return (UseStatus ~ IsCombatState) == 1
    end)
end

function SkillLogicMgr:OnEventControlStateChange(Params)
    if MajorUtil.GetMajorEntityID() ~= Params.ULongParam1 then
        return
    end
    local LogicData = self.MajorLogicData
    if LogicData then
        LogicData.PostStateChange = true
    end
end

function SkillLogicMgr:OnSkillProcessPreSlateTick()
    local LogicData = self.MajorLogicData
    if LogicData then
        LogicData:OnSkillProcessPreSlateTick()
    end
end

function SkillLogicMgr:OnMajorMPChange(Params)
    local LogicData = self.MajorLogicData
    if LogicData and Params.ULongParam1 == LogicData.EntityID and ProfUtil.IsCombatProf(LogicData:GetProfID()) then
        LogicData:OnSkillAssetAttrUpdate(SkillBtnState.SkillMP, ProtoCommon.attr_type.attr_mp)
    end
end

function SkillLogicMgr:OnMajorGPChange(Params)
    local LogicData = self.MajorLogicData
    if LogicData and LogicData.EntityID == Params.ULongParam1 then
        local ProfID = LogicData:GetProfID()
        if _G.GatherMgr:IsGatherProf(ProfID) or ProfID == ProtoCommon.prof_type.PROF_TYPE_FISHER then
            LogicData:OnSkillAssetAttrUpdate(SkillBtnState.SkillGP, ProtoCommon.attr_type.attr_gp)
        end
    end
end

local function SkillWeightChangeFunction(_, SkillID, Params)
    local SkillWeight = SkillMainCfg:FindValue(SkillID, "SkillWeight") or 0
    return SkillWeight > Params.SkillWeight
end

function SkillLogicMgr:OnMajorChangeSkillWeight(Params)
    local _ <close> = CommonUtil.MakeProfileTag("SkillLogicMgr:OnMajorChangeSkillWeight")
    local LogicData = self.MajorLogicData
    if LogicData ~= nil then
        LogicData:SetSkillButtonEnable(SkillBtnState.SkillWeight, nil, SkillWeightChangeFunction, Params)
    end
end

---------------------按钮状态END-------------------------------

--直接释放普工技能
function SkillLogicMgr:CastMainAttackSkill()
    local LogicData = self.MajorLogicData
    if LogicData then
        local SkillID = LogicData:GetBtnSkillID(0)
        if SkillID and SkillID > 0 then
            --目前生活技能的cd，服务器是没同步给客户端的
			-- local SkillCDInfo = _G.SkillCDMgr:GetSkillCD(SkillID)

            local CurSkillWeight = _G.SkillPreInputMgr:GetCurrentSkillWeight()
            if CurSkillWeight then
                local SubSkillID = _G.SkillLogicMgr:GetMultiSkillReplaceResult(SkillID, self.MajorLogicData.EntityID)
                local ToCastSkillWeight = _G.SkillPreInputMgr:GetInputSkillWeight(SubSkillID)
                if ToCastSkillWeight and ToCastSkillWeight <= CurSkillWeight then
                    -- FLOG_INFO("CastMainAttackSkill CurSkillWeight: %d ToCastSkillWeight: %d", CurSkillWeight, ToCastSkillWeight)
                    return -1
                end
            end

            --临时的不完善但目前够用的
            local SkillCD = SkillMainCfg:FindValue(SkillID, "CD")
            local CastTime = TimeUtil.GetServerTimeMS()
            local CDInfo = self.LifeSkillCDList[SkillID]
            if CDInfo and CDInfo.CastTime and CDInfo.SkillCD then
                if CastTime - CDInfo.CastTime < CDInfo.SkillCD then
                    FLOG_INFO("----------- CastMainAttackSkill CastTime %d  CD:%d ---------", CastTime, SkillCD)
                    FLOG_INFO("CastMainAttackSkill cding  time:%d", CastTime - CDInfo.CastTime)
                    _G.MsgTipsUtil.ShowTipsByID(MsgTipsID.LifeSkillCDing)
                    return -2
                end

                CDInfo.CastTime = CastTime
            else
                self.LifeSkillCDList[SkillID] = {CastTime = CastTime, SkillCD = SkillCD}
            end

            SkillUtil.CastLifeSkill(0, SkillID)
            return 0
        end
    end

    return -3
end

function SkillLogicMgr:GetLifeSkillCDInfo(SkillID)
    local CDInfo = self.LifeSkillCDList[SkillID]
    if CDInfo then
        return CDInfo
    end

    return nil
end

function SkillLogicMgr:CheckLifeSkillCD(SkillID)
    local CDInfo = self.LifeSkillCDList[SkillID]
    if CDInfo then
        if CDInfo.CastTime and CDInfo.SkillCD then
            local CastTime = TimeUtil.GetServerTimeMS()
            if CastTime - CDInfo.CastTime < CDInfo.SkillCD then
                return false
            end
        end
    end

    return true
end

function SkillLogicMgr:GetMultiSkillReplaceResult(SkillID, CasterEntityID)
    local Cfg = SkillMainCfg:FindCfgByKey(SkillID)
    if not Cfg then
        return 0
    end
    local IDList = Cfg.IdList
    if IDList == nil or IDList[1] == nil then
        return 0
    end

    local SelectType = Cfg.SelectType
    if SelectType == ProtoRes.skill_select_type.skill_select_none then
        return IDList[1].ID
    end

    local CasterActor = MajorUtil.GetMajor()

    local Target = GetCurrSelectedTarget(USelectEffectMgr)
	local SkillFirstClass = Cfg.SkillFirstClass
	if SkillFirstClass == ProtoRes.skill_first_class.PRODUCTION_SKILL then
        if CasterEntityID ~= 0 then
            CasterActor = ActorUtil.GetActorByEntityID(CasterEntityID)
        end
        
        Target = CasterActor
    elseif SkillFirstClass == ProtoRes.skill_first_class.LIFE_SKILL then
        local TargetEntityID = _G.GatherMgr.CurActiveEntityID
        if TargetEntityID then
            Target = ActorUtil.GetActorByEntityID(TargetEntityID)
        end

        if not Target then
            Target = CasterActor
        end
    end

    if SelectType == ProtoRes.skill_select_type.skill_select_derived then
        local bReplace = false
        local SubID = 0
        for _, value in ipairs(IDList) do
            local ConditionExpr = value.Param
            local CheckRet
            do
                local _ <close> = CommonUtil.MakeProfileTag("MultiSkillReplaceCheck")
                CheckRet = SelectTargetFilter:MultiSkillReplaceCheck(ConditionExpr, CasterActor, Target)
            end
            if ConditionExpr == "" or ConditionExpr == "0" or CheckRet then
                bReplace = true
                SubID = value.ID
                break
            end
        end
        if bReplace == false then
            SubID = IDList[1].ID
        end
        return SubID
    end
    return 0
end

--属性修正
function SkillLogicMgr:OnNetMsgCombatSSyncSkillRes(MsgBody)
    local SkillRes = MsgBody.SkillRes
    local SkillID = SkillRes.SkillID
    local ResType = SkillRes.ResType
    local Min = SkillRes.Min
    local Value = SkillRes.Value

    local SkillCostList = self.MajorServerSkillSyncInfo.SkillCostList
    if SkillCostList[SkillID] == nil then
        SkillCostList[SkillID] = {}
    end
    SkillCostList[SkillID][ResType] = {Min = Min, Value = Value}

    if ResType == ProtoCommon.attr_type.attr_mp or ResType == ProtoCommon.attr_type.attr_gp then
        _G.EventMgr:SendEvent(EventID.SkillResSync, SkillRes)
    end
end

function SkillLogicMgr:IsSkillLearned(EntityID, SkillID)
    local LogicData = self:GetSkillLogicData(EntityID)
    if LogicData then
        return LogicData:IsSkillLearned(SkillID)
    end
    return SkillUtil.SkillLearnStatus.Unknown, 0
end


---------------------------------------SkillSystem Only-----------------------------------------

function SkillLogicMgr:IsSkillSystemInternal(EntityID)
    local LogicData = self:GetSkillLogicData(EntityID or 0)
    if LogicData and LogicData.bMajor == false then
        return true
    end
    return false
end

local IsSkillSystemByEntityID <const> = _G.UE.USkillUtil.IsSkillSystemByEntityID

function SkillLogicMgr:IsSkillSystem(EntityID)
    -- if SkillSystemMgr.bIsActive then
    --     return SkillSystemMgr:IsSkillSystem(EntityID)
    -- end
    -- return self:IsSkillSystemInternal(EntityID)
    return IsSkillSystemByEntityID(EntityID)
end


function SkillLogicMgr:ResetPlayerSkillSeriesIndex(EntityID, Index)
    local LogicData = self.LogicDataList[EntityID]
    if LogicData then
        local SkillInfo = LogicData.SkillMap[Index] or {}
        SkillInfo.SeriesIndex = 0
        LogicData:SkillMoveNext(0, 0)
    end
end

function SkillLogicMgr:GetPlayerSeriesList(EntityID, Index)
    local LogicData = self.LogicDataList[EntityID]
    if LogicData then
        return LogicData:GetPlayerSeriesList(Index)
    end
    return {}
end

function SkillLogicMgr:CanPlayerSimulateReplaceShowTableView(EntityID, Index)
    local LogicData = self.LogicDataList[EntityID]
    if not LogicData then
        return false
    end
    local SkillInfo = LogicData.SkillMap[Index]
    if not SkillInfo then
        return false
    end
    local SeriesList = SkillInfo.SeriesList
    if not SeriesList or #SeriesList == 0 then
        return false
    end
    if SkillInfo.bShowTableView then
        return true
    end
    return false
end
---------------------------------------SkillSystem End-----------------------------------------
---@param Index number
--see SkillCommonDefine.SkillButtonIndexRange
function SkillLogicMgr:MajorPlaySkill(Index)
    _G.EventMgr:SendEvent(EventID.SimulateMajorSkillCast, Index)
end

function SkillLogicMgr:OnEntityIDUpdate(MajorEntityID)
    if self.MajorLogicData then
        local EntityID = self.MajorLogicData.EntityID
        if EntityID ~= MajorEntityID then
            _G.FLOG_WARNING(
                "[SkillLogicMgr] Major EntityID change, %d -> %d.",
                EntityID or 0, MajorEntityID or 0)
            self.MajorLogicData:OnEntityIDUpdate(MajorEntityID)
        end
    end
end

--播放技能解锁动效
function SkillLogicMgr:OnModuleOpenSkillUnLock(Params)
    local ProfID = MajorUtil.GetMajorProfID()
    if nil == Params.ProfID or nil == ProfID then
        return
    end
    if Params.ProfID ~= ProfID then
        return
    end
    local MajorLogicData = self.MajorLogicData
    if MajorLogicData == nil then
        FLOG_ERROR("[SkillLogicMgr]Invalid Skill Logic Data in OnModuleOpenSkillUnLock")
        return
    end
    if MajorUtil.GetMajorLevelByProf(Params.ProfID) <= MajorUtil.GetMajorLevel() then
        MajorLogicData:PlaySkillUnLockEffect(Params.SkillID)
    end
end


function SkillLogicMgr:OnFreezeCD(GroupID, EndFreezeTime, FreezeCD)
    local BagMgr = _G.BagMgr
    if BagMgr.ProfMedicineTable then
		local ResID = BagMgr.ProfMedicineTable[MajorUtil.GetMajorProfID()]

        local Cfg = ItemCfg:FindCfgByKey(ResID)
        if nil == Cfg then
            return
        end
    
        if Cfg.FreezeGroup == GroupID then
            local CurTime = TimeUtil.GetServerTime()
		    local CD = EndFreezeTime - CurTime
            _G.EventMgr:SendEvent(EventID.SkillMedicineCDUpdate, CD, FreezeCD)
        end
    end
end

function SkillLogicMgr:OnReportProductionSkillFlowData()
    --未登录状态，当前非生产职业
    local ProfID = MajorUtil.GetMajorProfID()
    if nil == ProfID then
        return
    end
    local ProFunction = ProfUtil.Prof2Func(ProfID)
    if ProFunction ~= ProtoCommon.function_type.FUNCTION_TYPE_PRODUCTION 
        and ProFunction ~= ProtoCommon.function_type.FUNCTION_TYPE_GATHER then
        return
    end    
    SkillUtil:ReportProductionSkillFlowData()
end

---------------------战斗记录相关----------------------------------------------
--- 监听战斗信息

local CS_ATTACK_EFFECT_HP_DAMAGE<const> = ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_HP_DAMAGE
local CS_ATTACK_EFFECT_HP_HEAL<const> = ProtoCS.CS_ATTACK_EFFECT.CS_ATTACK_EFFECT_HP_HEAL
local SYSCHATMSGBATTLETYPE_ATTACKEFFECTCHANGE<const> = ChatDefine.SysChatMsgBattleType.AttackEffectChange
local SYSCHATMSGBATTLETYPE_BUFFUPDATE<const> = ChatDefine.SysChatMsgBattleType.BuffUpdate
local SYSCHATMSGBATTLETYPE_MAJORDIE<const> = ChatDefine.SysChatMsgBattleType.MajorDie
local SYSCHATMSGBATTLETYPE_USEITEM<const> = ChatDefine.SysChatMsgBattleType.UseItem
local EFFECT_HURT_TYPE_PHY<const>  = ProtoCommon.EFFECT_HURT_TYPE.EFFECT_HURT_TYPE_PHY
local EFFECT_HURT_TYPE_MAG<const>  = ProtoCommon.EFFECT_HURT_TYPE.EFFECT_HURT_TYPE_MAG

function SkillLogicMgr:OnGameEventAttackEffectChange(Params)
    --local _ <close> = CommonUtil.MakeProfileTag("OnGameEventAttackEffectChange")
	if nil == Params then
		return
	end
    local ChatParams = {}
    local AttackedHurt = Params.Value
	local AttackObjID = Params.AttackObjID
	local AttackGiver = ActorUtil.GetActorName(AttackObjID)
	local BehitObjID = Params.BehitObjID
	if nil == AttackGiver or "" == AttackGiver or BehitObjID ~= MajorUtil.GetMajorEntityID() then
		return
	end
    ChatParams.AttackedHurt = AttackedHurt
    ChatParams.AttackGiver = AttackGiver
    ChatParams.EffectType = Params.EffectType
    ChatParams.HurtType = Params.HurtType
    ChatParams.ChatType = SYSCHATMSGBATTLETYPE_ATTACKEFFECTCHANGE
    self:PushSysChatMsgBattle(ChatParams)
end
function SkillLogicMgr:AddAttackEffectChangeMsg(Params)
    -- local _ <close> = CommonUtil.MakeProfileTag("AddAttackEffectChangeMsg")
    local AttackedHurt = Params.AttackedHurt
	local AttackGiver = Params.AttackGiver
	--受到伤害
	if CS_ATTACK_EFFECT_HP_DAMAGE == Params.EffectType then
		local AttackedHurtType = Params.HurtType
		if nil == AttackedHurt or nil == AttackedHurtType or AttackedHurt <= 0 then
			return
		end
		local IconPath = "Texture2D'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_Special_png.UI_Chat_Icon_Special_png'"
		if AttackedHurtType == EFFECT_HURT_TYPE_PHY then
			IconPath = "Texture2D'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_Physics_png.UI_Chat_Icon_Physics_png'"
		elseif AttackedHurtType == EFFECT_HURT_TYPE_MAG then
			IconPath = "Texture2D'/Game/UI/Atlas/ChatNew/Frames/UI_Chat_Icon_Magic_png.UI_Chat_Icon_Magic_png'"
		end
        --你受到了点伤害
		local AttackedHurtRichText =  RichTextUtil.GetText(string.format("%s", AttackedHurt), "d1ba8e")
        local AttackedHurtTypeIcon =  RichTextUtil.GetTexture(IconPath,40, 40, -10)
        local ContentLSTR = string.format("%s%s", AttackedHurtTypeIcon, AttackedHurtRichText)
        local ContentLSTR2 = string.format(LSTR(140092), ContentLSTR)
        --来源
		local AttackGiverRichText = RichTextUtil.GetText(string.format(LSTR(140086), AttackGiver), "d1ba8e")
		local Content = string.format("%s%s",ContentLSTR2, AttackGiverRichText)
		_G.ChatMgr:AddSysChatMsgBattle(Content)
	--恢复体力
	elseif CS_ATTACK_EFFECT_HP_HEAL == Params.EffectType then
        --你恢复了%s点体力
		local AttackedHurtRichText =  RichTextUtil.GetText(string.format(LSTR(140089), AttackedHurt), "d1ba8e")
		local AttackGiverRichText = RichTextUtil.GetText(string.format(LSTR(140086), AttackGiver), "d1ba8e")
		local Content = string.format("%s%s",AttackedHurtRichText,AttackGiverRichText)
		_G.ChatMgr:AddSysChatMsgBattle(Content)
	end
end

---在系统频道展示死亡消息
---@param EntityID 被攻击者
---@param KillerID 攻击者
function SkillLogicMgr:OnEntityDieCombatLog(EntityID, KillerID)
	if EntityID ~= MajorUtil.GetMajorEntityID() then
		return
	end
    local ChatParams = {}
    ChatParams.EntityID = EntityID
    ChatParams.KillerID = KillerID
    ChatParams.ChatType = SYSCHATMSGBATTLETYPE_MAJORDIE
    self:PushSysChatMsgBattle(ChatParams)
end

function SkillLogicMgr:AddMajorDieMsg(Params)
    local Killer = ActorUtil.GetActorName(Params.KillerID)
	if nil == Killer or Params.EntityID == Params.KillerID then
        Killer = ""
	end
    --你被%s打倒了
    local Content = RichTextUtil.GetText(string.format(LSTR(140085), Killer),
     "d1ba8e")
    _G.ChatMgr:AddSysChatMsgBattle(Content)
end

function SkillLogicMgr:PushSysChatMsgBattle(Params)
    -- local _ <close> = CommonUtil.MakeProfileTag("PushSysChatMsgBattle")
    if nil == Params then
       return 
    end
    table.insert(self.SysChatMsgBattleList,Params)
    if nil == self.SysChatMsgBattleTimerID then
        self.SysChatMsgBattleTimerID = _G.TimerMgr:AddTimer(self, self.PopSysChatMsgBattle, 0, 0.5, 0, nil, "PopSysChatMsgBattle")
    end
end

function SkillLogicMgr:AddSysChatMsgBattleFromList()
    local _ <close> = CommonUtil.MakeProfileTag("AddSysChatMsgBattleFromList")
    local ChatParams = self.SysChatMsgBattleList[1]
    table.remove(self.SysChatMsgBattleList, 1)
    if ChatParams then
        if ChatParams.ChatType == SYSCHATMSGBATTLETYPE_ATTACKEFFECTCHANGE then
            self:AddAttackEffectChangeMsg(ChatParams)
        elseif ChatParams.ChatType == SYSCHATMSGBATTLETYPE_BUFFUPDATE then
            _G.SkillBuffMgr:AddBuffUpdateMsg(ChatParams)
        elseif ChatParams.ChatType == SYSCHATMSGBATTLETYPE_MAJORDIE then
            self:AddMajorDieMsg(ChatParams)
        elseif ChatParams.ChatType == SYSCHATMSGBATTLETYPE_MAJORREVIVE then
            local Content = RichTextUtil.GetText(string.format("%s", LSTR(140091)), "d1ba8e", 0, nil)
            _G.ChatMgr:AddSysChatMsgBattle(Content)
        elseif ChatParams.ChatType == SYSCHATMSGBATTLETYPE_USEITEM then
            _G.ChatMgr:ShowUseItemInSysChatMsgBattle(ChatParams.GID, ChatParams.ResID)
        end
    end
end
function SkillLogicMgr:StartAddSysChatMsgBattle()
    -- local _ <close> = CommonUtil.MakeProfileTag("StartAddSysChatMsgBattle")
    --隔帧处理
    self:RegisterTimer(self.AddSysChatMsgBattleFromList, 0, 0.04, SkillCommonDefine.SysChatMsgBattleLimit)    
end

function SkillLogicMgr:PopSysChatMsgBattle()
    -- local _ <close> = CommonUtil.MakeProfileTag("PopSysChatMsgBattle")
    if #self.SysChatMsgBattleList <= 0 then
        if self.SysChatMsgBattleTimerID then
            _G.TimerMgr:CancelTimer(self.SysChatMsgBattleTimerID)
            self.SysChatMsgBattleTimerID = nil
        end
        return
    end
    self:StartAddSysChatMsgBattle()
    --处理完了，判断队列中是否还有数据，若有，0.3s后再pop一轮
    if #self.SysChatMsgBattleList > 0 then
        self:RegisterTimer(self.StartAddSysChatMsgBattle, 0.3)
    end
end

function SkillLogicMgr:SetSysChatMsgBattleLimit(Param)
    SkillCommonDefine.SysChatMsgBattleLimit = Param
end
---------------------战斗记录相关End----------------------------------------------
---
---
-----DEBUG
function SkillLogicMgr:PrintMajorButtonState()
    local LogicData = self:GetMajorSkillLogicData()
    if LogicData then
        return LogicData:PrintButtonState()
    end
    return ""
end

function SkillLogicMgr:AddSysChatMsgBattleDebug(AttackNum, BuffNum)
    local _ <close> = CommonUtil.MakeProfileTag("AddSysChatMsgBattleDebug")
    local ChatNum = AttackNum
    if ChatNum < BuffNum then
        ChatNum = BuffNum
    end
    for i = 1, ChatNum do
        if i <= AttackNum then
            local ChatParams = {}
            ChatParams.Value = 21 + i
            ChatParams.AttackObjID = MajorUtil.GetMajorEntityID()
            ChatParams.BehitObjID = MajorUtil.GetMajorEntityID()
            ChatParams.EffectType = CS_ATTACK_EFFECT_HP_DAMAGE
            if i%2 == 0 then
                ChatParams.HurtType = EFFECT_HURT_TYPE_MAG
            else
                ChatParams.HurtType = EFFECT_HURT_TYPE_PHY
            end
            self:OnGameEventAttackEffectChange(ChatParams)
        end
        if i <= BuffNum then
            local BuffInfo = _G.SkillBuffMgr:AddSysChatMsgBattleDebug(6058+i)
            self:PushSysChatMsgBattle(BuffInfo)
        end
    end
end
---
return SkillLogicMgr
