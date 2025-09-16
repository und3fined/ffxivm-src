local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoRes = require("Protocol/ProtoRes")
local ProtoCS = require("Protocol/ProtoCS")
local ItemCfg = require("TableCfg/ItemCfg")
local TimeUtil = require("Utils/TimeUtil")
local JumboCactpotDefine = require("Game/JumboCactpot/JumboCactpotDefine")
local MajorUtil = require("Utils/MajorUtil")
local DateTimeTools = require("Common/DateTimeTools")
local FairycolorRaffleTimeCfg = require("TableCfg/FairycolorRaffleTimeCfg")
local GoldSauserVM = require("Game/Gate/GoldSauserVM")
local GameWeekCronCfg = require("TableCfg/GameWeekCronCfg")
local ProtoCommon = require("Protocol/ProtoCommon")
local FairycolorRaffleCfg = require("TableCfg/FairycolorRaffleCfg")
local AudioUtil = require("Utils/AudioUtil")
local RichTextUtil = require("Utils/RichTextUtil")
local MsgTipsUtil = require("Utils/MsgTipsUtil")
local FairycolorRaffleTempoCfg = require("TableCfg/FairycolorRaffleTempoCfg")
local UIViewID = _G.UIViewID
local UIViewMgr = _G.UIViewMgr
local LSTR = _G.LSTR
local PWorldMgr = _G.PWorldMgr
local CS_CMD = ProtoCS.CS_CMD
local MsgTipsID = require("Define/MsgTipsID")
local SCORE_TYPE = ProtoRes.SCORE_TYPE
local EventID = _G.EventID
local UE = _G.UE
local ActorUtil = require("Utils/ActorUtil")
local GameGlobalCfg = require("TableCfg/GameGlobalCfg")
local EffectUtil = require("Utils/EffectUtil")
local JumboAreaID = 1100000
local MaxRound = 3
local MaxPlayEffectDistance = 6000  --- 超过6000距离不再播放特效

---@class JumboCactpotLottoryCeremonyMgr : MgrBase
local JumboCactpotLottoryCeremonyMgr = LuaClass(MgrBase)

function JumboCactpotLottoryCeremonyMgr:OnInit()
    local EntertainGameID = ProtoRes.Game.GameID
    self.ID = EntertainGameID.GameIDFairyColor -- 仙人仙彩的ID
    self.JDMapID = 12060
    self.JDResID = 1008204
    self.bEnterWrold = false
    self.RaffleRound = 0                -- 抽奖轮数
    self.TotalRound = 0                 -- 总轮数
    -- self.bInRaffleTime = false          -- 是否处于抽奖时间
    self.RoleEntityIDList = {}
    self.InJumboAreaRoleList = {}
    self.PlayEffectRoleList = {}
    self.EffectIDList = {}
    self.JumbNpcList = {}
    self.JumbMonsterList = {}

    self.JumbArea = nil                 -- 仙彩区域数据
    self.bShowLottoryTips = false       -- 是否已经出现果仙人仙彩的提示
    self.CachLottoryListID = {}         -- 缓存中奖人员名单
    self.EffectArrayIndex = 1           -- 灯光特效数组index
    self.CachRaffleRewardNum = nil
end

function JumboCactpotLottoryCeremonyMgr:OnBegin()

end

function JumboCactpotLottoryCeremonyMgr:OnEnd()
end

function JumboCactpotLottoryCeremonyMgr:OnShutdown()

end

function JumboCactpotLottoryCeremonyMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.VisionEnter, self.OnGameEventVisionEnter)
    self:RegisterGameEvent(EventID.VisionLeave, self.OnGameEventVisionLeave)
    self:RegisterGameEvent(EventID.PWorldExit, self.OnPWorldExit)
    self:RegisterGameEvent(EventID.AreaTriggerBeginOverlap, self.OnEnterAreaTrigger)
    self:RegisterGameEvent(EventID.AreaTriggerEndOverlap, self.OnLeaveAreaTrigger)
    self:RegisterGameEvent(EventID.RoleLoginRes, self.OnGameEventLoginRes)


end

function JumboCactpotLottoryCeremonyMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, ProtoCS.FairyColorGameCmd.StartJoinPrize, self.OnStartJoinPrize) -- 开始参与奖
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, ProtoCS.FairyColorGameCmd.EndJoinPrize, self.OnEndJoinPrize) -- 结束参与见 
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, ProtoCS.FairyColorGameCmd.StartRaffle, self.OnStartRaffle)   -- 开始抽奖
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_FAIRY_COLOR, ProtoCS.FairyColorGameCmd.EndRaffle, self.OnEndRaffle)-- 结束抽奖 
end

function JumboCactpotLottoryCeremonyMgr:JumboCeremonyMgrReset(bResetAll)
    self.bEnterWrold = false
    self.RaffleRound = 0                -- 抽奖轮数
    self.TotalRound = 0                 -- 总轮数 
    -- self.bInRaffleTime = false          -- 是否处于抽奖时间
    self.InJumboAreaRoleList = {}
    self.PlayEffectRoleList = {}
    self.EffectIDList = {}
    -- self.JumbNpcList = {}
    self.JumbArea = nil                 -- 仙彩区域数据
    if bResetAll then
        self.RoleEntityIDList = {}
    end
    self.CachLottoryListID = {}         -- 缓存中奖人员名单
    self.EffectArrayIndex = 1
    self.CachRaffleRewardNum = nil
    self:EndPlayLuckDrawEffectTimer() -- 开始的时候先清空Timer
end

function JumboCactpotLottoryCeremonyMgr:OnlyExitWorldReset()
    self.JumbNpcList = {}
    self.JumbMonsterList = {}
end

function JumboCactpotLottoryCeremonyMgr:OnPWorldExit(LeavePWorldResID, LeaveMapResID)
    if LeaveMapResID == self.JDMapID then
        self:UnRegisterAllTimer()
        self:JumboCeremonyMgrReset(true)
        self:OnlyExitWorldReset()
    end
end

function JumboCactpotLottoryCeremonyMgr:OnGameEventLoginRes(Params)
    local bReconnect = Params.bReconnect
    if bReconnect then
        local BaseInfo = PWorldMgr.BaseInfo
        if BaseInfo.CurrMapResID == self.JDMapID then
            self:EndPlayLuckDrawEffectTimer()
            self:HideLastEffect()
        end
    end
end


function JumboCactpotLottoryCeremonyMgr:OnGameEventVisionEnter(Params)
    local BaseInfo = PWorldMgr.BaseInfo
    -- self.CurrMapResID = BaseInfo.CurrMapResID
    if BaseInfo.CurrMapResID ~= self.JDMapID then
        return
    end

    local ActorType = Params.IntParam1
    local EntityID = Params.ULongParam1
    local ResID = Params.IntParam2
    if ActorType == _G.UE.EActorType.Npc and self:CheckIsJumboNpc(ResID) then
        self.JumbNpcList[ResID] = EntityID
    end

    if ActorType == _G.EActorType.Monster and self:CheckIsJumboMonster(ResID) then
        self.JumbMonsterList[ResID] = EntityID
    end

    if ActorType ~= _G.UE.EActorType.Player then
        return
    end
    ---                                是否参与抽奖
    local Tmp = {EntityID = EntityID, bAttendLuckDraw = true}
    table.insert(self.RoleEntityIDList, Tmp)
    -- local ResID = Params.IntParam2
end

function JumboCactpotLottoryCeremonyMgr:OnGameEventVisionLeave(Params)
    local ActorType = Params.IntParam1
    if ActorType ~= _G.UE.EActorType.Player then
        return
    end
    local EntityID = Params.ULongParam1
    table.array_remove_item_pred(self.RoleEntityIDList, function(Elem) return Elem.EntityID == EntityID end) 
    table.array_remove_item_pred(self.PlayEffectRoleList, function(Elem) return Elem.EntityID == EntityID end)
    table.array_remove_item_pred(self.InJumboAreaRoleList, function(Elem) return Elem.EntityID == EntityID end) 
end

--- @type 当进入仙彩区域
function JumboCactpotLottoryCeremonyMgr:OnEnterAreaTrigger(Params)
    if Params.AreaID == JumboAreaID then
        self.bEnterJumbArea = true
    end
end

function JumboCactpotLottoryCeremonyMgr:OnLeaveAreaTrigger(Params)
    if Params.AreaID == JumboAreaID then
        self.bEnterJumbArea = false
        self:ChangebAttendLuckDraw(MajorUtil.GetMajorEntityID(), false)
    end
end

function JumboCactpotLottoryCeremonyMgr:GetbEnterJumbArea()
    return self.bEnterJumbArea
end

--- @type 当开始抽奖
function JumboCactpotLottoryCeremonyMgr:OnStartRaffle(MsgBody)
    if MsgBody == nil then
        return
    end
    self.bShowLottoryTips = false
    -- self.bInRaffleTime = true          -- 是否处于抽奖时间

    self:EndPlayLuckDrawEffectTimer() -- 开始的时候先清空Timer
    local StartRaffle = MsgBody.StartRaffle
    self.RaffleRound = StartRaffle.Round
    self.TotalRound = StartRaffle.TotalRound
    MsgTipsUtil.ShowTipsByID(MsgTipsID.JumboBeginRaffleTip)
    self:TryAddMajorToList()
    self:BeginPlayRaffleEffect(StartRaffle.Num)
    self.CachLottoryListID = {}
end

--- @type 当结束抽奖
function JumboCactpotLottoryCeremonyMgr:OnEndRaffle(MsgBody)
    if MsgBody == nil then
        return
    end
    -- self.bInRaffleTime = false
    local EndRaffle = MsgBody.EndRaffle
    self.RaffleRound = EndRaffle.Round
    self.CurRoundRewardNum = EndRaffle.RewardNum
    AudioUtil.LoadAndPlay2DSound(JumboCactpotDefine.JumboCeremoneyAudioAssetPath.AssertLottory)

    self:EndPlayLuckDrawEffectTimer()
    self:HideLastEffect()
    local RoleList = self:GetRoleListByRoleId(EndRaffle.RoleIds)
    self:PlayRaffleEffect(RoleList, true)
    self:PlayGetRaffleVfx(RoleList)

    local JumboCeremoneyAssetPath = JumboCactpotDefine.JumboCeremoneyAssetPath
    self:JumboNpcPlayMontage(JumboCeremoneyAssetPath.CongratulationAtl)
    self.CachLottoryListID = EndRaffle.RoleIds

    local DelayShowCountDownTime = GameGlobalCfg:FindCfgByKey(ProtoRes.Game.game_global_cfg_id.GAME_CFG_FAIRY_COLOR_DELAY_SHOW_COUNTDOWN_TIP_TIME_ONEND).Value[1]
    local NeedMsgTipsID = MsgTipsID.JumboLastEndRaffleTip
    if EndRaffle.Round < MaxRound then
        NeedMsgTipsID = MsgTipsID.JumboEndRaffleTip
        self:RegisterTimer(function() self:ShowCountTip(EndRaffle.Round, tonumber(DelayShowCountDownTime)) end, tonumber(DelayShowCountDownTime))
    end
    MsgTipsUtil.ShowTipsByID(NeedMsgTipsID)
    self:TryShowGetRewardPanelByCach()
end

--- @type 模拟开奖灯光
function JumboCactpotLottoryCeremonyMgr:GMSimulateSpotEffect(ID)
    local RoleList = {}
    local Params = {
        EntityID = MajorUtil.GetMajorEntityID(),
        bAttendLuckDraw = true
    }
    table.insert(RoleList, Params)
    self:PlayRaffleEffect(RoleList)
end

--- @type 开始参与奖
function JumboCactpotLottoryCeremonyMgr:OnStartJoinPrize(MsgBody)
    MsgTipsUtil.ShowTipsByID(MsgTipsID.JumbStartJoinPrizeTip)
end

--- @type 结束参与奖
function JumboCactpotLottoryCeremonyMgr:OnEndJoinPrize(MsgBody)
    local JumboCeremoneyAssetPath = JumboCactpotDefine.JumboCeremoneyAssetPath
    self:JumboNpcPlayMontage(JumboCeremoneyAssetPath.ThrowMoneyAtl)
end

--- @type 停止播放特效
function JumboCactpotLottoryCeremonyMgr:EndPlayLuckDrawEffectTimer()
    self.InJumboAreaRoleList = {}
    if self.PlayEffectTimer ~= nil then
        FLOG_INFO("EndPlayRaffleEffect")
        self:UnRegisterTimer(self.PlayEffectTimer)
        self.PlayEffectTimer = nil
    end
end

--- @type 开始播放聚光灯特效
function JumboCactpotLottoryCeremonyMgr:BeginPlayRaffleEffect(InitNum)
    local RoleEntityIDList = self.RoleEntityIDList
    for _, v in pairs(RoleEntityIDList) do
        v.bAttendLuckDraw = self:CheckIsInJumbArea(v.EntityID)
    end
    self:ResetEffectArrayIndex()

    self:TryRegisterPlayEffectTimer(InitNum)
end

--- @type 注册播放灯光的计时器
function JumboCactpotLottoryCeremonyMgr:TryRegisterPlayEffectTimer(InitNum)
    local DelayTime = self:GetDelayTime()
    if DelayTime ~= nil and DelayTime >= 0 then
        self:AddEffectArrayIndex()
        self.PlayEffectTimer = self:RegisterTimer(self.TryPlayeRaffleEffect, DelayTime, DelayTime, 1, InitNum)
    end
end

function JumboCactpotLottoryCeremonyMgr:TryPlayeRaffleEffect(InitNum)
    local RoleEntityIDList = self.RoleEntityIDList
    if #RoleEntityIDList > 0 then
        self:OnPlayRaffleEffect(InitNum)
    end

    self:TryRegisterPlayEffectTimer(InitNum)
end

--- @type 当开始播放特效
function JumboCactpotLottoryCeremonyMgr:OnPlayRaffleEffect(InitNum)
    -- OnPlay
    self:HideLastEffect()
    self:ChoosePlayEffectList(InitNum)

    -- Play
    self:PlayRaffleEffect()

    -- OnPlayEnd
    self:OnPlayRaffleEffectEnd()
end

--- @type 隐藏上一次出现的特效
function JumboCactpotLottoryCeremonyMgr:HideLastEffect()
   local EffectIDList = self.EffectIDList
   for i = 1, #EffectIDList do
        local VfxID = EffectIDList[i]
        EffectUtil.StopVfx(VfxID, 0)
   end
   self.EffectIDList = {}
end

--- @type 重置灯光闪烁数组index
function JumboCactpotLottoryCeremonyMgr:ResetEffectArrayIndex()
    self.EffectArrayIndex = 1
end

--- @type 获取灯光闪烁数组index
function JumboCactpotLottoryCeremonyMgr:GetEffectArrayIndex()
    return self.EffectArrayIndex
end

--- @type 增加灯光刷说数组Index
function JumboCactpotLottoryCeremonyMgr:AddEffectArrayIndex()
    self.EffectArrayIndex = self.EffectArrayIndex + 1
end

--- @type 获取下一次灯光出现的延迟时间
function JumboCactpotLottoryCeremonyMgr:GetDelayTime()
    local CurRaffleRound = self.RaffleRound
    local RaffTempoCfg = FairycolorRaffleTempoCfg:FindCfgByKey(CurRaffleRound)
    if RaffTempoCfg == nil then
        FLOG_ERROR("FairycolorRaffleTempoCfg = nil")
        return
    end
    local EffectArrayIndex = self:GetEffectArrayIndex()
    local IntervalTime = RaffTempoCfg.IntervalTime
    return IntervalTime[EffectArrayIndex]
end

--- @type 当播放完
function JumboCactpotLottoryCeremonyMgr:OnPlayRaffleEffectEnd()
    self.PlayEffectRoleList = {}
end

--- @type 播放聚光灯特效
function JumboCactpotLottoryCeremonyMgr:PlayRaffleEffect(RoleList, bShowLottoryEffect)
    local PlayEffectRoleList = RoleList or self.PlayEffectRoleList
    local JumboCeremoneyAssetPath = JumboCactpotDefine.JumboCeremoneyAssetPath
    for _, v in pairs(PlayEffectRoleList) do
        local Elem = v
        local EntityID = Elem.EntityID
        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        if Actor ~= nil and Elem.bAttendLuckDraw then
            local VfxParameter = _G.UE.FVfxParameter()
            VfxParameter.VfxRequireData.EffectPath = bShowLottoryEffect and JumboCeremoneyAssetPath.SpotLottoryLightVfx or JumboCeremoneyAssetPath.SpotLightVfx
            VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_JumboCactpotLottoryCeremony
            local AttachPointType_AttachPointType_Body = _G.UE.EVFXAttachPointType.AttachPointType_Body
            VfxParameter.VfxRequireData.VfxTransform = Actor:FGetActorTransform()
            VfxParameter.VfxRequireData.bAlwaysSpawn = true

            VfxParameter:SetCaster(Actor, 0, AttachPointType_AttachPointType_Body, 0)
            local ID = EffectUtil.PlayVfx(VfxParameter)

            table.insert(self.EffectIDList, ID)
        end
    end
    if bShowLottoryEffect then
        self:RegisterTimer(self.HideLastEffect, 6)
    elseif self.bEnterJumbArea then -- 在仙彩范围内
        AudioUtil.LoadAndPlay2DSound(JumboCactpotDefine.JumboCeremoneyAudioAssetPath.FlickeringLights)
    end
end

--- @type 播放中奖特效
function JumboCactpotLottoryCeremonyMgr:PlayGetRaffleVfx(RoleList)
    local JumboCeremoneyAssetPath = JumboCactpotDefine.JumboCeremoneyAssetPath
    for _, v in pairs(RoleList) do
        local Elem = v
        local EntityID = Elem.EntityID
        local Actor = ActorUtil.GetActorByEntityID(EntityID)
        if Actor ~= nil then
            --- play GetRaffleVfx1
            local VfxParameter = _G.UE.FVfxParameter()
            VfxParameter.VfxRequireData.EffectPath = JumboCeremoneyAssetPath.GetRaffleVfx
            VfxParameter.PlaySourceType=_G.UE.EVFXPlaySourceType.PlaySourceType_JumboCactpotLottoryCeremony
            local AttachPointType_AttachPointType_Body= _G.UE.EVFXAttachPointType.AttachPointType_Body
            local ActorTransform = Actor:FGetActorTransform()
            VfxParameter.VfxRequireData.VfxTransform = ActorTransform
            VfxParameter.VfxRequireData.bAlwaysSpawn = true
            VfxParameter:SetCaster(Actor, 0, AttachPointType_AttachPointType_Body, 0)
            local ID1 = EffectUtil.KickTrigger(VfxParameter, 1)
            table.insert(self.EffectIDList, ID1)
            FLOG_INFO("PlayGetRaffleVfx1 Sucess")

            --- play GetRaffleVfx2
            local VfxParameter2 = _G.UE.FVfxParameter()
            VfxParameter2.VfxRequireData.EffectPath = JumboCeremoneyAssetPath.GetRaffleVfx2
            VfxParameter2.VfxRequireData.VfxTransform = ActorTransform
            VfxParameter2.VfxRequireData.bAlwaysSpawn = true
            VfxParameter2:SetCaster(Actor, 0, AttachPointType_AttachPointType_Body, 0)
            local ID2 = EffectUtil.PlayVfx(VfxParameter2, 1)
            table.insert(self.EffectIDList, ID2)
            FLOG_INFO("PlayGetRaffleVfx2 Sucess")

        else
            FLOG_WARNING("PlayGetRaffleVfx Actor == nil")
        end
    end
    if #RoleList > 0 then
        self:RegisterTimer(function() AudioUtil.LoadAndPlay2DSound(JumboCactpotDefine.JumboCeremoneyAudioAssetPath.LottoryCoin) end, 2) 
    end
end

--- @type 选出需要播放聚光灯特效的角色列表 
function JumboCactpotLottoryCeremonyMgr:ChoosePlayEffectList(InitNum)
    -- if #self.InJumboAreaRoleList < InitNum then
    -- 如果在仙彩区域则插入InJumboAreaRoleList
    local RoleEntityIDList = self.RoleEntityIDList
    for _, v in pairs(RoleEntityIDList) do
        local Data = v
        local bInJumbArea = self:CheckIsInJumbArea(Data.EntityID)
        v.bAttendLuckDraw = bInJumbArea
        if bInJumbArea then
            table.insert(self.InJumboAreaRoleList, Data)
        end
    end
    -- end

    for i = 1, InitNum do
        local InJumboAreaRoleNum = #self.InJumboAreaRoleList
        if InJumboAreaRoleNum == 0 then
            return
        elseif InJumboAreaRoleNum == 1 and self.InJumboAreaRoleList[1].bAttendLuckDraw then
            table.insert(self.PlayEffectRoleList, self.InJumboAreaRoleList[1])
        else
            while #self.InJumboAreaRoleList > 1 do
                math.randomseed(TimeUtil.GetServerTimeMS())  -- 设置随机数种子
                local Num = math.random(1, #self.InJumboAreaRoleList)
                -- FLOG_ERROR(" Length = %s", #self.InJumboAreaRoleList)
                -- FLOG_ERROR(" Random Num = %s", Num)
                if self.InJumboAreaRoleList[Num].bAttendLuckDraw then
                    table.insert(self.PlayEffectRoleList, self.InJumboAreaRoleList[Num])
                    break;
                end
                table.remove(self.InJumboAreaRoleList, Num) 
            end  
        end

      
    end
end

function JumboCactpotLottoryCeremonyMgr:ChangebAttendLuckDraw(EntityID, bAttendLuckDraw)
    local RoleEntityIDList = self.RoleEntityIDList
    for _, v in pairs(RoleEntityIDList) do
        if v.EntityID == EntityID then
            v.bAttendLuckDraw = bAttendLuckDraw
            break
        end
    end
    
    local PlayEffectRoleList = self.PlayEffectRoleList
    for _, v in pairs(PlayEffectRoleList) do
        if v.EntityID == EntityID then
            v.bAttendLuckDraw = bAttendLuckDraw
            break
        end
    end

    local InJumboAreaRoleList = self.InJumboAreaRoleList
    for _, v in pairs(InJumboAreaRoleList) do
        if v.EntityID == EntityID then
            v.bAttendLuckDraw = bAttendLuckDraw
            break
        end
    end
end

--- @type 获取仙彩区域的数据
function JumboCactpotLottoryCeremonyMgr:GetJumbArea()
    local JumbArea = self.JumbArea
    if JumbArea == nil then
        JumbArea = _G.MapEditDataMgr:GetArea(JumboAreaID)
        self.JumbArea = JumbArea
    end
    return JumbArea
end

--- @type 获取Major离仙彩区域多远
function JumboCactpotLottoryCeremonyMgr:GetJumbAreaDistance()
    local JumbArea = self:GetJumbArea()
    if JumbArea == nil then
        return -1
    end
    local Box = JumbArea.Box
    local Center = Box.Center
    local AreaLoc = UE.FVector(Center.X, Center.Y, Center.Z)
    local Role = ActorUtil.GetActorByEntityID(MajorUtil.GetMajorEntityID())
    if Role == nil then
        return -1
    end
    local RoleLoc = Role:FGetActorLocation()

    return _G.UE.FVector.Dist(RoleLoc, AreaLoc)
end

--- @type 检测是否在区域内(有十几厘米误差)
function JumboCactpotLottoryCeremonyMgr:CheckIsInJumbArea(RoleEntityID, NewLoc)
    -- local RoleEntityID = RoleEntityID or MajorUtil.GetMajorEntityID()
    local JumbArea = self:GetJumbArea()
    if JumbArea == nil then
        return false
    end
    local Box = JumbArea.Box
    local Rotator = Box.Rotator
    local Center = Box.Center
    local Extent = Box.Extent
    local AreaRotator = UE.FRotator(Rotator.X, Rotator.Z, Rotator.Y)
    local AreaLoc = UE.FVector(Center.X, Center.Y, Center.Z)
    local Role = ActorUtil.GetActorByEntityID(RoleEntityID)
    if Role == nil then
        return false
    end
    local RoleLoc = NewLoc or Role:FGetActorLocation() --(AreaLoc + UE.FVector(100, 0, 0)) 
    -- local RoleLocIgoreZ = UE.FVector(RoleLoc.X, RoleLoc.Y)
    local ToRoleVector = UE.FVector(RoleLoc.X, RoleLoc.Y, 0) - UE.FVector(AreaLoc.X, AreaLoc.Y, 0)  -- 方向从Area指向玩家的向量
    -- local UnRotationRoleLoc = AreaRotator:UnrotateVector(ToRoleVector)
    local UnRotationRoleLoc = AreaRotator:UnrotateVector(ToRoleVector)

    local FirstQuadrantBoundaryPoints = UE.FVector(Extent.X, Extent.Y, 0)
    local SecondQuadrantBoundaryPoints = UE.FVector(-Extent.X, Extent.Y, 0)
    local ThirdQuadrantBoundaryPoints = UE.FVector(-Extent.X, -Extent.Y, 0)
    local ForthQuadrantBoundaryPoints = UE.FVector(Extent.X, -Extent.Y, 0)
    if UnRotationRoleLoc.X <= FirstQuadrantBoundaryPoints.X and UnRotationRoleLoc.X >= SecondQuadrantBoundaryPoints.X 
    and UnRotationRoleLoc.Y <= FirstQuadrantBoundaryPoints.Y and UnRotationRoleLoc.Y >= ThirdQuadrantBoundaryPoints.Y
    and RoleLoc.Z >= (AreaLoc.Z - 200) then
        return true
    end

    return false
end

function JumboCactpotLottoryCeremonyMgr:JumboNpcPlayMontage(Path)
    local JumbNpcList = self.JumbNpcList
    for _, v in pairs(JumbNpcList) do
        local NpcEntityID = v
        local Npc = ActorUtil.GetActorByEntityID(NpcEntityID)
        if Npc then
            _G.AnimMgr:PlayActionTimeLineByActor(Npc, Path, nil)
        end
    end
end

--- @type 销毁射箭的Monster_看着像Npc实则使用monster做的
function JumboCactpotLottoryCeremonyMgr:DestroyJumboMonster()
    local JumbMonsterList = JumboCactpotLottoryCeremonyMgr.JumbMonsterList
    for _, MonsterEntityID in pairs(JumbMonsterList) do
        _G.ClientVisionMgr:DestoryClientActor(MonsterEntityID, _G.EActorType.Monster)
    end
end

function JumboCactpotLottoryCeremonyMgr:GetRoleListByRoleId(RoleIdList)
    local RoleList = {}
    for _, RoleID in pairs(RoleIdList) do
        local RoleEntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
        if RoleEntityID ~= nil then
            local Params = {
                EntityID = RoleEntityID,
                bAttendLuckDraw = self:CheckIsInJumbArea(RoleEntityID)
            }
            table.insert(RoleList, Params)
        end
    end
    return RoleList
end

--- @type 获取中奖人员名单
function JumboCactpotLottoryCeremonyMgr:GetLottoryPlayerName(Color)
    local Length = 3
    local CachLottoryListID = self.CachLottoryListID
    if CachLottoryListID == nil then
        return ""
    end
    if #CachLottoryListID < Length then
        Length = #CachLottoryListID
    end
    local NeedName = ""
    for i = 1, Length do
        local RoleID = CachLottoryListID[i]
        local RoleVM = _G.RoleInfoMgr:FindRoleVM(RoleID)
        if NeedName == "" then
            NeedName = string.format("%s%s", NeedName, RoleVM.Name)
        else
            NeedName = string.format("%s %s", NeedName, RoleVM.Name)
        end
    end
    NeedName = RichTextUtil.GetText(NeedName, tostring(Color))
    return NeedName
end

-- function JumboCactpotLottoryCeremonyMgr:Test()
--     local RoleVM = _G.ActorMgr:FindActorVMByRoleID(MajorUtil.GetMajorRoleID())

--     local a
-- end

--- @type 把主角加到列表里
function JumboCactpotLottoryCeremonyMgr:TryAddMajorToList()
    local MajorEntityID = MajorUtil.GetMajorEntityID()
    local bContained = false
    local RoleEntityIDList = self.RoleEntityIDList
    for _, v in pairs(RoleEntityIDList) do
        if v.EntityID == MajorEntityID then
            bContained = true
        end
    end
 
    if not bContained then
        local Tmp = {EntityID = MajorEntityID, bAttendLuckDraw = true}
        table.insert(self.RoleEntityIDList, Tmp)
    end
end

--- @type 检测还有多久就进行开奖仪式了
function JumboCactpotLottoryCeremonyMgr:CheckIsNearLotteryCeremoneyTime()
    local RemainTime = self:GetRemainSecondTime()
    local TwoMinSec = 120
    if RemainTime > TwoMinSec then
        return
    end
    if RemainTime <= TwoMinSec and not self.bShowLottoryTips then  --- 剩余2分钟开奖
        MsgTipsUtil.ShowTipsByID(MsgTipsID.JumbCountBeginRaffleTip)
        self.bShowLottoryTips = true
        if RemainTime <= 1 then
        end
    end
end

function JumboCactpotLottoryCeremonyMgr:GetRemainSecondTime()
    local Cfg = GameWeekCronCfg:FindCfgByKey(self.ID)
    if Cfg == nil then
        return
    end
  
    -- local ServerTime = TimeUtil.GetServerTimeFormat("%H:%M:%S")
    -- if self:CheckIsInJumbArea(MajorUtil.GetMajorEntityID()) then
    --     FLOG_INFO("ServerTime = %s", ServerTime)
    -- end

    local ServerTime = TimeUtil.GetServerTime()
    local ServerZone = 8 --这里先认为服务器在东8区，后面要以实际布置的服务器时区为准
    local LocalServeTime = ServerTime + (DateTimeTools.GetTimeZone() - ServerZone) * 3600
	local TmTime = os.date("*t",LocalServeTime)
    local CurWeekday = TmTime.wday - 1  -- 表示周几
    local CurDaySec = TimeUtil.GetGameDayTimeSinceServerTime()
    local CurWeekSec = (CurWeekday - 1) * 86400 + CurDaySec
    local NeedWeek = Cfg.Week == 0 and 7 or Cfg.Week -- 0的时候表示的是周天
    local NeedMin = Cfg.Minute == nil and 0 or Cfg.Minute
    local NeedSec = Cfg.Second == nil and 0 or Cfg.Second
    local OneWeekLotterySec = 86400 * (NeedWeek - 1) + 3600 * Cfg.Hour + 60 * NeedMin + NeedSec -- 开奖时间对应在该周的秒数
    -- local OneWeekLotterySec = 86400 * 5 + 3600 * 21
    local RemainTime
    if CurWeekSec <= OneWeekLotterySec then
        RemainTime = OneWeekLotterySec - CurWeekSec
    else
        local OneWeekSec = 86400 * 7
        RemainTime = OneWeekSec - CurWeekSec + OneWeekLotterySec
    end
    return RemainTime
end

function JumboCactpotLottoryCeremonyMgr:GetCurRaffleRound()
    return self.RaffleRound
end

function JumboCactpotLottoryCeremonyMgr:GetCurRoundRewardNum(Color)
    local NeedText = ""
    if Color ~= nil and type(Color) == "string" and self.CurRoundRewardNum ~= nil then
        NeedText = RichTextUtil.GetText(tostring(self.CurRoundRewardNum), Color)
    end
    return NeedText
end

--- @type 检测是否是仙彩的NpcID
function JumboCactpotLottoryCeremonyMgr:CheckIsJumboNpc(ResID)
    local RelatedNpcID = JumboCactpotDefine.RelatedNpcID
    for _, NpcID in pairs(RelatedNpcID) do
        if ResID == NpcID then
            return true
        end
    end
    return false
end

--- @type 检测是否是仙彩射箭的Monster_虽然长得像个Npc
function JumboCactpotLottoryCeremonyMgr:CheckIsJumboMonster(ResID)
    local IDList = JumboCactpotDefine.CeremoneyShootMonsterID
    for _, MonsterID in pairs(IDList) do
        if ResID == MonsterID then
            return true
        end
    end
    return false
end

--- @type 出现倒计时提示
function JumboCactpotLottoryCeremonyMgr:ShowCountTip(RaffleRound, SubTime)
    if not self.bEnterJumbArea then
        local bEnterArea = self:CheckIsInJumbArea(MajorUtil.GetMajorEntityID())
        if not bEnterArea then
            _G.FLOG_INFO("bEnterJumbArea = false")
            return
        else
            self.bEnterJumbArea = bEnterArea
        end
    end
    local Cfg = FairycolorRaffleTimeCfg:FindCfgByKey(RaffleRound + 1)
    if Cfg == nil then
        _G.FLOG_ERROR("FairycolorRaffleTimeCfg Error")
        return
    end
    local Params = {}
    Params.RedTime = 10
    Params.TimeInterval = 1
    Params.TimeDelay = 0
    Params.BeginTime = tonumber(Cfg.WaitTime) - SubTime
    Params.CountDownLoopSound = JumboCactpotDefine.JumboCeremoneyAudioAssetPath.CountDown
    Params.StartTitleText = LSTR(240003) -- 抽奖开始
    UIViewMgr:ShowView(UIViewID.InfoCountdownTipsView, Params)
end

function JumboCactpotLottoryCeremonyMgr:HideCountDownTip()
    if UIViewMgr:IsViewVisible(UIViewID.InfoCountdownTipsView) then
        UIViewMgr:HideView(UIViewID.InfoCountdownTipsView)
    end
end

--- @type 如果是自己中将出现中将Tip
function JumboCactpotLottoryCeremonyMgr:TryShowGetRewardPanel(RoleLists, JdCoinNum)
    for _, v in ipairs(RoleLists) do
        local RoleId = v
        local bIsMajor = MajorUtil.IsMajorByRoleID(RoleId)
        if bIsMajor then
            self:ShowGetRewardPanel(JdCoinNum)
            break
        end
    end
end

function JumboCactpotLottoryCeremonyMgr:ShowGetRewardPanel(JdCoinNum)
    local Data = {}
    local JDCoinID = SCORE_TYPE.SCORE_TYPE_KING_DEE
    local Cfg = ItemCfg:FindCfgByKey(JDCoinID)
    local Temp = {}
    Temp.ID = JDCoinID
    Temp.Num = JdCoinNum
    Temp.ItemName = ItemCfg:GetItemName(JDCoinID)
    Temp.Icon = ItemCfg.GetIconPath(Cfg.IconID)
    table.insert(Data, Temp)

    local ListVM = _G.GoldSauserMgr:UpdateRewardListVM(Data)
    local Title = LSTR(240004) -- 获得奖励
    _G.GoldSauserMgr:ShowCommRewardPanel(ListVM, Title)
end

--- @type 缓存中奖人员名单
function JumboCactpotLottoryCeremonyMgr:GetCachLottoryList()
    return self.CachLottoryListID
end

--- @type 检查是否有中奖人员列表
function JumboCactpotLottoryCeremonyMgr:CheckHasLottoryList()
    return self.CachLottoryListID ~= nil and #self.CachLottoryListID > 0
end

function JumboCactpotLottoryCeremonyMgr:CheckRoleIDHasMajor()
    local RoleIDList = self.CachLottoryListID
    if RoleIDList == nil then
        return false
    end
    for _, RoldID in ipairs(RoleIDList) do
        if RoldID == MajorUtil.GetMajorRoleID() then
            return true
        end
    end
    return false
end

function JumboCactpotLottoryCeremonyMgr:SetRaffleRewardNum(Num)
    self.CachRaffleRewardNum = Num
end

--- @type 出结果协议晚于掉落协议时触发
function JumboCactpotLottoryCeremonyMgr:TryShowGetRewardPanelByCach()
    if self.CachRaffleRewardNum ~= nil then
        self:ShowGetRewardPanel(self.CachRaffleRewardNum)
        self.CachRaffleRewardNum = nil
    end
end


return JumboCactpotLottoryCeremonyMgr
