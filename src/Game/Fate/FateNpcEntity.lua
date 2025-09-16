--
-- Author: MichaelYang_Lightpaw
-- Date: 2023-10-13 9:54
-- Description:FateNpc实体
--

local LuaClass = require("Core/LuaClass")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local ProtoCommon = require("Protocol/ProtoCommon")
local ActorUtil = require("Utils/ActorUtil")
local EventMgr = require("Event/EventMgr")
local EventID = require("Define/EventID")
local MsgTipsID = require("Define/MsgTipsID")
local ProtoCS = require("Protocol/ProtoCS")
local FateNpcyellCfg = require("TableCfg/FateNpcyellCfg")
local FateNpcyellarrayCfg = require("TableCfg/FateNpcyellarrayCfg")
local YellCfg = require("TableCfg/YellCfg")
local BitUtil = require("Utils/BitUtil")

local LSTR = _G.LSTR
local FLOG_ERROR = _G.FLOG_ERROR
local FLOG_WARNING = _G.FLOG_WARNING
local ClientVisionMgr = _G.ClientVisionMgr
local EActorType = _G.UE.EActorType

---@class FateNpcEntity

local FateNpcEntity = LuaClass()

---Ctor
function FateNpcEntity:Ctor()
    self:ResetData()
end

function FateNpcEntity:Init(InEntityID, InResID, InFateID)
    if (InEntityID == nil or InEntityID < 0) then
        _G.FLOG_ERROR("FateNpcEntity:Init 出错，传入的 InEntityID 无效，请检查")
        return false
    end

    self:ResetData()
    if (InResID == nil or InResID <= 0) then
        _G.FLOG_ERROR("传入的 InResID 无效，请检查")
        return false
    end
    local SearchStr = string.format("BNpcID == %d", InResID)
    local TempCfg = FateNpcyellCfg:FindCfg(SearchStr)
    if (TempCfg == nil) then
        FLOG_WARNING(
            "无法获取 FateNpcID , 查找的ResID :%d, EntityID : %d, 名字 : %s, 查找字符串 : %s",
            InResID,
            InEntityID,
            ActorUtil.GetActorName(InEntityID) or "",
            SearchStr
        )
        return false
    end

    self.Actor = ActorUtil.GetActorByEntityID(InEntityID)
    if (self.Actor == nil) then
        FLOG_ERROR("无法获取到 Actor, EntityID : " .. InEntityID)
        return false
    end

    self.EntityID = InEntityID
    self.ResID = InResID
    self.FateID = InFateID
    self.TableCfg = TempCfg
    self.Active = true
    self.DyingHpRate = self.TableCfg.DyingHpRate

    -- 这里默认登场，后续会有MONSTER的创建时间，根据创建时间小于当前时间2秒，来确定
    if (not self.HasPlayAppearYell) then
        self.HasPlayAppearYell = true
        local VisionEnterFlag = self.Actor.VisionEnterFlag
        local bNeedShow = false
        if (VisionEnterFlag ~= nil) then
            bNeedShow = (VisionEnterFlag & ProtoCS.VisionEnterFlag.VisionEnterFlagNewBorn) ~= 0
        end
        
        if (bNeedShow) then
            local TargetYellID = self.TableCfg.AppearYell
            if (TargetYellID ~= nil and TargetYellID > 0) then
                local YellCfg = YellCfg:FindCfgByKey(TargetYellID)
                if (YellCfg == nil) then
                    FLOG_ERROR("YellCfg 无法找到数据，ID : " .. TargetYellID)
                else
                    _G.SpeechBubbleMgr:ShowBubbleByID(self.EntityID, TargetYellID)
                    self.CommonCD = YellCfg.BalloonTime
                end
            end
        end
    end

    return true
end

function FateNpcEntity:PrepareYellArray(InTargetArrayID)
    local TimeSpan = -1
    local TempCfg = FateNpcyellarrayCfg:FindCfgByKey(InTargetArrayID)
    if (TempCfg == nil) then
        FLOG_ERROR("无法找打 FateNpcyellarrayCfg 数据，ID : " .. InTargetArrayID)
    else
        TimeSpan = math.random(TempCfg.YellInterval, TempCfg.YellIntervalMax)
        local YellIndex = math.random(1, #TempCfg.NpcYellArray)
        local YellID = TempCfg.NpcYellArray[YellIndex]
        table.insert(self.YellQueueTable, YellID)
    end
    return TimeSpan
end

-- 外部调用，每秒调用
function FateNpcEntity:Tick()
    if (not self.Active) then
        return
    end

    if (self.Actor == nil) then
        return
    end

    if (not self.Actor:IsValid()) then
        return
    end

    local StateComponent = self.Actor:GetStateComponent()
    if (StateComponent == nil) then
        FLOG_ERROR("无法获取到 Actor 的 StateComponent, EntityID : " .. tostring(self.EntityID))
    end

    if (StateComponent ~= nil and StateComponent:IsInNetState(ProtoCommon.CommStatID.COMM_STAT_COMBAT)) then
        --处于战斗中
        if (self.BattleYellTime <= 0) then
            local TargetArrayID = 0
            local AttrComponent = self.Actor:GetAttributeComponent()
            if (AttrComponent == nil) then
                FLOG_ERROR("无法获取到 Actor 的 GetAttributeComponent， EntityID : " .. tostring(self.EntityID))
            end
            if (AttrComponent ~= nil and self.DyingHpRate > 0) then
                local CurHp = AttrComponent:GetCurHp()
                local MaxHp = AttrComponent:GetMaxHp()
                local Percentage = CurHp / MaxHp
                if (Percentage<=self.DyingHpRate) then
                    -- 濒死
                    TargetArrayID = self.TableCfg.DyingYellArray
                else
                    TargetArrayID = self.TableCfg.BattleYellArray
                end
            else
                TargetArrayID = self.TableCfg.BattleYellArray
            end

            if (TargetArrayID ~= nil and TargetArrayID > 0) then
                local TimeSpan = self:PrepareYellArray(TargetArrayID)
                if (TimeSpan > 0) then
                    self.BattleYellTime = TimeSpan
                end
            end
        else
            self.BattleYellTime = self.BattleYellTime - 1
        end
    else
        if (self.NormalYellTime <= 0) then
            -- 这里是普通喊话
            local TargetArrayID = self.TableCfg.RunningYellArray
            if (TargetArrayID ~= nil and TargetArrayID > 0) then
                local TimeSpan = self:PrepareYellArray(TargetArrayID)
                if (TimeSpan > 0) then
                    self.NormalYellTime = TimeSpan
                end
            end
        else
            self.NormalYellTime = self.NormalYellTime - 1
        end
    end

    if (self.CommonCD <= 0) then
        if (#self.YellQueueTable > 0) then
            local YellID = table.remove(self.YellQueueTable, 1)
            local YellCfg = YellCfg:FindCfgByKey(YellID)
            if (YellCfg == nil) then
                FLOG_ERROR("YellCfg 无法找到数据，ID : " .. YellID)
            else
                _G.SpeechBubbleMgr:ShowBubbleByID(self.EntityID, YellID)
                self.CommonCD = YellCfg.BalloonTime
            end
        end
    else
        self.CommonCD = self.CommonCD - 1
    end
end

function FateNpcEntity:OnDead()
    self:ResetData()
end

function FateNpcEntity:ResetData()
    self.Actor = nil
    self.EntityID = 0
    self.ResID = 0
    self.FateID = 0
    self.TableCfg = nil
    self.NormalYellTime = 0 -- 普通YELL的CD
    self.BattleYellTime = 0 -- 战斗YELL的CD
    self.YellQueueTable = {}
    self.Active = false -- 是否激活更新
    self.CommonCD = 2 -- 公共等待时间
    self.HasPlayAppearYell = false -- 出现的时候播放的
    self.DyingHpRate = 0 -- 濒危血量
end

function FateNpcEntity:OnFaied()
    self.Active = false
    if (self.TableCfg == nil) then
        return
    end
    local YellID = self.TableCfg.FailureYell
    if (YellID ~= nil and YellID > 0) then
        _G.SpeechBubbleMgr:ShowBubbleByID(self.EntityID, YellID)
    end
    self:ResetData()
end

function FateNpcEntity:OnSuccess()
    self.Active = false
    if (self.TableCfg == nil) then
        return
    end
    local YellID = self.TableCfg.SuccessYell
    if (YellID ~= nil and YellID > 0) then
        _G.SpeechBubbleMgr:ShowBubbleByID(self.EntityID, YellID)
    end
    self:ResetData()
end

return FateNpcEntity
