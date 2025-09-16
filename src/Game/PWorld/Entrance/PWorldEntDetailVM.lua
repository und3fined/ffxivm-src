--[[
Author: v_hggzhang
Date: 2024-06-12 16:30:36
LastEditors: jususchen jususchen@tencent.com
LastEditTime: 2024-06-13 11:45:13
FilePath: \Script\Game\PWorld\Entrance\PWorldEntDetailVM.lua
Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
--]]
local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")

local UIBindableList = require("UI/UIBindableList")
local PWorldTaskSetUpListItemVM = require("Game/PWorld/Item/PWorldTaskSetUpListItemVM")
local PWorldEntEntityVM = require("Game/PWorld/Entrance/PWorldEntEntityVM")
local PWorldRewardVM = require("Game/PWorld/Entrance/ItemVM/PWorldRewardVM")
local ItemTipsVM = require("Game/Item/ItemTipsVM")
local PWorldDirectorTreeItemVM = require("Game/PWorld/Entrance/ItemVM/PWorldDirectorTreeItemVM")

local TimeUtil = require("Utils/TimeUtil")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")
local LocalizationUtil = require("Utils/LocalizationUtil")
local PWorldEntDefine = require("Game/PWorld/Entrance/PWorldEntDefine")
local PWorldQuestDefine = require("Game/PWorld/Quest/PWorldQuestDefine")
local MentorDefine = require("Game/Mentor/MentorDefine")

local CrystallineParamCfg = require("TableCfg/CrystallineParamCfg")
local SceneEnterTypeCfg = require("TableCfg/SceneEnterTypeCfg")
local MajorUtil = require("Utils/MajorUtil")

local ProtoRes = require("Protocol/ProtoRes")
local GlobalCfg = require("TableCfg/GlobalCfg")

local PWorldEntMgr
local ProtoCommon = require("Protocol/ProtoCommon")
local PWorldHelper = require("Game/PWorld/PWorldHelper")
local FUNCTION_TYPE = ProtoCommon.function_type
local ScenePoolType = ProtoCommon.ScenePoolType
local SceneMode = ProtoCommon.SceneMode

local LSTR = _G.LSTR
local CHOCOBO_INFO_TIPS_ID = 11193

local RoleInfoMgr

--- @class PWorldEntDetailVM : UIViewModel
--- @field Policy PWorldEntPol
local PWorldEntDetailVM = LuaClass(UIViewModel)


-- 分类 预留的，后面副本入口有分类
---@deprecated #TODO PENDING DELETE
local Cate = 1

-------------------------------------------------------------------------------------------------------
---@see Template

function PWorldEntDetailVM:Ctor()
    self.IsDailyRandom = false
	-- 副本入口类型
    self.LastEntType = nil
    self:SetEntTy(1) -- Type and ID are same
    self.SubType = 1 -- 二级副本类型
    self.EntTyIcon = ""
    self.EntTyName = ""
    self.TyData = nil
    self.TyVMs = {} -- UIBindableList.New()
    self.IsExpandAll = true
    -- 匹配
    self.IsMatching = false
    self.IsShowCancelMatchBtn = false
    self.CurMatchEstTimeDesc = ""
    self.CancelText = ""

    self.MaxMatchCnt = 0
    self.CurMatchCnt = 0
    -- 副本
    self.EntCfg = nil
    self.PWorldID = 0
    self.IsPWorldLocked = false
    self.PWorldName = ""
    self.PWorldRequireLv = 0 -- 副本所需Lv
    self.PWorldMaxMemCnt = 0
    self.BG = ""
    self.bShowSubTitle = false
    self.SubTitleText = ""
    -- PWorldRequireProfFuncDict[CLASS_TYPE] = 需要数量（配置表）
    self.PWorldRequireProfFuncDict = {}
    self.PWorldRequireEquipLv = 0
    self.PWorldInfor = ""
    self.PWorldSummary = ""
    self.PWorldExtraDesc = ""
    -- 参见按钮
    self.IsJoinBtnVisible = false
    self.IsJoinBtnEnable = false
    self.JoinBtnText = ""
    self.ForbidText = ""
    -- 副本权限
    self.IsPreCheckPass = false
    self.LevelRequireDesc = ""
    -- 副本列表
    self.PWorldsData = {}

    self.CurEntIdx = -1
    self.RewardTipsVM = ItemTipsVM.New()
    self.CurEntVM = nil
    -- 副本奖励
    self.bShowRewards = false
    self.RewardsData = {}
    self.RewardVMs = UIBindableList.New(PWorldRewardVM)
    self.CurRewardIdx = 0
    -- View相关
    self.IsTaskBtnVisible = false
    self.IsCommCloseMaskVisible = false
    self.IsModePanelVisible = false
    self.bTextRewardsVisible = true
    -- 设置
    self.EnableSettingModeNormal = false
    self.EnableSettingModeChallenge = false
    self.EnableSettingModeUnlimited = false
    self.EnableSettingModeExplore = false
    self.EnableSettingModeRoom = false
    self.EnableSettingModeChocoboRank = false
    self.TaskOp = -1
    self.TaskType = -1
    self:SetDifficultyCheckState(_G.UE.EToggleButtonState.Unchecked)
    self.bShowDifficultyDetail = false
    self.DifficultyVMs = UIBindableList.New((PWorldTaskSetUpListItemVM))
    -- 攻略按钮
    self.bBtnStrategy = true
    -- 策略
    self.Policy = nil
    -- 玩家RoleVM
    self.MajorRoleVM = nil
    -- Punish
    self.HasPunished = false
    self.PunishDesc = ""
    -- 招募
    self.RecruitID = 0
    self.bShowBtnRecruit = false

    self.bShowBtnHelp = false

    self.MemNumReqDesc = ""
    self.DefMemDesc = "0"
    self.HelMemDesc = "0"
    self.AtkMemDesc = "0"
    self.bLimitProf = true
    self.LvReqDesc = ""
    self.EquipReqDesc = ""

    self.PWorldEntList = UIBindableList.New(PWorldEntEntityVM)

    -- 指导者
    self.bOnDirectorPannel = false
    self.bShowDirectorNavBtn = false
    self.DirectorPworldListVMs = UIBindableList.New(PWorldDirectorTreeItemVM)
    self.bShowNavDirectorTips = false
    self.bShowDirectorUnReg = false

    self.BindableProperties["IsExpandAll"]:SetNoCheckValueChange(true)
    self.BindableProperties["TaskType"]:SetNoCheckValueChange(true)
    self.BindableProperties["TaskOp"]:SetNoCheckValueChange(true)

    self.LackProf = nil
    self:SetNoCheckValueChange("LackProf", true)    -- PVP默认就是nil，会导致稀缺控件不刷新

    -- 剧情辅助器
    self.IsShowBtnEncourage = false

    self:SetMuren(false)
    self.bShowMurenButton = false;

    self.bShortDesc = true
    self.bPassJoinLevel = false
    self.bPassTeamNum = false
    self.bPassEquipLv = false

    self.HelpInfoID = nil

    -- 陆行鸟相关
    self.IsShowChocoboPanel = false
    self.IsShowVerticalPWorld = true
    self.ChocoboMatchRequirementDes = ""
    self.IsShowChocoboMatchRequirementPrompt = false

    --排行榜按钮
    self.bShowBtnRank = false

    -- 额外条件
    self:SetExtraCondTitle(nil)
    self:SetExtraCondDetail(nil)
end

function PWorldEntDetailVM:OnInit()
    self.DailyRewardUpdateHour = GlobalCfg:FindValue(ProtoRes.global_cfg_id.GLOBAL_CFG_SCENE_DAILYRANDOM_REFRESH_HOUR_OFFSET, "Value")[1]
end

function PWorldEntDetailVM:OnBegin()
    RoleInfoMgr = _G.RoleInfoMgr
    self.TyData = PWorldEntUtil.GetPWordTypeListViewData()
    self.TyVMs = self.TyData --:UpdateByValues(self.TyData)

    PWorldEntMgr = _G.PWorldEntMgr
end

function PWorldEntDetailVM:OnShowEntranceView(Param)
    self:SetCommCloseMaskVisible(false)
    self.IsModePanelVisible = false

    if not Param then
        self:SetSelectType(ScenePoolType.ScenePoolRandom)
    else
        local TypeID = Param.TypeID or ScenePoolType.ScenePoolRandom
        self:SetSelectType(TypeID)
        local EID = Param.EID
        if EID then
            self:SetSelectedPWorldID(EID)
        end
    end
end

function PWorldEntDetailVM:OnHideEntranceView()
    -- self:UnSubLackProfUpd()
end

function PWorldEntDetailVM:UpdateEntInfo()
    self.Policy = PWorldEntUtil.GetPol(self.CurEntID, self.EntTy)
    if self.Policy == nil then
       _G.FLOG_ERROR("PWorldEntDetailVM: failed to get policy, ent: %s, entty: %s", self.CurEntID, self.EntTy) 
       return
    end
    local Info = self.Policy:GetEntInfo(self.CurEntID, self.SubType)

    self.EntCfg                  = Info.EntCfg 
    self.PWorldID                = Info.PWorldID
    self.BG                      = Info.BG
    self.PWorldName              = Info.PWorldName
    self.MaxMatchCnt             = Info.MaxMatchCnt
    self.PWorldRequireLv         = Info.PWorldRequireLv
    self.PWorldRequireEquipLv    = Info.PWorldRequireEquipLv
    self.IsChocoboRandomTrack    = Info.IsChocoboRandomTrack

    if Info.CombatCfg then
        if self.TaskType == SceneMode.SceneModeNormal or self.TaskType == SceneMode.SceneModeStory then
            self.EquipLvSyncReq = Info.CombatCfg.EquipMaxLv
        elseif self.TaskType == SceneMode.SceneModeChallenge then
            self.EquipLvSyncReq = Info.CombatCfg.EquipMinLv
        else
            self.EquipLvSyncReq = 0
        end
        self.SyncMaxLv = Info.CombatCfg.SyncMaxLv
    else
        self.EquipLvSyncReq = 0
        self.SyncMaxLv = 0
    end
end


function PWorldEntDetailVM:ToggleDifficultyCheckState()
    if self.DifficultyCheckState == _G.UE.EToggleButtonState.Checked then
        self:SetDifficultyCheckState(_G.UE.EToggleButtonState.Unchecked)
    else
        self:SetDifficultyCheckState(_G.UE.EToggleButtonState.Checked)
    end
end

function PWorldEntDetailVM:SetDifficultyCheckState(State)
    self.DifficultyCheckState = State
    self.bShowDifficultyDetail = self.DifficultyCheckState == _G.UE.EToggleButtonState.Checked
end

function PWorldEntDetailVM:UpdateVM()
    if self.CurEntID == nil or self.CurEntID == 0 then
       return 
    end

    if self.MajorRoleVM == nil then
        self:UpdateMajorRoleVM()
    end

    self.bShowMurenButton = not self.bMuren and (self.EntTy == ProtoCommon.ScenePoolType.ScenePoolAnnihilation or self.EntTy == ProtoCommon.ScenePoolType.ScenePoolLargeTask) and 
        _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDStoneSkySea)
    self.HasTeam = _G.TeamMgr:IsInTeam()
    self.IsDailyRandom = PWorldEntUtil.IsDailyRandom(self.EntTy)
    if self.EntTy == ProtoCommon.ScenePoolType.ScenePoolLargeTask and _G.SavageRankMgr:CheckScenceID(self.CurEntID) then
        self.bShowBtnRank = true
    else
        self.bShowBtnRank = false
    end
    -- subtitle
    self.bShowSubTitle = self.IsDailyRandom
    self:RefreshRewards()

    -- 根据类型有不同的更新策略 EntranceCfg
    self:UpdateEntInfo()

    self.RecruitID = self:GetEntranceCfgAttr("RecruitID")

    -- 设置选项
    self:SetDifficultyCheckState(_G.UE.EToggleButtonState.Unchecked)
    self:UpdateSettingModeEnable()
    self:SetTaskIdx(PWorldEntMgr:GetTaskOpCache(self.CurEntID, self.EntTy))

    -- 缓存选择副本ID
    if self.CachedEntSelectInfo == nil then
       self.CachedEntSelectInfo = {}
    end
    if self.EntTy then
        self.CachedEntSelectInfo[self.EntTy] = self.CurEntID
        if PWorldEntUtil.IsChocoboRandomTrack(self.SubType) then
            self.CachedEntSelectInfo[self.EntTy] = -1 -- 代表随机赛道
        end
   end

    self.PWorldSummary = self:GetEntranceCfgAttr("Summary", "")
    self.PWorldExtraDesc = self:CheckExtraDescription()
    self.PWorldInfor = self:GetEntranceCfgAttr("Explain", "")

    -- 检查指导者
    self:CheckDirector()

    self:UpdateRequireDesc()

    --  攻略按钮 #TODO  功能实现在启用
    self.bBtnStrategy = false       -- self.bBtnStrategy = not self.bMuren

    -- 招募
    self:UpdateRecruit()

    -- 奖励
    self:UpdateRewards()

    -- 切换时预先的参加条件检测
    self:UpdatePreCheck()

    -- 奖励选中
    self.CurRewardIdx = 0

    -- 匹配
    self:UpdMatch()

    -- 惩罚
    self:UpdPunish()

    -- UpdListenLack-Prof
    self:UpdLackProfUpd()

    -- 检查弹出引导
    self:CheckVisited()

    self.bShowBtnHelp = self:GetShowBtnHelp()

    self:UpdSettingBtnVisible()

    self:UpdateForbidText()

    self:UpdateHelp()
end

-- @return SceneEnterTypeCfg | nil
function PWorldEntDetailVM:GetEnterTypeCfg()
    return SceneEnterTypeCfg:FindCfgByKey(self.EntTy)
end

---@private
function PWorldEntDetailVM:GetShowBtnHelp()
    if PWorldEntUtil.IsCrystalline(self.SubType) then
        if PWorldEntUtil.IsCrystallineExercise(self.SubType) then
            return true
        else
            return false
        end
    else
        return not self.bOnDirectorPannel and not self.bMuren
    end
end
-------------------------------------------------------------------------------------------------------
---@see Upd

function PWorldEntDetailVM:UpdateHelp()
    if self.EntCfg == nil then
       _G.FLOG_ERROR("PWorldPreviewVM:UpdateHelp invalid EntCfg, ent type: %s, entid: %s", tostring(self.EntTy), tostring(self.CurEntID)) 
       return
    end

    if self.EntTy ==  ProtoCommon.ScenePoolType.ScenePoolChocobo then
        self.HelpInfoID = CHOCOBO_INFO_TIPS_ID
    else
        self.HelpInfoID = self:GetEntranceCfgAttr("HelpInfoID", -1)
    end
end

function PWorldEntDetailVM:RefreshRewards()
    if not self.bShowSubTitle then
		return	
	end

    local t = TimeUtil.GetServerTime()
    local utcOffTime = os.time() - os.time(os.date("!*t"))
    local date = os.date("*t", t)
    local mins = 0
    local utcOffHours = utcOffTime / 3600
    if utcOffHours >= 8 then
        mins = (utcOffHours - 8 + self.DailyRewardUpdateHour) * 60
    else
        mins = (-(8 - utcOffHours) + self.DailyRewardUpdateHour) * 60
    end
    local btime = os.time({
        year = date.year,
        month = date.month,
        day = date.day,
        hour = 0,
        min = math.floor(mins),
        sec = 0,
        isdst = false  -- 不考虑夏令时
    })

    local offtime = btime - t
    -- 最多相差26小时
    if offtime < 0 then
        offtime = offtime + 86400
    end
    if offtime < 0 then
        offtime = offtime + 86400
    end

    self.SubTitleText = PWorldHelper.pformat("DAILY_RAND_REFRESH", LocalizationUtil.GetCountdownTimeForLongTime(offtime))
    if math.abs(offtime) < 5 then
       self:UpdateRewards() 
    end
end

-- 玩家VM
function PWorldEntDetailVM:UpdateMajorRoleVM()
    local MajorRoleID = MajorUtil.GetMajorRoleID()
    self.MajorRoleVM = RoleInfoMgr:FindRoleVM(MajorRoleID)
end

-- 惩罚
function PWorldEntDetailVM:UpdPunish()
    local PunishStartTime = _G.PWorldMatchMgr.PunishStartTime
    if PunishStartTime == 0 then
        self.HasPunished = false
        self:UpdJoinBtn()
        return self.HasPunished
    end

    local PunishEplasedTime = math.max(TimeUtil.GetServerTime() - PunishStartTime, 0)
    local PublishInv = PWorldEntDefine.PublishInv()
    self.HasPunished = PunishEplasedTime <= PublishInv
    if self.HasPunished then
        self.PunishDesc = PWorldHelper.pformat("PUNISH_REMAIN_TIME", LocalizationUtil.GetCountdownTimeForShortTime(math.max(PublishInv - PunishEplasedTime, 0), "hh:mm:ss"))
    end
    self:UpdJoinBtn()
    return self.HasPunished
end

-- 招募
function PWorldEntDetailVM:UpdateRecruit()
    if PWorldEntUtil.IsCrystalline(self.SubType) then
        self.bShowBtnRecruit = false
    else
        self.bShowBtnRecruit = self.EntTy ~= ScenePoolType.ScenePoolChocobo and not self.bMuren and not (self.EntTy == 1 and (self.EntCfg or {}).ID == ProtoRes.DailyRandomSceneType.DailyRandomSceneTypeGuide)
    end
end

-- 副本入口类型
function PWorldEntDetailVM:UpdatePWorldType()
    local Cfg = self:GetEnterTypeCfg()
    if Cfg == nil then
        return
    end
    self.EntTyIcon = Cfg.Icon
    self.EntTyName = Cfg.Name
end

-- 奖励
function PWorldEntDetailVM:UpdateRewards()
    -- 查询时，还未初始化
    if not self.Policy then
        return
    end

    self.RewardsData = self.Policy:GetRewardData(self.EntCfg)
    self.RewardVMs:UpdateByValues(self.RewardsData)
    self.bShowRewards = self.RewardsData and #self.RewardsData > 0
end

local ReqDescCol = {
    Succ = "#D5D5D5FF",
    Fail = "#DC5868FF",
}

local GetColorReqDesc = function(Desc, Cond)
    local Col = Cond and ReqDescCol.Succ or ReqDescCol.Fail

    return string.format("<span color=\"%s\">%s</>", Col, Desc)
end

-- 职业等要求tips
function PWorldEntDetailVM:UpdateRequireDesc()
    local _, RltInfo = PWorldEntUtil.PreCheck(self.CurEntID, self.EntTy)
    RltInfo = RltInfo or {}
    local MemProfFuncDict = PWorldEntUtil.GetRequireMemProfFunc(self.CurEntID, self.EntTy)
    self.PWorldRequireProfFuncDict = MemProfFuncDict
    local MaxMemCnt = PWorldEntUtil.GetRequireMemCnt(self.CurEntID, self.EntTy)
    self.PWorldMaxMemCnt = MaxMemCnt

    local RecoverClassCnt = self.PWorldRequireProfFuncDict[FUNCTION_TYPE.FUNCTION_TYPE_RECOVER]
    local GuardClassCnt = self.PWorldRequireProfFuncDict[FUNCTION_TYPE.FUNCTION_TYPE_GUARD]
    local AttackClassCnt = self.PWorldRequireProfFuncDict[FUNCTION_TYPE.FUNCTION_TYPE_ATTACK]

    self.IsShowChocoboPanel = self.EntTy ==  ProtoCommon.ScenePoolType.ScenePoolChocobo
    if PWorldEntUtil.IsCrystalline(self.SubType) then
        self.IsShowVerticalPWorld = true
        self.bLimitProf = false
        self.bPassTeamNum = RltInfo.IsPassMem
        self.bPassJoinLevel = RltInfo.IsPassLv
        self.bPassEquipLv = RltInfo.IsPassEquipLv
        if PWorldEntUtil.IsCrystallineExercise(self.SubType) or PWorldEntUtil.IsCrystallineRank(self.SubType) then
            if self.bPassTeamNum then
                self.MemNumReqDesc = string.sformat(LSTR(1320003), self.PWorldMaxMemCnt)
            else
                self.MemNumReqDesc = string.sformat(LSTR(1320125), self.PWorldMaxMemCnt)
            end
        else
            self.MemNumReqDesc = LSTR(1320209)
        end

        if self.bPassJoinLevel then
            self.LvReqDesc = string.sformat(LSTR(1320004), self.PWorldRequireLv)
        else
            self.LvReqDesc = string.sformat(LSTR(1320126), self.PWorldRequireLv)
        end

        if self.bPassEquipLv then
            self.EquipReqDesc = string.sformat(LSTR(1320005), self.PWorldRequireEquipLv)
        else
            self.EquipReqDesc = string.sformat(LSTR(1320127), self.PWorldRequireEquipLv)
        end
    elseif self.EntTy ==  ProtoCommon.ScenePoolType.ScenePoolChocobo then
        self.IsShowVerticalPWorld = false
        self:CheckChocoboMatchRequirementPrompt()
    else
        self.IsShowVerticalPWorld = true
        self.bLimitProf = true
        if (self.PWorldMaxMemCnt or 0) <= 1 or self.bMuren or self.bOnDirectorPannel then
            self.MemNumReqDesc = LSTR(1320010)
        else
            self.MemNumReqDesc = string.sformat(LSTR(1320011), self.PWorldMaxMemCnt)
        end
        self.DefMemDesc = tostring((self.bMuren or self.bOnDirectorPannel) and 1 or GuardClassCnt)
        self.HelMemDesc = tostring((self.bMuren or self.bOnDirectorPannel) and 1 or RecoverClassCnt)
        self.AtkMemDesc = tostring((self.bMuren or self.bOnDirectorPannel) and 1 or AttackClassCnt)
        self.bPassTeamNum = RltInfo.IsPassMem

        local ReqLv = self.PWorldRequireLv
        if self.TaskType == SceneMode.SceneModeUnlimited then
            self.LvReqDesc = string.sformat(LSTR(1320207), ReqLv)
        elseif self.EntTy == ProtoCommon.ScenePoolType.ScenePoolRandom then
            self.LvReqDesc = string.sformat(LSTR(1320078), ReqLv)
        else
            self.LvReqDesc = string.sformat(LSTR(1320206), ReqLv, self.SyncMaxLv, self.SyncMaxLv)
        end
        self.bPassJoinLevel = RltInfo.IsPassLv
        self.LvReqDesc = GetColorReqDesc(self.LvReqDesc, self.bPassJoinLevel)

        local SyncEquipLv = self.EquipLvSyncReq or 0
        local ReqEquipLv = self.PWorldRequireEquipLv
        self.bPassEquipLv = RltInfo.IsPassEquipLv
        if SyncEquipLv > 0 then
            self.EquipReqDesc = PWorldHelper.pformat("PWOLRD_EQUILP_LIMIT_FULL", ReqEquipLv, SyncEquipLv)
        else
            self.EquipReqDesc = PWorldHelper.pformat("PWORLD_EQUIP_LIMIT", ReqEquipLv)
        end
        self.EquipReqDesc = GetColorReqDesc(self.EquipReqDesc, self.bPassEquipLv)
    end
end

-- 设置可用
function PWorldEntDetailVM:UpdateSettingModeEnable()
    if PWorldEntUtil.IsDailyRandom(self.EntTy) then
        self.EnableSettingModeNormal = true
        self.EnableSettingModeChallenge = false
        self.EnableSettingModeUnlimited = false
        self.EnableSettingModeExplore = false
        self.EnableSettingModeChocoboRank = false
        self.EnableSettingModeRoom = false
    elseif self.EntTy == ScenePoolType.ScenePoolChocobo then
        self.EnableSettingModeNormal = false
        self.EnableSettingModeChallenge = false
        self.EnableSettingModeUnlimited = false
        self.EnableSettingModeExplore = false
        self.EnableSettingModeChocoboRank = true
        self.EnableSettingModeRoom = true
    else
        if not self.EntCfg then
            return
        end
        local Cfg = self.EntCfg
        self.EnableSettingModeNormal = Cfg.HasNormal > 0
        self.EnableSettingModeChallenge = Cfg.HasChallenge > 0
        self.EnableSettingModeUnlimited = Cfg.HasUnlimited > 0
        self.EnableSettingModeExplore = Cfg.HasExplore > 0
        self.EnableSettingModeChocoboRank = false
        self.EnableSettingModeRoom = false
    end

    local OpsData = {}
    if self.EnableSettingModeNormal then
       table.insert(OpsData, {Op = 1,})
    end
    if self.EnableSettingModeChallenge then
        table.insert(OpsData, {Op = 2,})
    end
    if self.EnableSettingModeUnlimited then
        table.insert(OpsData, {Op = 3,})
    end
    if self.EnableSettingModeChocoboRank then
        table.insert(OpsData, {Op = 4,})
    end
    if self.EnableSettingModeRoom then
        table.insert(OpsData, {Op = 5,})
    end

    self.bShowDifficultyDetail = self.bShowDifficultyDetail and #OpsData > 0
    self.DifficultyVMs:UpdateByValues(OpsData)
end

-- 切换时检查锁定和相关描述&是否可以参加
function PWorldEntDetailVM:UpdatePreCheck()
    if not self.EntCfg then
        return
    end

    self.IsPreCheckPass, self.PreCheckFailedReasons = PWorldEntUtil.PreCheck(self.CurEntID, self.EntTy)
    self:UpdModePanelVisible()
    self:UpdJoinBtn()
end

function PWorldEntDetailVM:UpdateForbidText()
    local Desc = LSTR(1320006)
    if PWorldEntUtil.IsCrystalline(self.SubType) then
        if not self.IsPreCheckPass and self.PreCheckFailedReasons then
            local FailReasonTypeList = { "IsOpen", "IsPassMem", "IsPassLv", "IsPassEquipLv", "IsPassTime" }
            local FailReasonMap = {
                IsOpen = LSTR(1320210),
                IsPassMem = LSTR(1320213),
                IsPassLv = LSTR(1320042),
                IsPassEquipLv = LSTR(1320043),
                IsPassTime = LSTR(1320124),
            }
            for _, Reason in ipairs(FailReasonTypeList) do
                if self.PreCheckFailedReasons[Reason] ~= true then
                    Desc = FailReasonMap[Reason]
                    break
                end
            end
        end
    else
        if PWorldEntUtil.IsEntDirector(self.CurEntID, self.EntTy) and
            not _G.MentorMgr:VerifyMentorIdentity(MentorDefine.GuideType.GUIDE_TYPE_FIGHT) then
                Desc = ""
        end

        if _G.PWorldMatchMgr:IsEntMatching(self.CurEntID, self.EntTy) then
            Desc = ""
        end

        if not self.IsPreCheckPass and self.PreCheckFailedReasons then
            for _, v in ipairs({{"IsPassMem", "HINT_JOIN_PROF_NOT_PASS"},{"IsPassLv", "HINT_JOIN_LEVEL_NOT_PASS"}, {"IsPassEquipLv", "HINT_JOIN_EQUIP_NOT_PASS"}}) do
                if self.PreCheckFailedReasons[v[1]] ~= true then
                Desc = PWorldHelper.GetPWorldText(v[2])
                break
                end
            end
        end

        if PWorldEntUtil.IsPrettyHardPWorld(self.CurEntID) and not PWorldEntUtil.IsPrettyHardEntranceJoinable(self.CurEntID) then
            Desc = _G.LSTR(1320233)
        end
    end
    self.ForbidText = Desc
end

-- 匹配
function PWorldEntDetailVM:UpdMatch()
    local PWorldMatchMgr = _G.PWorldMatchMgr
    self.IsMatching = PWorldMatchMgr:IsPWorldMatching(self.CurEntID, self.SubType)
    for _, Item in pairs(self.PWorldEntList:GetItems()) do
        Item:UpdMatch()
    end

    self:UpdModePanelVisible()
    self:UpdJoinBtn()

    if self.IsMatching then
        local ResIDs = {}
        for _, v in ipairs(self.PWorldEntList:GetItems()) do
            if v.ID then
                table.insert(ResIDs, v.ID)
            end
        end
    end

    self:UpdateMatchTime()
end

function PWorldEntDetailVM:UpdateMatchTime()
    local EntID = self.CurEntID
    if self.SubType == ScenePoolType.ScenePoolChocoboRandomTrack then
        EntID = 0
    end
    
    local MatchTimeData = _G.PWorldMatchMgr:GetMatchTimeDataElement(EntID)
    self.CurMatchEstTimeDesc = MatchTimeData and MatchTimeData.EstDesc or _G.LSTR(1320018)
    if MatchTimeData then
         self.CancelText = PWorldHelper.pformat("PWORLD_MATCH_CANCEL_REMAIN", LocalizationUtil.GetCountdownTimeForShortTime(MatchTimeData.TotalWaitTime, "mm:ss"))
    else
        self.CancelText = LSTR(1320007)
    end
end

-- 引导：首次访问弹出Tips
function PWorldEntDetailVM:CheckVisited()
    local Visited = PWorldEntMgr:HasPWEVisited(self.CurEntID)
    if not Visited then
        PWorldEntMgr:SetPWEVisited(self.CurEntID)
    end
end

-- 指导者
function PWorldEntDetailVM:CheckDirector()
    self.bOnDirectorPannel = PWorldEntUtil.IsEntDirector(self.CurEntID, self.EntTy)
    self.bShowNavDirectorTips = false

    self.bShowDirectorNavBtn = false
    local bFightDirector = _G.MentorMgr:VerifyMentorIdentity(MentorDefine.GuideType.GUIDE_TYPE_FIGHT)
    self.bShowDirectorUnReg = self.bOnDirectorPannel and not bFightDirector
    if self.bOnDirectorPannel then
        local DirectorCatList = {
            {Name = LSTR(1320024), IDList={}, bPreConditonFinished=true},
            {Name = LSTR(1320025), IDList={}, bPreConditonFinished=false},
        }
        local PolUtil = require("Game/PWorld/Entrance/Policy/PWorldEntPolUtil")
        local RandList = PolUtil.GetDRPoolList(self.CurEntID)
        local SceneEnterCfg = require("TableCfg/SceneEnterCfg")
        for _, PWorldID in ipairs(RandList) do
            local ECfg = SceneEnterCfg:FindCfgByKey(PWorldID)
            if ECfg then
                if PolUtil.HasPreQuestFinish(ECfg.PreQuestID) then
                    local PCfg = require('TableCfg/PworldCfg'):FindCfgByKey(PWorldID)
                    if PCfg then
                        if not PWorldEntUtil.IsEntancePass(PCfg) then
                            table.insert(DirectorCatList[1].IDList, PWorldID)
                        end
                    else
                        _G.FLOG_ERROR("invalid pworld id: %s", tostring(PWorldID))
                    end
                else
                    table.insert(DirectorCatList[2].IDList, PWorldID)
                end
            else
                _G.FLOG_ERROR("no SceneEnterCfg rec: %s", tostring(PWorldID))
            end
        end
        self.DirectorPworldListVMs:UpdateByValues(DirectorCatList)
        self.bShowDirectorNavBtn = #RandList > 0 and (#DirectorCatList[1].IDList + #DirectorCatList[2].IDList) > 0 and bFightDirector
    end
end

function PWorldEntDetailVM:CheckEncourage()
    if self.CurEntID == 0 or self.CurEntID == nil then
        self.IsShowBtnEncourage = false
        return
    end

    local SceneEncourageCfg = require("TableCfg/SceneEncourageCfg")
    self.IsShowBtnEncourage = SceneEncourageCfg:FindCfgByKey(self.CurEntID) ~= nil
end

-------------------------------------------------------------------------------------------------------
---@see OpSelectAndSet

-- 副本类型选择更新

function PWorldEntDetailVM:UpdPWEList()
    self.PWorldsData = PWorldEntUtil.GetPWordTreeViewCfg(self.EntTy) or {}
    local Data = {}
    for _, PWorldsDataValue in pairs(self.PWorldsData or {}) do
        for _, ID in pairs(PWorldsDataValue.IDs) do
            table.insert(Data, {
                ID = ID,
                Type = PWorldsDataValue.Type
            })
        end
    end
    self.PWorldEntList:UpdateByValues(Data)
end

function PWorldEntDetailVM:SetSelectType(Type)
    if Type == nil then
        return
    end

    self.LastEntType = self.EntTy
    self:SetEntTy(Type)
    self:UpdatePWorldType()
    self:UpdPWEList()

    self.CurEntIdx = 0
    self:SeletectPWorldByIndex(self:GetDefaultEntSelectIndex(self.EntTy))
    self.IsExpandAll = true
    self:UpdSettingBtnVisible()
    self:UpdateRecruit()
    self.bTextRewardsVisible = self.EntTy ~= ScenePoolType.ScenePoolRandom
end

function PWorldEntDetailVM:SetEntTy(Type)
    self.EntTy = Type
    self:SetMuren(Type == ProtoCommon.ScenePoolType.ScenePoolMuRen)
end

function PWorldEntDetailVM:SetMuren(Value)
    self.bMuren = Value
    self:UpdateExtraCondition()
end

---@private
function PWorldEntDetailVM:GetTaskBtnVisible(EntType)
    if PWorldEntUtil.IsCrystalline(self.SubType) then
        return false
    else
        return EntType ~= ScenePoolType.ScenePoolRandom and not self.bMuren
    end
end

---@private
function PWorldEntDetailVM:GetDefaultEntSelectIndex(EntTy)
    if EntTy == nil or self.CachedEntSelectInfo == nil then
       return 1 
    end

    return self:FindSelectIndexByEntID(self.CachedEntSelectInfo[EntTy]) or 1
end

function PWorldEntDetailVM:SelecteLastEntType()
    self:SetSelectType(self.LastEntType)
end

function PWorldEntDetailVM:Flush()
    local Idx = self.CurEntIdx
    self.CurEntIdx = nil
    self:UpdPWEList()
    self:SeletectPWorldByIndex(Idx)
end

function PWorldEntDetailVM:SetCurMatchCnt(V)
    self.CurMatchCnt = V
end

-- 副本入口选择
function PWorldEntDetailVM:SetSelectedPWorldID(ID)
    if ID == nil then
        return
    end

    if (not self.PWorldsData) or (not self.PWorldsData[Cate]) or (not self.PWorldsData[Cate].IDs) then
        return
    end

    self:SeletectPWorldByIndex(self:FindSelectIndexByEntID(ID))
end

---@private
---@return number | nil
function PWorldEntDetailVM:FindSelectIndexByEntID(EntID)
    local Idx = 0
    for _, PWorldsDataValue in pairs(self.PWorldsData or {}) do
        for K, V in pairs(PWorldsDataValue.IDs) do
            Idx = Idx + 1
            if V == EntID then
                return Idx
            end
        end
    end
    return 1
end

function PWorldEntDetailVM:SeletectPWorldByIndex(InIndex)
    if InIndex == nil then
        return
    end

    if (not self.PWorldsData) or (not self.PWorldsData[Cate]) or (not self.PWorldsData[Cate].IDs) then
        return
    end

    self.CurEntIdx = InIndex
    local EntID = 0
    local Index = 0
    local SubType = 0
    for _, PWorldsDataValue in pairs(self.PWorldsData) do
        for _, Value in pairs(PWorldsDataValue.IDs) do
            Index = Index + 1
            if Index == InIndex then
                EntID = Value
                SubType = PWorldsDataValue.Type
                break
            end
        end
    end

    if EntID ~= 0 and EntID then
        self.CurEntVM = self.PWorldEntList:Get(self.CurEntIdx)
    end
    self:SetCurEntID(EntID, SubType)
end

function PWorldEntDetailVM:SetCurEntID(ID, InSubType)
    local bChanged = ID ~= self.CurEntID or self.SubType ~= InSubType
    self.CurEntID = ID
    self.SubType = InSubType
    if bChanged and ID and ID ~= 0 then
        self:UpdateVM()
    end

    self:UpdateLackProf()
    self:CheckEncourage()
    self:UpdateExtraCondition()
end

function PWorldEntDetailVM:UpdateLackProf()
    self.LackProf = _G.PWorldMatchMgr:GetLackProfFunc(self.CurEntID)
end

-- 副本选项
local TaskIdx2Type = PWorldQuestDefine.TaskIdx2Type

function PWorldEntDetailVM:SetTaskIdx(Idx)
    self.TaskOp = Idx
    self.TaskType = self:ToTaskType(Idx)
    PWorldEntMgr:SetTaskOpCache(self.CurEntID, Idx)
    self:UpdModePanelVisible()
    self:CheckChocoboMatchRequirementPrompt()
    self:UpdateJoinRelatedInfo()
end

function PWorldEntDetailVM:UpdateJoinRelatedInfo()
    self:UpdateEntInfo()
    self:UpdateRequireDesc()
    self:UpdatePreCheck()
    self:UpdateForbidText()

    for _, Item in pairs(self.PWorldEntList:GetItems()) do
        Item:UpdLock()
    end
end

function PWorldEntDetailVM:ToTaskType(Idx)
    return TaskIdx2Type[Idx] or SceneMode.SceneModeNormal
end

-- 奖励
function PWorldEntDetailVM:SetSelectedRewardIdx(V)
    self.CurRewardIdx = V
    self:SetRewardTipsVM()
end

function PWorldEntDetailVM:SetRewardTipsVM()
    local VM = self.RewardVMs:Get(self.CurRewardIdx)
    if not VM then
        return
    end
    local ResID = VM.ResID
    local Params = {
        ResID = ResID
    }
    self.RewardTipsVM:UpdateVM(Params)
end

function PWorldEntDetailVM:SetCommCloseMaskVisible(V)
    self.IsCommCloseMaskVisible = V
end

function PWorldEntDetailVM:UpdModePanelVisible()
    self.IsModePanelVisible = (self.TaskType ~= SceneMode.SceneModeNormal) and (not self.Matching) and self.IsPreCheckPass
end

function PWorldEntDetailVM:CheckChocoboMatchRequirementPrompt()
    if self.TaskType == PWorldQuestDefine.ClientSceneMode.SceneModeChocboRank then
        self.IsShowChocoboMatchRequirementPrompt = _G.TeamMgr:IsInTeam()
        -- LSTR string: 段位赛：仅限单人状态下参与
        self.ChocoboMatchRequirementDes = LSTR(430010)
    elseif self.TaskType == PWorldQuestDefine.ClientSceneMode.SceneModeChocoboRoom then
        self.IsShowChocoboMatchRequirementPrompt = not _G.TeamMgr:IsInTeam()
        -- LSTR string: 开房间：仅限组队状态下参与
        self.ChocoboMatchRequirementDes = LSTR(430011)
    end
end

-- 根据副本类型切换模式选择按钮的可视性
function PWorldEntDetailVM:UpdSettingBtnVisible()
    self.IsTaskBtnVisible = self:GetTaskBtnVisible(self.EntTy)--not PWorldEntUtil.IsDailyRandom(self.EntTy) and not self.bMuren
end

function PWorldEntDetailVM:UpdJoinBtn()
    self.IsShowCancelMatchBtn = self.IsMatching and not (_G.TeamMgr:IsInTeam() and not _G.TeamMgr:IsCaptain())
    self.IsJoinBtnVisible = (not self.HasPunished) and (not self.IsShowCancelMatchBtn) 
    self.IsJoinBtnEnable = self.IsPreCheckPass and (not self.IsMatching)
    self.JoinBtnText = self.IsMatching and _G.LSTR(1320008) or _G.LSTR(1320009)

    local Params = {
        IsJoinBtnEnable = self.IsJoinBtnEnable, 
        PreCheckFailedReasons = self.PreCheckFailedReasons
    }
    _G.EventMgr:SendEvent(_G.EventID.PWorldUpdatePreCheck, Params)
end

function PWorldEntDetailVM:CheckExtraDescription()
    local ExtraDescription = ""
    if PWorldEntUtil.IsCrystalline(self.SubType) then
        local IsInEventTime, EventTimeData, CurIntervalData, NextIntervalData = self.Policy:CheckIsInEventTime(self.CurEntID)
        local EventTimeString = self:GetCrystallineEventTimeInfo(EventTimeData)

        if PWorldEntUtil.IsCrystallineExercise(self.SubType) or PWorldEntUtil.IsCrystallineRank(self.SubType) then
            local CurMapString, NextMapString = self:GetCrystallineMapTimeInfo(IsInEventTime, CurIntervalData, NextIntervalData)
            ExtraDescription = string.format(LSTR(1320121), CurMapString, NextMapString, EventTimeString)
        elseif PWorldEntUtil.IsCrystallineCustom(self.SubType) then
            ExtraDescription = EventTimeString
        end
    end
    return ExtraDescription
end

function PWorldEntDetailVM:GetCrystallineMapTimeInfo(IsInEventTime, CurIntervalData, NextIntervalData)
    local CurMapString
    if IsInEventTime then
        -- 00:00是新一天的第一秒，但是策划希望显示24:00，所以在展示上对数字做处理，接口里实际返回时间还是新一天的00:00，只对EndTime处理是因为开始时间不会是24:00，只有结束时间要这样显示
        if CurIntervalData.EndTime.hour == 0 and CurIntervalData.EndTime.min == 0 and CurIntervalData.EndTime.sec == 0 then
            CurIntervalData.EndTime.hour = 24
        end
        local CurMapStartTime = string.format(LSTR(1320123), CurIntervalData.StartTime.hour, CurIntervalData.StartTime.min)
        local CurMapEndTime = string.format(LSTR(1320123), CurIntervalData.EndTime.hour, CurIntervalData.EndTime.min)
        CurMapString = string.format(LSTR(1320118), CurIntervalData.MapName, CurMapStartTime, CurMapEndTime)
    else
        CurMapString = LSTR(1320122)
    end

    -- 00:00是新一天的第一秒，但是策划希望显示24:00，所以在展示上对数字做处理，接口里实际返回时间还是新一天的00:00，只对EndTime处理是因为开始时间不会是24:00，只有结束时间要这样显示
    if NextIntervalData.EndTime.hour == 0 and NextIntervalData.EndTime.min == 0 and NextIntervalData.EndTime.sec == 0 then
        NextIntervalData.EndTime.hour = 24
    end
    local NextMapStartTime = string.format(LSTR(1320123), NextIntervalData.StartTime.hour, NextIntervalData.StartTime.min)
    local NextMapEndTime = string.format(LSTR(1320123), NextIntervalData.EndTime.hour, NextIntervalData.EndTime.min)
    local NextMapString = string.format(LSTR(1320119), NextIntervalData.MapName, NextMapStartTime, NextMapEndTime)

    return CurMapString, NextMapString
end

function PWorldEntDetailVM:GetCrystallineEventTimeInfo(EventTimeData)
    if EventTimeData == nil or EventTimeData.StartTime == nil or EventTimeData.EndTime == nil then return "" end
    local EventTimeString = ""
    local StartTimeHour = EventTimeData.StartTime.hour
    local StartTimeMinute = EventTimeData.StartTime.min
    local EndTimeHour = EventTimeData.EndTime.hour
    local EndTimeMinute = EventTimeData.EndTime.min

    -- 00:00是新一天的第一秒，但是策划希望显示24:00，所以在展示上对数字做处理，接口里实际返回时间还是新一天的00:00，只对EndTime处理是因为开始时间不会是24:00，只有结束时间要这样显示
    if EventTimeData.EndTime.hour == 0 and EventTimeData.EndTime.hour == 0 and EventTimeData.EndTime.hour == 0 then
        EndTimeHour = 24
    end
    
    local StartTimeString = string.format(LSTR(1320123), StartTimeHour, StartTimeMinute)
    local EndTimeString = string.format(LSTR(1320123), EndTimeHour, EndTimeMinute)
    if EventTimeData.IsCrossDay then
        EventTimeString = string.format(LSTR(1320120), StartTimeString, EndTimeString)
    else
        EventTimeString = string.format(LSTR(1320136), StartTimeString, EndTimeString)
    end
    return EventTimeString
end

-------------------------------------------------------------------------------------------------------
---@see 稀缺职业消息订阅

---@deprecated
function PWorldEntDetailVM:UnSubLackProfUpd()
    -- _G.PWorldMatchMgr:UnSubLackProfUpd(self)
end

function PWorldEntDetailVM:UpdLackProfUpd()
    -- if not PWorldEntUtil.IsDailyRandom(self.EntTy) then
    --     self:UnSubLackProfUpd()
    -- else
    --     local List = {self.CurEntID}
    --     _G.PWorldMatchMgr:SubLackProfUpd(self, List)
    -- end
end

function PWorldEntDetailVM:SetExtraCondTitle(Value)
    self.ExtraCondTitle = Value
end

function PWorldEntDetailVM:SetExtraCondDetail(Value)
    self.ExtraCondDetail = Value
end

function PWorldEntDetailVM:UpdateExtraCondition()
    local Title
    local Content
    local bPassExtraCondition = true
    if self.bMuren then
        Title = LSTR(1320216)
        Content = LSTR(1320217)
    elseif PWorldEntUtil.IsPrettyHardPWorld(self.CurEntID) then
        local OK, EntID = PWorldEntUtil.IsPrettyHardEntranceJoinable(self.CurEntID)
        if not OK then
            Title = _G.LSTR(1320234)
            local Cfg = require("TableCfg/PworldCfg"):FindCfgByKey(EntID)
            Content = GetColorReqDesc(string.sformat(_G.LSTR(1320235), Cfg and Cfg.PWorldName or ""))
        end
        bPassExtraCondition = OK
    end

    self.bPassExtraCondition = bPassExtraCondition
    self:SetExtraCondTitle(Title)
    self:SetExtraCondDetail(Content)
end

function PWorldEntDetailVM:GetEntranceCfgAttr(AttrName, DefaultValue)
    if self.EntCfg and AttrName then
        return self.EntCfg[AttrName] or DefaultValue
    end

    return DefaultValue
end

return PWorldEntDetailVM
