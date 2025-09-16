local LuaClass = require("Core/LuaClass")
local UIViewModel = require("UI/UIViewModel")
local SceneEnterCfg = require("TableCfg/SceneEnterCfg")

local PWorldQuestVM = LuaClass(UIViewModel)
local PworldCfg = require("TableCfg/PworldCfg")
local SceneDailyRandomTaskPoolCfg = require("TableCfg/SceneDailyRandomTaskPoolCfg")
local PWorldEntUtil = require("Game/PWorld/Entrance/PWorldEntUtil")

local ProtoCommon = require("Protocol/ProtoCommon")
local PWorldEntDefine = require("Game/PWorld/Entrance/PWorldEntDefine")
local PWorldQuestDefine = require("Game/PWorld/Quest/PWorldQuestDefine")
local TeamDefine = require("Game/Team/TeamDefine")
local SceneModeDef = ProtoCommon.SceneMode

local PWorldQuestMgr
local PWorldMgr
local PWorldTeamMgr


function PWorldQuestVM:Ctor()
    self.CanGiveUp = false
    self.CanSupplement = false
    self.IsShowSup = false

    self.CanExit = false
    self:SetCanExpel(true)

    self.PWorldID = nil
    self.Mode = 0

    self.IsSuppling = false
    self.IsEntourageMode = false
    self.FuncAlpha = 1
end

function PWorldQuestVM:OnInit()
end

function PWorldQuestVM:OnBegin()
    PWorldQuestMgr = _G.PWorldQuestMgr
    PWorldMgr = _G.PWorldMgr
    PWorldTeamMgr = _G.PWorldTeamMgr
end

function PWorldQuestVM:OnEnd()
end

function PWorldQuestVM:OnShutdown()
end

function PWorldQuestVM:UpdateVM()
    self.PWorldID = PWorldMgr:GetCurrPWorldResID()
    if self.PWorldID then
        local PWCfg = PworldCfg:FindCfgByKey(self.PWorldID)
        if PWCfg then
            --
        else
            _G.FLOG_ERROR("PWorldQuestVM:UpdateVM PWCfg = nil PWorldID = " .. tostring(self.PWorldID) )
        end
    end

    self.Mode = PWorldMgr:GetMode() or SceneModeDef.SceneModeNormal

    self:UpdateIsEntourageMode()
    self:UpdateGiveUp()
    self:UpdateExile()
    self:UpdateExit()
    self:UpdateSupplement()
end

-- 由 QuestMenuView 驱动的 QuestMgr 驱动
function PWorldQuestVM:OnTimer()
    self:UpdateGiveUp()
    self:UpdateExit()
    self:UpdateExile()
    self:UpdateSupplement()
end

function PWorldQuestVM:UpdateIsEntourageMode()
    local Mode = PWorldMgr:GetMode()
    self.IsEntourageMode = Mode == SceneModeDef.SceneModeStory
    self.FuncAlpha = self.IsEntourageMode and 0.5 or 1
end

function PWorldQuestVM:UpdateGiveUp()
    if self.IsEntourageMode then
        self.CanGiveUp = false
        return
    end

    if #(_G.PWorldTeamMgr.MemberList or {}) <= 1 then
        self.CanGiveUp = false
        return 
     end

    local Mode = PWorldMgr:GetMode()
    if Mode == SceneModeDef.SceneModeUnlimited then
        self.CanGiveUp = true
        return
    end

    if PWorldMgr.IsFinished then
        self.CanGiveUp = false
        return
    end

    if self:IsInMuren() then
        self.CanGiveUp = false
        return
    end

    if _G.PWorldTeamMgr:IsVoting() then
        self.CanGiveUp = false
        return
    end

    local Delta = PWorldMgr:GetDuringTime()
    local Inv = PWorldQuestDefine.GiveUpInv()
    self.CanGiveUp = Delta > Inv
end

function PWorldQuestVM:UpdateExile()
    if self.IsEntourageMode then
        self:SetCanExpel(false)
        return
    end

    local Mode = PWorldMgr:GetMode()
    if Mode == SceneModeDef.SceneModeUnlimited then
        self:SetCanExpel(false)
        return
    end

    if PWorldMgr.IsFinished then
        self:SetCanExpel(false)
        return
    end

    if not PWorldMgr:IsFromMatch() then
        self:SetCanExpel(false)
        return
    end

    if self:IsInMuren() then
        self:SetCanExpel(false)
        return
    end

    if #(_G.PWorldTeamMgr.MemberList or {}) <= 1 then
        self:SetCanExpel(false)
        return 
     end

     if _G.PWorldTeamVM:GetMatchMemberCount() == 0 then
        self:SetCanExpel(false)
        return 
     end

    if _G.PWorldTeamMgr:IsVoting() then
        self:SetCanExpel(false)
        return
    end

    local Delta = PWorldMgr:GetDuringTime()
    local Inv = PWorldQuestDefine.VoteExileInv()
    local TimeOK = Delta >= Inv
    self:SetCanExpel(TimeOK)
end

function PWorldQuestVM:SetCanExpel(Value)
    self.bCanExpel = Value
end

function PWorldQuestVM:UpdateExit()
    local IsFromMatch = PWorldMgr:IsFromMatch() or false
    local HasMemExited = PWorldTeamMgr.HasMemExited
    if IsFromMatch then
        self.CanExit = HasMemExited
    else
        local Mode = PWorldMgr:GetMode()
        if Mode == SceneModeDef.SceneModeUnlimited or
            Mode == SceneModeDef.SceneModeChallenge or
            Mode == SceneModeDef.SceneModeStory then
                self.CanExit = true
        else
            if HasMemExited then
                self.CanExit = true
            -- 非日随本
            elseif not _G.PWorldMgr.IsDailyRandom then
                self.CanExit = true
            else
                local Delta = PWorldMgr:GetDuringTime()
                local Inv = PWorldQuestDefine.ExitInv()
                local TimeOK = Delta >= Inv
                self.CanExit = TimeOK
            end
        end
    end

    if self:IsInMuren() then
        self.CanExit = true
    end
end

function PWorldQuestVM:UpdateSupplement()
    self:UpdateSupplementInner()
    self.IsShowSup = self.CanSupplement or _G.PWorldTeamVM.IsSupplementing
end

function PWorldQuestVM:UpdateSupplementInner()
    if self.IsEntourageMode then
        self.CanSupplement = false
        return
    end

    local PCfg = SceneEnterCfg:FindCfgByKey(_G.PWorldMgr:GetCurrPWorldResID())
    if not _G.PWorldTeamMgr:IsCaptain() then
        self.CanSupplement = false
        return
    end

    if PCfg then
        if PCfg.CanMidWay ~= 1 then
            self.CanSupplement = false
            return
        end
    end

    if PWorldMgr.IsFinished then
        self.CanSupplement = false
        return
    end

    local IsFromMatch = PWorldMgr:IsFromMatch() or false
    if not IsFromMatch then
        self.CanSupplement = false
        return
    end

    if self:IsInMuren() then
        self.CanSupplement = false
        return
    end

    if _G.PWorldMgr:GetRemainTime() / 60 <= 10 then
        self.CanSupplement = false
        return
    end

    local PWorldID = PWorldMgr:GetCurrPWorldResID()
    local MemCnt = PWorldTeamMgr:GetMemCnt()
    local RequireCnt = PWorldEntUtil.GetRequireMemCnt(PWorldID)

    self.CanSupplement = RequireCnt > MemCnt
end


function PWorldQuestVM:IsInMuren()
    return PWorldEntUtil.IsMuren(PWorldMgr:GetCurrPWorldResID())
end

return PWorldQuestVM