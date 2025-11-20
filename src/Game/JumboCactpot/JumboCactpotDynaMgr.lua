local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local GoldSauserMainPanelDefine = require("Game/GoldSauserMainPanel/GoldSauserMainPanelDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local PWorldDynDataMgr = require("Game/PWorld/DynData/PWorldDynDataMgr")
local PWorldMgr = _G.PWorldMgr
local EventID = _G.EventID
local MapDynType = ProtoCommon.MapDynType
local EffectType = MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
local CenterPoleState = JumboCactpotDefine.CenterPoleState
local GoldSauserMapID = GoldSauserMainPanelDefine.GoldSauserMapID -- 12060
local UpAnimTime = 6 -- 上升的动画时间为6s
local WheelIntervalTime = 4 -- 第四个轮子先转 4s后第三个轮子转 然后 4s后第二个转....
local WheelRotatingTime = 20 -- 轮子转动动画为20s
local CenterPoleSlowMoveTime = JumboCactpotDefine.CenterPoleSlowMoveTime

---@class JumboCactpotDynaMgr : MgrBase
local JumboCactpotDynaMgr = LuaClass(MgrBase)

function JumboCactpotDynaMgr:OnInit()
    self.JDResID = 1008204
    self.bEnterWrold = false
    self.DelayCeremonyTime = UpAnimTime + WheelRotatingTime + WheelIntervalTime * 3
    self.WinNumber = ""
    self.DynItemID = {
        CenterDynItem = 2, StagePole1 = 8, StagePole6 = 13,  
        LottoryWheel1 = 3, StagePole2 = 9, StageOrnament2 = 15,
        LottoryWheel2 = 4, StagePole3 = 10, LastStageOrnament = 16,
        LottoryWheel3 = 5, StagePole4 = 11, StageOrnament1 = 14,
        LottoryWheel4 = 6, StagePole5 = 12, CenterPole = 7, LottoryWheel5 = 23, LottoryWheel6 = 24, LottoryWheel7 = 25, LottoryWheel8 = 26,
        FloorAndLight = 27,
    }
end

function JumboCactpotDynaMgr:OnBegin()
  
end

function JumboCactpotDynaMgr:OnEnd()
end

function JumboCactpotDynaMgr:OnShutdown()
 
end

function JumboCactpotDynaMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.PWorldReady, self.OnPWorldReady)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)

end

function JumboCactpotDynaMgr:OnRegisterNetMsg()
    
end

--- @type 设置的得奖的彩票
function JumboCactpotDynaMgr:SetWinNumber(WinNumber)
    self.WinNumber = WinNumber
end

--- @type 当加载完世界
function JumboCactpotDynaMgr:OnPWorldReady()
    local BaseInfo = PWorldMgr.BaseInfo
    self.CurrMapResID = BaseInfo.CurrMapResID
    if BaseInfo.CurrMapResID == GoldSauserMapID then
        if self.bEnterWrold then
            return
        end
        self.bEnterWrold = true
    end
end

function JumboCactpotDynaMgr:OnPWorldExit(LeavePWorldResID, LeaveMapResID)
    local BaseInfo = PWorldMgr.BaseInfo
    self.CurrMapResID = BaseInfo.CurrMapResID
    if LeaveMapResID == GoldSauserMapID then
        self.bEnterWrold = false
    end
end


--- @type 根据当前处于什么阶段和是否是进入金碟游乐场更新动态物件的状态
--- @param CurrStage number
--- @param bIsEnterWrold boolean
--- @param IsInLottery boolean@是否在开奖过程中
function JumboCactpotDynaMgr:UpdateDynItemByCurrStage(CurrStage, bIsEnterWrold, IsInLottery)
    self:UpdateSixPoleState(CurrStage, bIsEnterWrold)
    self:UpdateCenterPoleState(CurrStage, bIsEnterWrold, IsInLottery)
    self:UpdateCenterItemState(CurrStage, false)
    self:UpdateStageOrnamentState(CurrStage, _G.JumboCactpotMgr.LastStage)
end

---@type 更新六个小柱子的状态
function JumboCactpotDynaMgr:UpdateSixPoleState(CurrStage, bIsEnterWrold)
    local DynItemID = self.DynItemID
    if DynItemID == nil then
        _G.FLOG_ERROR("DynItemID == nil Wait Load DynItemID")
        return
    end
    local StagePoleState = JumboCactpotDefine.StagePoleState
    for i = 1, 6 do
        local Key = string.format("StagePole%s", i)
        local StagePoleData = PWorldDynDataMgr:GetDynData(EffectType,  DynItemID[Key])
        if StagePoleData == nil then
            _G.FLOG_INFO("StagePoleData == nil")
            return
        end
        local NeedState
        if CurrStage >= i and not bIsEnterWrold then
            NeedState = StagePoleState.Up
        elseif CurrStage < i and not bIsEnterWrold then
            NeedState = StagePoleState.Down
        elseif CurrStage < i and bIsEnterWrold then
            NeedState = StagePoleState.Default          -- 立即下来，用于刚进入世界
        elseif CurrStage >= i and bIsEnterWrold then
            NeedState = StagePoleState.UpIm             -- 立即升上来，用于刚进入世界
        end
        local ShouldUpdate = true
        if NeedState == StagePoleState.Down then
            if StagePoleData.State == NeedState or StagePoleData.State == StagePoleState.Default then
                ShouldUpdate = false
            end
        elseif  NeedState == StagePoleState.Up then
            if StagePoleData.State == NeedState or StagePoleData.State == StagePoleState.UpIm then
                ShouldUpdate = false
            end
        end
        if ShouldUpdate then
            PWorldMgr:LocalUpdateDynData(EffectType, DynItemID[Key], NeedState) 
        end
    end
end

--- 更改中心柱的动态物件状态
function JumboCactpotDynaMgr:ChangeCenterPoleState(PoleState)
    local DynItemID = self.DynItemID
    if DynItemID == nil then
        _G.FLOG_WARNING("DynItemID == nil Wait Load DynItemID")
        return
    end
    local CenterPoleData = PWorldDynDataMgr:GetDynData(EffectType, DynItemID.CenterPole)
    if CenterPoleData == nil then
        _G.FLOG_WARNING("Do not get dyndata ID: %s", DynItemID.CenterPole)
        return
    end
    local ExistState = CenterPoleData.State
    if ExistState == PoleState then -- 相同状态不需要播放
        return
    end
    if PoleState == CenterPoleState.Down and ExistState == CenterPoleState.Default then -- 缓慢向下时若已处于最低状态不需要播放
        return
    end

    if PoleState == CenterPoleState.Up and ExistState == CenterPoleState.UpIm then -- 缓慢向上时若已处于最高状态不需要播放
        return
    end

    if ExistState == CenterPoleState.UpRotate and PoleState ~= CenterPoleState.UpIm then
        PWorldMgr:LocalUpdateDynData(EffectType, DynItemID.CenterPole, CenterPoleState.UpIm) -- 当原本状态位于高处旋转时，且下个状态不是高处静止时，先转换为高处静止，防止播放显示错误
    end

    if ExistState == CenterPoleState.DownRotate and PoleState ~= CenterPoleState.Default then
        PWorldMgr:LocalUpdateDynData(EffectType, DynItemID.CenterPole, CenterPoleState.Default) -- 当原本状态位于低处旋转时，且下个状态不是低处静止时，先转换为低处静止，防止播放显示错误
    end

    PWorldMgr:LocalUpdateDynData(EffectType, DynItemID.CenterPole, PoleState)
end

---@type 更新中心柱子的状态
function JumboCactpotDynaMgr:UpdateCenterPoleState(CurrStage, bIsEnterWorld, IsInLottery)
    local MaxCurrStage = 7
    local bUp = CurrStage == MaxCurrStage
    if IsInLottery then
        if bIsEnterWorld then
            if bUp then
                self:ChangeCenterPoleState(CenterPoleState.UpRotate)
            else
                self:ChangeCenterPoleState(CenterPoleState.DownRotate)
            end
        else
            local MoveTime = bUp and (CenterPoleSlowMoveTime[CenterPoleState.Up] or 0) or (CenterPoleSlowMoveTime[CenterPoleState.Down] or 0)
            if bUp then
                self:ChangeCenterPoleState(CenterPoleState.Up)
                self:RegisterTimer(function()
                    self:ChangeCenterPoleState(CenterPoleState.UpRotate)
                end, MoveTime)
            else
                self:ChangeCenterPoleState(CenterPoleState.Down)
                self:RegisterTimer(function()
                    self:ChangeCenterPoleState(CenterPoleState.DownRotate)
                end, MoveTime)
            end
        end
    else
        if bIsEnterWorld then
            if bUp then
                self:ChangeCenterPoleState(CenterPoleState.UpIm)
            else
                self:ChangeCenterPoleState(CenterPoleState.Default)
            end
        else
            if bUp then
                self:ChangeCenterPoleState(CenterPoleState.Up)
            else
                self:ChangeCenterPoleState(CenterPoleState.Down)
            end
        end
    end
end


--- @type 开奖是播放开奖仪式实则播放动态物件
function JumboCactpotDynaMgr:PlayDynItemWhenLottory()
    -- local Test = _G.MapEditDataMgr:GetMapEditCfg()
    -- local MapDynamicAssetList = Test.MapDynamicAssetList
    -- local DynItemID = self.DynItemID
    -- local LottoryWheelState = JumboCactpotDefine.LottoryWheelState
    -- for i = 1, 4 do
    --     local Index = string.format("LottoryWheel%s", i)
    --     local LottoryWheelID = DynItemID[Index]
    --     PWorldMgr:LocalUpdateDynData(EffectType, LottoryWheelID, LottoryWheelState.Up)
    -- end

    -- local function Temporary()
    --     self:UpdateWheelByNum(WheelIndex.Wheel4) -- 从右往左数第一个轮子转动
    --     self:RegisterTimer(function() self:UpdateWheelByNum(WheelIndex.Wheel3) end, WheelIntervalTime)-- 第二个轮子转动
    --     self:RegisterTimer(function() self:UpdateWheelByNum(WheelIndex.Wheel2) end, WheelIntervalTime * 2) --- 三
    --     self:RegisterTimer(function() self:UpdateWheelByNum(WheelIndex.Wheel1) end, WheelIntervalTime * 3) --- 四
    -- end
    -- self:RegisterTimer(Temporary, UpAnimTime)

    -- local DurTime = WheelRotatingTime + WheelIntervalTime * 3 + UpAnimTime + EndWaitTime
    -- local function EndCeremony() -- 结束开奖仪式
    --     for i = 1, 4 do
    --         local Index = string.format("LottoryWheel%s", i)
    --         local LottoryWheelID = DynItemID[Index] 
    --         PWorldMgr:LocalUpdateDynData(EffectType, LottoryWheelID, LottoryWheelState.Down)
    --     end
    --     self:UpdateDynItemByCurrStage(0, false)
    --     self:UnRegisterAllTimer()
    -- end
    -- -- 开奖后更新动态物件
    -- self:RegisterTimer(EndCeremony, DurTime, nil, 1)
end

--- @type 重连更新四个轮子的状态
function JumboCactpotDynaMgr:UpdateWheelOnReconnect()
    local DynItemID = JumboCactpotDynaMgr.DynItemID
    local LottoryWheelState = JumboCactpotDefine.LottoryWheelState
    for i = 1, 8 do
        local Index = string.format("LottoryWheel%s", i)
        local LottoryWheelID = DynItemID[Index]
        local WheelData = PWorldDynDataMgr:GetDynData(EffectType, LottoryWheelID)
        if WheelData == nil then -- 重连时候会出现nil的情况
            return
        end
        local CurState = WheelData.State
        if CurState ~= LottoryWheelState.Down or CurState ~= 0 then
            PWorldMgr:LocalUpdateDynData(EffectType, LottoryWheelID, LottoryWheelState.Down)
        end
    end
    local FloorAndLightID = DynItemID.FloorAndLight
    PWorldMgr:LocalUpdateDynData(EffectType, FloorAndLightID, 0)
end


--- @type 更新四个轮子的状态
function JumboCactpotDynaMgr:UpdateWheelByNum(Index)
    -- local DynItemID = self.DynItemID
    -- local LottoryWheelState = JumboCactpotDefine.LottoryWheelState
    -- local NameIndex = string.format("LottoryWheel%d", Index)
    -- local LottoryWheelID = DynItemID[NameIndex]
    -- local WinNumber = self.WinNumber
    -- local SingleWinNum = string.sub(WinNumber, Index, Index)
    -- local StateIndex = string.format("StopTo%s", SingleWinNum)
    -- if tonumber(SingleWinNum) % 2 == 0 then
    --     PWorldMgr:LocalUpdateDynData(EffectType, LottoryWheelID, LottoryWheelState[StateIndex])
    -- else
    --     PWorldMgr:LocalUpdateDynData(EffectType, LottoryWheelID, LottoryWheelState["StopTo2"])
    --     self:RegisterTimer(function() PWorldMgr:LocalUpdateDynData(EffectType, LottoryWheelID, LottoryWheelState[StateIndex]) end, WheelRotatingTime)
    -- end
end

--- @type 更新发放员Npc背后的那个动态物件的状态
function JumboCactpotDynaMgr:UpdateCenterItemState(CurStage, bInLottory)
    local CenterDynItemState = JumboCactpotDefine.CenterDynItemState
    local DynItemID = self.DynItemID
    local NameIndex = string.format("ShowLight%s", CurStage)
    if bInLottory and CurStage > 0 then
        local NoramlToLottoryStateOffset = 7
        NameIndex = string.format("ShowLight%s", CurStage + NoramlToLottoryStateOffset)
    end
    PWorldMgr:LocalUpdateDynData(EffectType, DynItemID.CenterDynItem, CenterDynItemState[NameIndex])
end

function JumboCactpotDynaMgr:UpdateStageOrnamentState(CurrStage, LastStage)
    local DynItemID = self.DynItemID
    local StageOrnamentState = JumboCactpotDefine.StageOrnamentState
    local StageOrState, LastStageOrState

    local NameIndex1 = string.format("ShowLight%s", CurrStage)
    StageOrState = StageOrnamentState[NameIndex1]
    local NameIndex2 = string.format("ShowLight%s", LastStage)
    LastStageOrState = StageOrnamentState[NameIndex2]
    PWorldMgr:LocalUpdateDynData(EffectType, DynItemID.StageOrnament1, StageOrState)
    PWorldMgr:LocalUpdateDynData(EffectType, DynItemID.StageOrnament2, StageOrState)
    PWorldMgr:LocalUpdateDynData(EffectType, DynItemID.LastStageOrnament, LastStageOrState)
end

return JumboCactpotDynaMgr
