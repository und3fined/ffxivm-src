local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local ProtoCommon = require("Protocol/ProtoCommon")
local PWorldDynDataMgr = require("Game/PWorld/DynData/PWorldDynDataMgr")
local PWorldMgr = _G.PWorldMgr
local EventID = _G.EventID
local MapDynType = ProtoCommon.MapDynType
local EffectType = MapDynType.MAP_DYNAMIC_DATA_TYPE_DYN_INSTANCE
local UpAnimTime = 6 -- 上升的动画时间为6s
local WheelIntervalTime = 4 -- 第四个轮子先转 4s后第三个轮子转 然后 4s后第二个转....
local WheelRotatingTime = 20 -- 轮子转动动画为20s
-- local EndWaitTime = 5 -- 轮子旋转完成后等待多久开始回到地底下
-- local EDynaIndex = {
--     ["CenterDynItem"] = 1, ["LottoryWheel4"] = 2, ["LottoryWheel3"] = 3, ["LottoryWheel2"] = 4, ["LottoryWheel1"] = 5, ["LastStageOrnament"] = 6,
--     ["StageOrnament2"] = 7, ["StageOrnament1"] = 8, ["StagePole3"] = 9, ["StagePole4"] = 10, ["StagePole5"] = 11, ["StagePole6"] = 12,
--     ["StagePole1"] = 13, ["StagePole2"] = 14, ["CenterPole"] = 15
-- }
-- local WheelIndex = {
--     Wheel1 = 1,
--     Wheel2 = 2,
--     Wheel3 = 3,
--     Wheel4 = 4,
-- }

---@class JumboCactpotDynaMgr : MgrBase
local JumboCactpotDynaMgr = LuaClass(MgrBase)

function JumboCactpotDynaMgr:OnInit()
    self.JDMapID = 12060
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
    if BaseInfo.CurrMapResID == self.JDMapID then
        if self.bEnterWrold then
            return
        end
        self.bEnterWrold = true
        local JDMapEditData = _G.MapEditDataMgr:GetMapEditCfg()
        local MapDynamicAssetList = JDMapEditData.MapDynamicAssetList
        if #MapDynamicAssetList > 0 then
            -- self.DynItemID = {                  -- 15个相关动态物件ID LottoryWheel开奖转动的转轮 StagePole达到阶段升起的柱子
            --     CenterDynItem = MapDynamicAssetList[EDynaIndex.CenterDynItem].ID, StagePole1 = MapDynamicAssetList[EDynaIndex.StagePole1].ID, StagePole6 = MapDynamicAssetList[EDynaIndex.StagePole6].ID,  
            --     LottoryWheel1 = MapDynamicAssetList[EDynaIndex.LottoryWheel1].ID, StagePole2 = MapDynamicAssetList[EDynaIndex.StagePole2].ID, StageOrnament2 = MapDynamicAssetList[EDynaIndex.StageOrnament2].ID,
            --     LottoryWheel2 = MapDynamicAssetList[EDynaIndex.LottoryWheel2].ID, StagePole3 = MapDynamicAssetList[EDynaIndex.StagePole3].ID, LastStageOrnament = MapDynamicAssetList[EDynaIndex.LastStageOrnament].ID,
            --     LottoryWheel3 = MapDynamicAssetList[EDynaIndex.LottoryWheel3].ID, StagePole4 = MapDynamicAssetList[EDynaIndex.StagePole4].ID, StageOrnament1 = MapDynamicAssetList[EDynaIndex.StageOrnament1].ID,
            --     LottoryWheel4 = MapDynamicAssetList[EDynaIndex.LottoryWheel4].ID, StagePole5 = MapDynamicAssetList[EDynaIndex.StagePole5].ID, CenterPole = MapDynamicAssetList[EDynaIndex.CenterPole].ID,
            -- }
        end
       
        -- local DynItemID = self.DynItemID
        -- local LottoryWheelState = JumboCactpotDefine.LottoryWheelState
        -- for i = 1, 4 do
        --     local Index = string.format("LottoryWheel%s", i)
        --     local LottoryWheelID = DynItemID[Index] 
        --     PWorldMgr:LocalUpdateDynData(EffectType, LottoryWheelID, LottoryWheelState.Down)
        -- end

        --- 如果不存在基础数据则请求基础数据，如果存在就直接更新动态物件
    end
end

function JumboCactpotDynaMgr:OnPWorldExit(LeavePWorldResID, LeaveMapResID)
    local BaseInfo = PWorldMgr.BaseInfo
    self.CurrMapResID = BaseInfo.CurrMapResID
    if LeaveMapResID == self.JDMapID then
        self.bEnterWrold = false
    end
end


--- @type 根据当前处于什么阶段和是否是进入金碟游乐场更新动态物件的状态
--- @param CurrStage number
--- @param bIsEnterWrold boolean
function JumboCactpotDynaMgr:UpdateDynItemByCurrStage(CurrStage, bIsEnterWrold)
    self:UpdateSixPoleState(CurrStage, bIsEnterWrold)
    self:UpdateCenterPoleState(CurrStage, bIsEnterWrold)
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

---@type 更新中心柱子的状态
function JumboCactpotDynaMgr:UpdateCenterPoleState(CurrStage, bIsEnterWorld)
    local DynItemID = self.DynItemID
    if DynItemID == nil then
        _G.FLOG_WARNING("DynItemID == nil Wait Load DynItemID")
        return
    end
    local MaxCurrStage = 7
    local CenterPoleData = PWorldDynDataMgr:GetDynData(EffectType, DynItemID.CenterPole)
    if CenterPoleData == nil then
        _G.FLOG_WARNING("Do not get dyndata ID: %s", DynItemID.CenterPole)
        return
    end
    local CPCurState = CenterPoleData.State
    local CenterPoleState = JumboCactpotDefine.CenterPoleState

    local NeedState
    if CurrStage == MaxCurrStage then
        if bIsEnterWorld then
            NeedState = CenterPoleState.UpIm    -- 立即升上来，用于刚进入世界
        else
            NeedState = CenterPoleState.Up
        end
    else
        if bIsEnterWorld then
            NeedState = CenterPoleState.Default -- 立即下来，用于刚进入世界
        else
            NeedState = CenterPoleState.Down
        end
    end
    if NeedState == CenterPoleState.Down then
        if CPCurState == CenterPoleState.Down or CPCurState == CenterPoleState.Default then
            return
        end
        if CPCurState == CenterPoleState.DownRotate then
            NeedState = CenterPoleState.Default
        end
    end

    if NeedState == CenterPoleState.Up then
        if CPCurState == CenterPoleState.UpIm or CPCurState == CenterPoleState.Up then
            return
        end
    end
    PWorldMgr:LocalUpdateDynData(EffectType, DynItemID.CenterPole, NeedState)
    -- PWorldMgr:PlaySharedGroupTimeline(5498894, NeedState)
end

function JumboCactpotDynaMgr:UpdateCenterPoleWhenCeremony(CurStage)
    local CenterPoleState = JumboCactpotDefine.CenterPoleState
    local DynItemID = self.DynItemID

    local NewState = CenterPoleState.DownRotate
    if CurStage >= JumboCactpotDefine.MaxStage then
        NewState = CenterPoleState.UpRotate
    end
    PWorldMgr:LocalUpdateDynData(EffectType, DynItemID.CenterPole, NewState)
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
