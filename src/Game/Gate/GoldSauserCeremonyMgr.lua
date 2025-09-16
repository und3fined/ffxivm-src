--[[
Author: lightpaw_Leo
Date: 2025-02-12 9:02:12
Description: 金蝶庆典相关
--]]
local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCommon = require("Protocol/ProtoCommon")
local GoldSaucerBlessingDefine = require("Game/GoldSaucerMiniGame/GoldSaucerBlessingDefine")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local TimeUtil = require("Utils/TimeUtil")
local FairyBlessedTimeCfg = require("TableCfg/FairyBlessedTimeCfg")
local CS_CMD = ProtoCS.CS_CMD
local EffectUtil = require("Utils/EffectUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local GoldSauserMainPanelMainVM = require("Game/GoldSauserMainPanel/VM/GoldSauserMainPanelMainVM")
local ActivityCfg = require("TableCfg/ActivityCfg")
local GoldsauserCeremonyCfg = require("TableCfg/GoldsauserCeremonyCfg")
local LocalizationUtil = require("Utils/LocalizationUtil")
local EBlessingState = GoldSaucerBlessingDefine.EBlessingState
local PWorldMgr = _G.PWorldMgr
local EventID = _G.EventID
local LSTR = _G.LSTR
local MapDynType = ProtoCommon.MapDynType
local EffectType = MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
local SecDef = 60

local ModuleOpenMgr

---@class GoldSauserCeremonyMgr : MgrBase
local GoldSauserCeremonyMgr = LuaClass(MgrBase)

function GoldSauserCeremonyMgr:OnInit()
    ModuleOpenMgr = _G.ModuleOpenMgr
    self.JDMapID = 12060
    self.CereKey = 0 -- 当前生效的活动配置Key
    self:SetTheLatestActivityID()
end

function GoldSauserCeremonyMgr:Reset()
end

function GoldSauserCeremonyMgr:OnBegin()
    self.bHaveShowCeremonyMgrThisLogin = false -- 本次登录是否显示过金碟庆典准备提示
end

function GoldSauserCeremonyMgr:OnEnd()
    self.bHaveShowCeremonyMgrThisLogin = nil
end

function GoldSauserCeremonyMgr:OnShutdown()
 
end

function GoldSauserCeremonyMgr:OnRegisterGameEvent()
	self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)
	self:RegisterGameEvent(EventID.ModuleOpenNotify, self.OnModuleOpenNotify) --系统解锁
end

function GoldSauserCeremonyMgr:OnGameEventLoginRes(Params)
	if not ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDGoldSauserMain) then
        return
    end
    if _G.DemoMajorType ~= 0 then
        return
    end
	self:CheckIsInCeramonyAndSend()
end


function GoldSauserCeremonyMgr:OnModuleOpenNotify(InModuleID)
    if InModuleID == ProtoCommon.ModuleID.ModuleIDGoldSauserMain then
        self:CheckIsInCeramonyAndSend()
    end
end

function GoldSauserCeremonyMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_GOLD_SAUSER, ProtoCS.CS_GOLD_SAUSER_CMD.CS_GOLD_SAUSER_CMD_REPORT_CELEBRATION_BUFF, self.OnGetCeremonyeRsp)
end

function GoldSauserCeremonyMgr:SetTheLatestActivityID()
    local CereCfgs = GoldsauserCeremonyCfg:FindAllCfg("1=1")
    if not CereCfgs then
        return
    end

    local ListToSort = {}
    for _, CereCfg in ipairs(CereCfgs) do
        local ID = CereCfg.ID
        local ActID = CereCfg.ActivityID
        local ActCfg = ActivityCfg:FindCfgByKey(ActID)
        if ActCfg then
            local ChinaTimeInfo = ActCfg.ChinaActivityTime
            if ChinaTimeInfo then
                local StartTimeStr = ChinaTimeInfo.StartTime or ""
                local StartTime = TimeUtil.GetTimeFromString(StartTimeStr)
                local EndTimeStr = ChinaTimeInfo.EndTime or ""
                local EndTime = TimeUtil.GetTimeFromString(EndTimeStr)
                if StartTime and type(StartTime) == "number" then
                    table.insert(ListToSort, {ID = ID, StartTime = StartTime, EndTime = EndTime})
                end
            end
        end
    end
    table.sort(ListToSort, function(A, B) 
        return A.StartTime > B.StartTime
    end)
    local LastIndex = 1
    for Index, ActTimeInfo in ipairs(ListToSort) do
        local CurTime = TimeUtil.GetServerLogicTime()
        local ActStartTime = ActTimeInfo.StartTime
        local ActEndTime = ActTimeInfo.EndTime
        if CurTime >= ActStartTime then
            if CurTime < ActEndTime then
                self.CereKey = ActTimeInfo.ID
                return
            else
                break
            end
        end
        LastIndex = Index
    end
    local SortedTarget = ListToSort[LastIndex]
    if SortedTarget then
        self.CereKey = SortedTarget.ID or 0
    end
end

--- 在线状态下在活动信息变化的时候更新激活的金碟庆典
---@param ActivityID number@活动系统表id
function GoldSauserCeremonyMgr:CheckTheNewActiveCereKey(ActivityID)
    local ActCfg = self:GetCurActiveActivityCfg()
    if not ActCfg then
        return
    end
    if ActivityID ~= ActCfg.ActivityID then
        return
    end
    self:SetTheLatestActivityID()
end

--- @type 请求开启金碟庆典
function GoldSauserCeremonyMgr:SendMsgCheckCeremonyReq()
    local MsgID = CS_CMD.CS_CMD_GOLD_SAUSER
    local SubMsgID = ProtoCS.CS_GOLD_SAUSER_CMD.CS_GOLD_SAUSER_CMD_REPORT_CELEBRATION_BUFF
    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--- @type 开启金碟庆典回包
function GoldSauserCeremonyMgr:OnGetCeremonyeRsp(MsgBody)
    if MsgBody == nil then
        return
    end
    FLOG_INFO("GoldSauserCeremony is Begining!")
    -- MsgTipsUtil.ShowActiveTips("金碟庆典已开启") -- to delete
   
    self:OnGetCeremonyeInternal()
end

function GoldSauserCeremonyMgr:OnGetCeremonyeInternal()
    local GoldCeremonyCfg = self.GoldCeremonyCfg
    if not GoldCeremonyCfg then
        return
    end
  
end

--- 获取当前生效的活动配置
function GoldSauserCeremonyMgr:GetCurActiveActivityCfg()
    local CereKey = self.CereKey
    if not CereKey or type(CereKey) ~= "number" then
        return
    end
    local CereCfg = GoldsauserCeremonyCfg:FindCfgByKey(CereKey)
    if not CereCfg then
        return
    end
    return ActivityCfg:FindCfgByKey(CereCfg.ActivityID)
end

--- @type 获得距离庆典开始还有多少秒
function GoldSauserCeremonyMgr:GetReaminSecToCeremony()
    local Cfg = self:GetCurActiveActivityCfg()
    if Cfg == nil then
        return
    end
    local ActivityTime = Cfg.ChinaActivityTime
    if not ActivityTime then
        return
    end
    local StartTime = ActivityTime.StartTime or ""
    local StartTimeSec = TimeUtil.GetTimeFromString(StartTime)
    local CurTime = TimeUtil.GetServerLogicTime()
    return StartTimeSec - CurTime
end

--- @type 获得距离庆典结束还有多少秒
function GoldSauserCeremonyMgr:GetReaminSecToCeremonyEnd()
    local Cfg = self:GetCurActiveActivityCfg()
    if Cfg == nil then
        return
    end
    local ActivityTime = Cfg.ChinaActivityTime
    if not ActivityTime then
        return
    end
    local EndTime = ActivityTime.EndTime or ""
    local EndTimeSec = TimeUtil.GetTimeFromString(EndTime)
    local CurTime = TimeUtil.GetServerLogicTime()
    return EndTimeSec - CurTime 
end

--- 获取金碟庆典是否处于准备阶段（开始前24小时）
function GoldSauserCeremonyMgr:IsCeremonyInPrepare()
    local SecToCeremonyStart = self:GetReaminSecToCeremony()
    return SecToCeremonyStart > 0 and SecToCeremonyStart <= 3600 * 24
end

--- 获取金碟庆典是否正在进行中
function GoldSauserCeremonyMgr:IsInCeremony()
    local Cfg = self:GetCurActiveActivityCfg()
    if Cfg == nil then
        return
    end
    local ActivityTime = Cfg.ChinaActivityTime
    if not ActivityTime then
        return
    end
    local CurTime = TimeUtil.GetServerLogicTime()
    local StartTime = ActivityTime.StartTime or ""
    local StartTimeSec = TimeUtil.GetTimeFromString(StartTime)
    local EndTime = ActivityTime.EndTime or ""
    local EndTimeSec = TimeUtil.GetTimeFromString(EndTime)

    return CurTime >= StartTimeSec and CurTime < EndTimeSec
end

--- 接入活动状态变化检查拉取活动信息
---@param ActIDs table@开启活动列表
function GoldSauserCeremonyMgr:CheckSendReq(ActIDs)
    if not ActIDs or not next(ActIDs) then
        return
    end
    local CurActCfg = self:GetCurActiveActivityCfg()
    if not CurActCfg then
        return
    end
   
    local bExist = false
    for _, ActID in ipairs(ActIDs) do
        if ActID == CurActCfg.ActivityID then
            if _G.DemoMajorType == 0 then
                bExist = true
                break
            end
        end
    end

    if bExist then
        self:CheckIsInCeramonyAndSend()
    end
end

--- @type 根据时间推算是否处于活动中
function GoldSauserCeremonyMgr:CheckIsInCeramonyAndSend()
    local Cfg = self:GetCurActiveActivityCfg()
    if Cfg == nil then
        -- FLOG_INFO("Cfg == nil ActivityID = %d", Cfg.ActivityID)
        return
    end
    local StartTimeSec = TimeUtil.GetTimeFromString(Cfg.ChinaActivityTime.StartTime)
    local CurTime = TimeUtil.GetServerLogicTime() --TimeUtil.GetServerTime()
    local EndTimeSec = TimeUtil.GetTimeFromString(Cfg.ChinaActivityTime.EndTime)
    if CurTime >= StartTimeSec and CurTime < EndTimeSec then
        if _G.DemoMajorType == 0 then
            self:SendMsgCheckCeremonyReq()
        end
    end 
end

--- @type 获取金碟主界面倒计时Text文本
function GoldSauserCeremonyMgr:UpdateGoldCeremonyCountDownText()
    local bPrepare = self:IsCeremonyInPrepare()
    local bInCeremony = self:IsInCeremony()
    local Cfg = self:GetCurActiveActivityCfg()
    if Cfg == nil then
        return
    end
    if not bInCeremony and not bPrepare then
        GoldSauserMainPanelMainVM:SetSauserCelebrationInfo(false, false, "", "")
        self:StopUpdateTimeInfo()
        return
    end
    local TopTimeText = ""
    local DownTimeText = ""
    if bPrepare then
        local SecToCeremonyStart = self:GetReaminSecToCeremony()
        local TimeStr = LocalizationUtil.GetCountdownTimeForLongTime(SecToCeremonyStart)
        TopTimeText = string.format(LSTR(350077), TimeStr)
    elseif bInCeremony then
        local SecToCeremonyEnd = self:GetReaminSecToCeremonyEnd()
        local TimeStr = LocalizationUtil.GetCountdownTimeForLongTime(SecToCeremonyEnd)
        TopTimeText = string.format(LSTR(350078), TimeStr)
        DownTimeText = string.format(LSTR(350076), "50%")
    end
    GoldSauserMainPanelMainVM:SetSauserCelebrationInfo(bInCeremony, bPrepare or bInCeremony, TopTimeText, DownTimeText)
end

--- @type 缓存日期Text XX/YY-XX/YY
function GoldSauserCeremonyMgr:CachMouthDayData()
    local Cfg = self:GetCurActiveActivityCfg()
    if Cfg == nil then
        return
    end
    local StartDayAndTime = string.split(Cfg.ChinaActivityTime.StartTime, " ")
    local StartYearMouthAndDay = string.split(StartDayAndTime[1], "-")

    local EndDayAndTime = string.split(Cfg.ChinaActivityTime.EndTime, " ")
    local EndYearMouthAndDay = string.split(EndDayAndTime[1], "-")
    self.CeremonyTimeText = string.format("%s/%s-%s/%s", StartYearMouthAndDay[2], StartYearMouthAndDay[3], EndYearMouthAndDay[2], EndYearMouthAndDay[3])
end

--- @type 是否需要刷新时间信息
function GoldSauserCeremonyMgr:IsNeedUpdateTimeInfo()
    local bPrepare = self:IsCeremonyInPrepare()
    local bInCeremony = self:IsInCeremony()
    return bPrepare or bInCeremony
end

--- @type 尝试刷新刷新时间信息
function GoldSauserCeremonyMgr:TryUpdateTimeInfo()
    if self:IsNeedUpdateTimeInfo() then
        self.TimeInfoTimer = self:RegisterTimer(self.UpdateGoldCeremonyCountDownText, 0, 0.2, 0)
    else
        GoldSauserMainPanelMainVM:SetSauserCelebrationInfo(false, false, "", "")
    end
end

--- @type 停止刷新刷新刷新时间信息
function GoldSauserCeremonyMgr:StopUpdateTimeInfo()
    if self.TimeInfoTimer ~= nil then
        self:UnRegisterTimer(self.TimeInfoTimer)
        self.TimeInfoTimer = nil
    end
end

return GoldSauserCeremonyMgr
