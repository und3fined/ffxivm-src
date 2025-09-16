local LuaClass = require("Core/LuaClass")
local MgrBase = require("Common/MgrBase")
local ProtoCS = require("Protocol/ProtoCS")
local ProtoCommon = require("Protocol/ProtoCommon")
local GameNetworkMgr = require("Network/GameNetworkMgr")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local EventID = require("Define/EventID")
local FashionDecorateCfg = require("TableCfg/FashionDecorateCfg")
local FashionDecoVM = require("Game/FashionDeco/VM/FashionDecoVM")
local EmotionMgr = require("Game/Emotion/EmotionMgr")
local ItemCfg = require("TableCfg/ItemCfg")
local FashionDecoDefine = require("Game/FashionDeco/VM/FashionDecoDefine")
local WeatherUtil = require("Game/Weather/WeatherUtil")
local FuncCfg = require("TableCfg/FuncCfg")
local SaveKey = require("Define/SaveKey")
local ClientGlobalCfg = require("TableCfg/ClientGlobalCfg")
local ProtoRes = require("Protocol/ProtoRes")
local SingBarMgr = require("Game/Interactive/SingBar/SingBarMgr")
local CommSideBarUtil = require("Utils/CommSideBarUtil")
local CommonSelectSidebarDefine = require("Game/Common/Frame/Define/CommonSelectSideBarDefine")
local UIViewID = require("Define/UIViewID")
local ChangeRoleCfg = require("TableCfg/ChangeRoleCfg")
local USaveMgr = _G.UE.USaveMgr
local FASHION_DECORTTE_CS_CMD = ProtoCS.CS_CMD
local CS_CMD = ProtoCS.CS_CMD
local FASHION_DECORTTE_SUB = ProtoCS.Role.FashionDecorate
local FASHION_DECORTTE_SUB_ID = FASHION_DECORTTE_SUB.CsFashionDecorateCmd
local LSTR
local PWorldMgr
local MsgTipsUtil
local BagMgr
local TimerMgr
local MountMgr
local FishMgr
local ModuleOpenMgr
local EventMgr
local InteractiveMgr
local UIViewMgr
local RideShootingMgr

---@class FashionDecoMgr : MgrBase
local FashionDecoMgr = LuaClass(MgrBase)

function FashionDecoMgr:OnInit()
    self.INF = 0.000000001				---起步速度
    self.bIsOurDoorLastCheck = false
    self.bPauseAutoUse = false
    local Cfg = ClientGlobalCfg:FindCfgByKey(ProtoRes.client_global_cfg_id.GLOBAL_CFG_FASHIONDECO_MAXCOLLECTNUM)
	if (Cfg ~= nil) then
		self.GLOBAL_CFG_FASHIONDECO_MAXCOLLECTNUM = Cfg.Value[1]
	end
    self.LastWearByClick = false
    self.IsInitByNet = false
    self.CurrentMajorLockMap={}
    for _,v in pairs(FashionDecoDefine.FashionDecorateHiddenPriority) do
        self.CurrentMajorLockMap[v] = false
    end
end

function FashionDecoMgr:OnBegin()

    LSTR = _G.LSTR
    PWorldMgr = _G.PWorldMgr
    MsgTipsUtil = _G.MsgTipsUtil
    BagMgr = _G.BagMgr
    TimerMgr = _G.TimerMgr
    MountMgr = _G.MountMgr
    FishMgr = _G.FishMgr
    ModuleOpenMgr = _G.ModuleOpenMgr
    EventMgr = _G.EventMgr
    InteractiveMgr = _G.InteractiveMgr
    TimeUtil = _G.TimeUtil
    UIViewMgr = _G.UIViewMgr
    RideShootingMgr = _G.RideShootingMgr
    self.TimerID = TimerMgr:AddTimer(self, self.OnUpdateTime, 0, 1, -1)
    BagMgr:RegisterItemUsedFun(ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_ACCESSORY, self.IsItemUsed)
    self.CurrentMajorLockMap={}
    for _,v in pairs(FashionDecoDefine.FashionDecorateHiddenPriority) do
        self.CurrentMajorLockMap[v] = false
    end
end

function FashionDecoMgr.IsItemUsed(CurResID)
    local Cfg = ItemCfg:FindCfgByKey(CurResID)
    if Cfg == nil then
        return false
    end

    if (Cfg.ItemType ~= ProtoCommon.ITEM_TYPE_DETAIL.COLLAGE_ACCESSORY) then
        return false
    end
    local FindFuncCfg = FuncCfg:FindCfgByKey(Cfg.UseFunc)
		if FindFuncCfg == nil then return false end
    local bResult = FashionDecoVM:IsItemUnlocked(FindFuncCfg.Func[1].Value[1])
    return bResult
end
--某个角色是否在读条
function FashionDecoMgr:IsFashionDecoSing(InEntityID)
    return FashionDecoVM:IsFashionDecoSing(InEntityID)
end
function FashionDecoMgr:OnEnd()
    --关闭屋内屋外检测
    if self.TimerID ~= nil then
        TimerMgr:CancelTimer(self.TimerID)
        self.TimerID = nil
    end

end

function FashionDecoMgr:OnShutdown()

end

function FashionDecoMgr:OnRegisterTimer()

end

-- Event回调注册 -- Start
function FashionDecoMgr:OnRegisterGameEvent()
    self:RegisterGameEvent(EventID.ActorVMCreate, self.OnGameEventActorVMCreate)--角色创建
    self:RegisterGameEvent(EventID.PWorldMapEnter, self.OnGameEventEnter)--进入世界
    self:RegisterGameEvent(EventID.PWorldMapExit, self.OnGameEventExit)--离开世界
    self:RegisterGameEvent(EventID.UpdateOrnamentMode, self.OnUpdateOrnamentState)
    self:RegisterGameEvent(EventID.ActorVelocityUpdate, self.OnGameEventActorVelocityUpdate)--玩家速度更新
    self:RegisterGameEvent(EventID.MountCall, self.OnGameEventMountCall)			-- 上坐骑
	self:RegisterGameEvent(EventID.MountBack, self.OnGameEventMountBack)            --下坐骑
    self:RegisterGameEvent(EventID.PostEmotionEnter, self.OnGameEventPostEmotionEnter) --动作表情开始
	self:RegisterGameEvent(EventID.PostEmotionEnd, self.OnGameEventPostEmotionEnd) --动作表情结束
    self:RegisterGameEvent(EventID.MajorSingBarBegin, self.OnGameEventShowSingBarBegin) --主角吟唱条开始
    self:RegisterGameEvent(EventID.MajorSingBarBreak, self.OnGameEventShowMajorAllOrnament) --主角吟唱条中断
    self:RegisterGameEvent(EventID.MajorSingBarOver, self.OnGameEventShowSingBarOver)   --主角吟唱条结束
    self:RegisterGameEvent(EventID.OthersSingBarBegin, self.OnGameEventHideUmbrellaByEntityID)  --其他人吟唱条开始 
    self:RegisterGameEvent(EventID.OthersSingBarBreak, self.OnGameEventShowAllOrnamentByEntityID)--其他人吟唱条中断
    self:RegisterGameEvent(EventID.EnterWater, self.OnGameEventHideAllOrnamentByEntityIDAndULongBySwim)  	-- 开始游泳
	self:RegisterGameEvent(EventID.ExitWater, self.OnGameEventEndSwimming)  		-- 结束游泳
    self:RegisterGameEvent(EventID.MusicPerformanceEntityStart, self.OnGameEventHideUmbrellaByEntityID)  	-- 开始演奏
	self:RegisterGameEvent(EventID.MusicPerformanceEntityEnd, self.OnGameEventShowAllOrnamentByEntityID)  		-- 结束演奏
    self:RegisterGameEvent(EventID.EnterGatherState, self.OnGameEventHideMajorUmbrella)			--进入主角采集状态
	self:RegisterGameEvent(EventID.MiniGameMajorEnterStartMode, self.OnGameEventHideMajorUmbrella)	--进入金蝶小游戏
    self:RegisterGameEvent(EventID.MiniGameMajorEnterQuitMode, self.OnGameEventShowMajorAllOrnament)--离开金蝶小游戏
	self:RegisterGameEvent(EventID.OnMagicCardStart, self.OnGameEventHideMajorUmbrella)	--进入幻卡小游戏
    self:RegisterGameEvent(EventID.OnMagicCardExit, self.OnGameEventShowMajorAllOrnament)--离开幻卡小游戏
    self:RegisterGameEvent(EventID.RideShootingWorldStart, self.OnGameEventHideMajorAllOrnament)--空军小游戏
    self:RegisterGameEvent(EventID.RideShootingShowAllAvatarPart, self.OnGameEventHideMajorAllOrnament)--空军小游戏结算
    self:RegisterGameEvent(EventID.RideShootingWorldEnd, self.OnGameEventShowMajorAllOrnament)--空军小游戏
    self:RegisterGameEvent(EventID.LeapOfFaithGameStart, self.OnGameEventHideMajorAllOrnament)--跳跳乐
    self:RegisterGameEvent(EventID.LeapOfFaithGameEndAndLeave, self.OnGameEventShowMajorAllOrnament)--跳跳乐小游戏
    self:RegisterGameEvent(EventID.CrafterAllExitAllState, self.OnGameEventShowAllOrnamentByEntityID) --离开其他人采集状态
    self:RegisterGameEvent(EventID.OthersEnterGatherState, self.OnGameEventHideUmbrellaByEntityID)	--退出其他人采集状态
    --self:RegisterGameEvent(EventID.CrafterExitRecipeState, self.OnGameEventShowAllOrnamentByEntityID) --所有人离开制作状态便会通知
    self:RegisterGameEvent(EventID.CrafterAllEnterRecipeState, self.OnGameEventHideAllOrnamentByEntityID)--所有人进入制作状态便会通知
    self:RegisterGameEvent(EventID.HoldWeaponStateAllEnd, self.OnGameEventHoldWeaponStateAllEnd)
    self:RegisterGameEvent(EventID.MountPreCallStart, self.OnGameEventHideUmbrellaByEntityID)
    self:RegisterGameEvent(EventID.SingBarAllOver, self.OnGameEventShowAllOrnamentByEntityID)
    self:RegisterGameEvent(EventID.OtherCharacterDead,self.OnGameEventOtherCharacterDeadHideAllOrnamentByEntityID)
    self:RegisterGameEvent(EventID.MajorDead,self.OnGameEventHideMajorAllOrnament)
    self:RegisterGameEvent(EventID.ActorReviveNotify,self.OnGameEventActorReviveNotify)
    self:RegisterGameEvent(EventID.SitToStandAllEnd, self.OnGameEventHoldWeaponStateAllEnd)
    self:RegisterGameEvent(EventID.FisherManFishing, self.OnGameEventHideAllOrnamentByEntityID)--所有人进入制作状态便会通知FisherManFishin
    self:RegisterGameEvent(EventID.FishAllEnd, self.OnGameEventHoldWeaponStateAllEnd)
    self:RegisterGameEvent(EventID.FantasiaSuccessChangeRole, self.UnWearAllCloth) --性别 种族变更
    self:RegisterGameEvent(EventID.SitStartEvent, self.OnGameEventHideAllOrnamentByEntityIDAndULong)
    self:RegisterGameEvent(EventID.Attr_Change_ChangeRoleProfile, self.OnGameEventChangeRoleIDChanged)
    self:RegisterGameEvent(EventID.NetworkReconnected, 		self.OnNetworkReconnected) 			-- 断线重连 
    self:RegisterGameEvent(EventID.BeginTrueJump, 		self.OnjumpStart)
    self:RegisterGameEvent(EventID.FashionDecorateShowThirdPersonAll,self.OnGameEventShowAllOrnamentByEntityID)
    self:RegisterGameEvent(EventID.PlayItemUsedPlayATLEnd,self.OnGameEventPlayItemUsedPlayATLEnd)
end
function FashionDecoMgr:OnjumpStart(Param)
    if Param.ULongParam1 ~= nil and ActorUtil.IsPlayerOrMajor(Param.ULongParam1) then
        FashionDecoVM:StopMontageByEntityID(Param.ULongParam1)
    end

end
function FashionDecoMgr:UnWearAllCloth()
    self:SendUnClothing(FashionDecoDefine.FashionDecoType.Umbrella)
    self:SendUnClothing(FashionDecoDefine.FashionDecoType.Wing)
end
function FashionDecoMgr:OnGameEventShowSingBarBegin(EntityID, SingStateID)
    --使用特殊的需要走另一个通知,58是使用特殊道具，33是坐骑 605893使用烟花 605896烟花之境-气泡酒
    if SingStateID ~= nil and SingStateID ~= 0 then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = true
        self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Umbrella,-1)
    end
end
function FashionDecoMgr:OnGameEventShowSingBarOver(EntityID, IsBreak, SingStateID)

    --使用特殊的需要走另一个通知,58是使用特殊道具，33是坐骑 605893使用烟花 605896烟花之境-气泡酒
    if SingStateID == 33 then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = false
    end
    if SingStateID ~= nil and SingStateID ~= 0 and SingStateID ~= 58 and SingStateID ~= 33 and SingStateID ~= 243 and SingStateID ~= 605893 and SingStateID ~= 605896 then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = false
        if self:CheckIsInSpecialState(MajorUtil.GetMajorEntityID(),FashionDecoDefine.FashionDecorateHiddenPriority.Common) then
            return
        end
        self:ChangeOrnamentVisibleState(true,FashionDecoDefine.FashionDecoType.Max,-1)
    end

end
function FashionDecoMgr:OnGameEventChangeRoleIDChanged(Params)
    if not Params then return end
	local EntityID = Params.ULongParam1
    local ChangeName = Params.StringParam1
	local bBecomeHuman = false
    if ChangeName == "" then
        bBecomeHuman = false
    else
        bBecomeHuman = true
    end
    if bBecomeHuman  then
        if MajorUtil.IsMajor(EntityID) then
            self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.ChangeRole] = true
            self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,-1)
        else
            self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,EntityID)
        end
    else
        if MajorUtil.IsMajor(EntityID) then
            self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.ChangeRole] = false
            if self:CheckIsInSpecialState(MajorUtil.GetMajorEntityID(),FashionDecoDefine.FashionDecorateHiddenPriority.ChangeRole) then
                return
            end
            self:ChangeOrnamentVisibleState(true,FashionDecoDefine.FashionDecoType.Max,-1)
        else
            if self:CheckIsInSpecialState(EntityID,FashionDecoDefine.FashionDecorateHiddenPriority.ChangeRole) then
                return
            end
            self:ChangeOrnamentVisibleState(true,FashionDecoDefine.FashionDecoType.Max,EntityID)
        end

    end
end
function FashionDecoMgr:HasOrnamentVisibleLocked()
    for _,v in pairs(FashionDecoDefine.FashionDecorateHiddenPriority) do
        if self.CurrentMajorLockMap[v]  then
            return true
        end
    end
    return false
end
--改变时尚配饰显隐
function FashionDecoMgr:ChangeOrnamentVisibleState(bVisible,InType,EntityID)
    if bVisible  then
        if EntityID == -1 then
            local MajorActor = MajorUtil.GetMajor()
            --有可能不是baseCharacter
            if MajorActor ~= nil and MajorActor.ShowOrnamentCompByType ~= nil  then
                if not self:HasOrnamentVisibleLocked() then
                    MajorActor:ShowOrnamentCompByType(InType)
                end
            end
        else
            local Actor = ActorUtil.GetActorByEntityID(EntityID)
            --有可能不是baseCharacter
            if Actor ~= nil and Actor.ShowOrnamentCompByType ~= nil  and ActorUtil.IsPlayerOrMajor(EntityID)   then
                if ActorUtil.IsMajor(EntityID)  then
                    if not self:HasOrnamentVisibleLocked() then
                        Actor:ShowOrnamentCompByType(InType)
                    end
                else
                    Actor:ShowOrnamentCompByType(InType)
                end

            end
        end

    else
        if EntityID == -1 then
            local MajorActor = MajorUtil.GetMajor()
            if MajorActor ~= nil and MajorActor.HideOrnamentCompByType ~= nil then
                if self.SendClothingTimerHandler ~= nil then
                    TimerMgr:CancelTimer( self.SendClothingTimerHandler)
                    self.SendClothingTimerHandler = nil
                end
                FashionDecoVM:StopMontageByEntityID(MajorUtil.GetMajorEntityID())
                MajorActor:HideOrnamentCompByType(InType)
            end
        else
            local Actor = ActorUtil.GetActorByEntityID(EntityID)
            if Actor ~= nil  and ActorUtil.IsPlayerOrMajor(EntityID) and Actor.HideOrnamentCompByType ~= nil  then
                FashionDecoVM:StopMontageByEntityID(EntityID)
               Actor:HideOrnamentCompByType(InType)
            end
        end
    end
end
function FashionDecoMgr:OnNetworkReconnected(Params)
    --print("ccppeng stop montage")
    FashionDecoVM:StopMontageByEntityID(MajorUtil.GetMajorEntityID())
end
--显示指定角色所有时尚配饰
function FashionDecoMgr:OnGameEventPlayItemUsedPlayATLEnd(InEntityID,VfxID)
    --重生之境
    if VfxID ~=580 then
        return
    end
    if MajorUtil.GetMajorEntityID() == InEntityID then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = false
    end
    if self:CheckIsInSpecialState(InEntityID,FashionDecoDefine.FashionDecorateHiddenPriority.Common) then
        return
    end
    self:ChangeOrnamentVisibleState(true,FashionDecoDefine.FashionDecoType.Max,InEntityID)
end
--显示指定角色所有时尚配饰
function FashionDecoMgr:OnGameEventShowAllOrnamentByEntityID(InEntityID)
    if MajorUtil.GetMajorEntityID() == InEntityID then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = false
    end
    if self:CheckIsInSpecialState(InEntityID,FashionDecoDefine.FashionDecorateHiddenPriority.Common) then
        return
    end
    self:ChangeOrnamentVisibleState(true,FashionDecoDefine.FashionDecoType.Max,InEntityID)
end
--隐藏指定角色所有时尚配饰
function FashionDecoMgr:OnGameEventHideAllOrnamentByEntityID(InEntityID)
    if MajorUtil.GetMajorEntityID() == InEntityID then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = true
    end
    self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,InEntityID)
end
--隐藏指定角色雨伞时尚配饰
function FashionDecoMgr:OnGameEventHideUmbrellaByEntityID(InEntityID)
    if MajorUtil.GetMajorEntityID() == InEntityID then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = true
    end
    self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Umbrella,InEntityID)
end

--隐藏主角色时尚配饰雨伞
function FashionDecoMgr:OnGameEventHideMajorUmbrella()

    self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = true

    self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Umbrella,-1)
end
--隐藏主角色所有时尚配饰
function FashionDecoMgr:OnGameEventHideMajorAllOrnament()

    self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = true

    self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,-1)
end
--显示主角色所有时尚配饰
function FashionDecoMgr:OnGameEventShowMajorAllOrnament()

    self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = false
    if self:CheckIsInSpecialState(MajorUtil.GetMajorEntityID(),FashionDecoDefine.FashionDecorateHiddenPriority.Common) then
        return
    end
    self:ChangeOrnamentVisibleState(true,FashionDecoDefine.FashionDecoType.Max,-1)
end

--隐藏指定角色所有时尚配饰
function FashionDecoMgr:OnGameEventHideAllOrnamentByEntityIDAndULong(Param)
    if MajorUtil.GetMajorEntityID() == Param.ULongParam1 then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = true
    end
    self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,Param.ULongParam1)
end
--隐藏指定角色所有时尚配饰
function FashionDecoMgr:OnGameEventHideAllOrnamentByEntityIDAndULongBySwim(Param)
    if MajorUtil.GetMajorEntityID() == Param.ULongParam1 then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = true
    end
    self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,Param.ULongParam1)
    if ActorUtil.IsMajor(Param.ULongParam1) then
        local MajorActor = MajorUtil.GetMajor()
        if MajorActor ~= nil then
            MajorActor:SetWetBySwim(true)
        end
    end
end

--显示所有时尚配饰
function FashionDecoMgr:OnGameEventEndSwimming(Param)
    if MajorUtil.GetMajorEntityID() == Param.ULongParam1 then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = false
    end
    if self:CheckIsInSpecialState(Param.ULongParam1,FashionDecoDefine.FashionDecorateHiddenPriority.Common) then
        return
    end
    self:ChangeOrnamentVisibleState(true,FashionDecoDefine.FashionDecoType.Max,Param.ULongParam1)
    FashionDecoVM:ReSetWetToDryRestTime(Param.ULongParam1,false)
end
--显示所有时尚配饰
function FashionDecoMgr:OnGameEventActorReviveNotify(Param)
    if MajorUtil.GetMajorEntityID() == Param.ULongParam1 then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = false
    end
    if self:CheckIsInSpecialState(Param.ULongParam1,FashionDecoDefine.FashionDecorateHiddenPriority.Common) then
        return
    end
    self:ChangeOrnamentVisibleState(true,FashionDecoDefine.FashionDecoType.Max,Param.ULongParam1)
end
function FashionDecoMgr:OnGameEventHoldWeaponStateAllEnd(Param)
    if MajorUtil.GetMajorEntityID() == Param.ULongParam1 then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = false
    end
    if self:CheckIsInSpecialState(Param.ULongParam1,FashionDecoDefine.FashionDecorateHiddenPriority.Common) or EmotionMgr:CheckIsInEmote(Param.ULongParam1) then
        return
    end
    self:ChangeOrnamentVisibleState(true,FashionDecoDefine.FashionDecoType.Max,Param.ULongParam1)
end
--播放动作
function FashionDecoMgr:OnGameEventPostEmotionEnter(Param)
    --坐下临时处理，可能还有其他动作排除
    if self.IgnoreMotionMap == nil then
        self.IgnoreMotionMap = {}
        self.IgnoreMotionMap[68] = true
        self.IgnoreMotionMap[69] = true
        self.IgnoreMotionMap[70] = true
        self.IgnoreMotionMap[71] = true
        self.IgnoreMotionMap[72] = true
        self.IgnoreMotionMap[73] = true
        self.IgnoreMotionMap[74] = true
        self.IgnoreMotionMap[75] = true
        self.IgnoreMotionMap[76] = true
        self.IgnoreMotionMap[77] = true
        self.IgnoreMotionMap[78] = true
        self.IgnoreMotionMap[79] = true
        self.IgnoreMotionMap[80] = true
        self.IgnoreMotionMap[50] = true
        self.IgnoreMotionMap[52] = true
    end
        if self.IgnoreMotionMap ~= nil and self.IgnoreMotionMap[Param.IntParam1] ~= nil then
            return
        end
        --88是躺下，断点打不到也是奇怪
    if  Param.IntParam1 == 88 then
        if MajorUtil.GetMajorEntityID() == Param.ULongParam1 then
            self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = true
        end
        self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,Param.ULongParam1)
    else
        if MajorUtil.GetMajorEntityID() == Param.ULongParam1 then
            self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = true
        end
        self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Umbrella,Param.ULongParam1)
    end
    FashionDecoVM:StopMontageByEntityID(Param.ULongParam1)

end
--播放动作表情结束
function FashionDecoMgr:OnGameEventPostEmotionEnd(Param)
    --50和52是坐椅子和坐地上
    if MajorUtil.GetMajorEntityID() == Param.ULongParam1 and SingBarMgr:GetMajorIsSinging() then
        return
    end
    --local IsSit,_ = _G.EmotionMgr:IsSitState(MajorUtil.GetMajorEntityID()) 
	--if IsSit then	--坐下
	--return 
	--end
    if MountMgr:IsEntitySing(Param.ULongParam1) or FishMgr:IsEntityInFishing(Param.ULongParam1) then
        return
    end
    --88是起床
    if Param.IntParam1 ~= 116 and Param.IntParam1 ~= 50 and Param.IntParam1 ~= 52 and Param.IntParam1 ~= 88  then
        if MajorUtil.GetMajorEntityID() == Param.ULongParam1 then
            self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = false
        end
        if self:CheckIsInSpecialState(Param.ULongParam1,FashionDecoDefine.FashionDecorateHiddenPriority.Common) or EmotionMgr:CheckIsInEmote(Param.ULongParam1) then
            return
        end
        self:ChangeOrnamentVisibleState(true,FashionDecoDefine.FashionDecoType.Max,Param.ULongParam1)
    end
end
function FashionDecoMgr:OnGameEventOtherCharacterDeadHideAllOrnamentByEntityID(Param)
    if MajorUtil.GetMajorEntityID() == Param.ULongParam1 then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = true
    end
    self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,Param.ULongParam1)

end
--坐骑召唤
function FashionDecoMgr:OnGameEventMountCall(Param)
    if MajorUtil.GetMajorEntityID() == Param.EntityID then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Mount] = true
    end
    --local Actor = ActorUtil.GetActorByEntityID(Param.EntityID)
    --if Actor ~= nil and Actor:IfInChangeRole() then
    --    return
    --end
    self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,Param.EntityID)
end


--坐骑召回
function FashionDecoMgr:OnGameEventMountBack(Param)

    if MajorUtil.GetMajorEntityID() == Param.EntityID then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Mount] = false
    end

    if self:CheckIsInSpecialState(Param.EntityID,FashionDecoDefine.FashionDecorateHiddenPriority.Mount) then
        return
    end



    self:ChangeOrnamentVisibleState(true,FashionDecoDefine.FashionDecoType.Max,Param.EntityID)
end

function FashionDecoMgr:ShowFashionDecoMgrMainPanel()
	if UIViewMgr:IsViewVisible(UIViewID.CommEasytoUseView) then
		UIViewMgr:HideView(UIViewID.CommEasytoUseView)
	end

	CommSideBarUtil.ShowSideBarByType(CommonSelectSidebarDefine.PanelType.EasyToUse,CommonSelectSidebarDefine.EasyToUseTabType.FashionDeco, {bOpen = true})
end

--角色速度更新就停止表演动作播放
function FashionDecoMgr:OnGameEventActorVelocityUpdate(InParams)
	local EntityID = InParams.ULongParam1
    local Actor = ActorUtil.GetActorByEntityID(EntityID)

    if Actor == nil then return end

	local Velocity = Actor.CharacterMovement.Velocity

	if Velocity:Size() < self.INF then
		return
	end
    if FashionDecoVM:IsFashionDecoSing(EntityID) then
        FashionDecoVM:StopSingBar(EntityID)
    end
    FashionDecoVM:StopMontageByEntityID(EntityID)
end

--更新时尚配饰状态
function FashionDecoMgr:OnUpdateOrnamentState(Inparams)

	local bIsInOrnamentMode = Inparams.BoolParam1
	local bIsInOrnamentMoveMode = Inparams.BoolParam2
    local MajorActor = MajorUtil.GetMajor()
    if MajorActor ~= nil then
        FashionDecoVM:SetFashionDecorateState(FashionDecoVM:IfHaveDressedEquipment() and not MajorActor:CheckFashionDecorateHiddenState(FashionDecoDefine.FashionDecoType.Max))
    end

end


-- 角色创建
function FashionDecoMgr:OnGameEventActorVMCreate(Params)

    if Params.EntityID == MajorUtil.GetMajorEntityID() then
        if not ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDFashionDecorate) then
            return
        end

        self:SendFashionDecoListQuery()
    end
end
--进入世界
function FashionDecoMgr:OnGameEventEnter(Params)
    self.NeedAutoUnWearOnce = true
    self:ClearData()
    local IsInDungeon = PWorldMgr:CurrIsSpecialTypeMap()
    if IsInDungeon then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Map] = true
    end

    if not self:CheckIsInSpecialState(MajorUtil.GetMajorEntityID(),FashionDecoDefine.FashionDecorateHiddenPriority.Map) then
        local tempMajor = MajorUtil.GetMajor()
        if tempMajor ~= nil  then
            tempMajor:ShowOrnamentCompByType(FashionDecoDefine.FashionDecoType.Max)
        end
    end
    if self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Map] then
        local tempMajor = MajorUtil.GetMajor()
        if tempMajor ~= nil  then
            tempMajor:HideOrnamentCompByType(FashionDecoDefine.FashionDecoType.Max)
        end
    end
end
--离开世界
function FashionDecoMgr:OnGameEventExit(Params)
    local IsInDungeon = PWorldMgr:CurrIsSpecialTypeMap()
    if not IsInDungeon then
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Map] = false
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = false
    else
        self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Common] = false
    end
end

-- Event回调注册 -- End

--[[
1.客户端发送:chooseType 非0时，忽略id，服务器设置choosetype，且尝试穿戴
服务器回包:穿戴成功回包:对应choosetype和穿戴后的ID，穿戴失败回包:对应choosetype和ID=0，设置choosetype无论如何只要有，就设置，而穿戴的回包是根据一系列判断来的。
2.客户端发送:chooseType 为0时且ID为0，则服务器choosetype设置为0，服务器回包为choosetype0，id0
3.客户端发送:choosetype 为0且id非0 则服务器指定穿戴且设置choosetype为0，服务器回包为choosetype0，和指定id
4.穿戴翅膀以及后续其他类型拓展装备，客户端发送:choosetype 为0且id非0 服务器则指定穿戴且不设置choosetype，服务器:回包为choosetype0，和指定id
]]
--注册网络事件  --Start
function FashionDecoMgr:OnRegisterNetMsg()
    self:RegisterGameNetMsg(FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE, FASHION_DECORTTE_SUB_ID.CsFashionDecorateQuery, self.OnFashionDecorateQuery)--查询
    self:RegisterGameNetMsg(FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE, FASHION_DECORTTE_SUB_ID.CsFashionDecorateClothing, self.OnClothingCurrentFashionDecorate)--穿衣服和设置自动穿戴选择状态
    self:RegisterGameNetMsg(FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE, FASHION_DECORTTE_SUB_ID.CsFashionDecorateUnClothing, self.OnUnClothingCurrentFashionDecorate)--脱衣服
    self:RegisterGameNetMsg(FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE, FASHION_DECORTTE_SUB_ID.CsFashionDecorateCollect, self.OnCollectCurrentFashionDecorate)--收藏
    self:RegisterGameNetMsg(FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE, FASHION_DECORTTE_SUB_ID.CsFashionDecorateShowNotify, self.OnCallBackNotifyCurrentFashionDecorate)--释放技能
    self:RegisterGameNetMsg(FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE, FASHION_DECORTTE_SUB_ID.CsFashionDecorateUnlock, self.OnReceivedDecorateUnlock)--解锁
    self:RegisterGameNetMsg(FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE, FASHION_DECORTTE_SUB_ID.CsFashionDecorateRead, self.OnReceivedRead)--已读
    self:RegisterGameNetMsg(FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE, FASHION_DECORTTE_SUB_ID.CsFashionDecoratePlay, self.OnSingBarStart)--3P读条
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_ENTER, self.OnVisionEnter)	    --进入视野同步
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_QUERY, self.OnVisionQuery)	    --初次登陆查询
	self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_LEAVE, self.OnVisionLeave)	    --视野离开
    self:RegisterGameNetMsg(CS_CMD.CS_CMD_VISION, ProtoCS.CS_VISION_CMD.CS_VISION_CMD_AVATAR_CHG, self.OnVisionChg)	    --视野内发生变化
end

--首次登陆和切图查询
function FashionDecoMgr:OnFashionDecorateQuery(MsgBody)
	local FashionDecoQueryRsp = MsgBody.Query
    --清除数据
    FashionDecoVM:ClearData()
    --初始化当前装备的武器
    FashionDecoVM:InitCurrentClothingMap(FashionDecoQueryRsp.CurClothing)
    --记录已解锁饰品
    for _,v in ipairs(FashionDecoQueryRsp.Unlocked) do
        --保存数据，flag为红点
        FashionDecoVM:AddNewRecordElemFashionDeco(v.ID,v.Flag,v.UpdateTime)
    end
    --记录收藏物品
    for _,v in ipairs(FashionDecoQueryRsp.CollectedList) do
        FashionDecoVM:AddCollectNew(v)
    end

    local SavedData = USaveMgr.GetInt(SaveKey.FashionDecoSetting, self.ChooseType, false)
    self.LastWearByClick = USaveMgr.GetInt(SaveKey.FashionDecoLastWearWay, self.LastWearByClick and 1 or 0, false)
    if self.LastWearByClick == 0 then
        self.LastWearByClick = false
    elseif self.LastWearByClick == 1 then
        self.LastWearByClick = true
    end
    --设置未查看红点
    FashionDecoVM:SetFashionDecorateBitmapIsNew(FASHION_DECORTTE_SUB.FashionDecorateBitmap.FashionDecorateNew)

    --设置Autouse模式
    if SavedData ~= nil then
        FashionDecoVM:SetCurrentChooseType(SavedData)
    end

    --通知主界面，已更新数据
    EventMgr:SendEvent(EventID.FashionDecorateUpdateData,  FashionDecoVM.CurrentClothingMap)
    self.IsInitByNet = true
    --执行穿戴
    FashionDecoVM:DressUpAllOrnament()
end

--切换场景视野查询
function FashionDecoMgr:OnVisionQuery(MsgBody)
    local localbIsCurMapLeapOf =_G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()
    for _, VEntity in ipairs(MsgBody.Query.Entities or {}) do
        if VEntity.Role  then
            if VEntity.Role.Avatar ~= nil and VEntity.Role.Avatar.Face ~= nil then
                --36和37为后台固定ID,添加记录的玩家装备ID
                FashionDecoVM:AddPlayerEquipMap(VEntity.ID,VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Umbrella],VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Wing])
                local Actor = ActorUtil.GetActorByEntityID(VEntity.ID)
                if Actor ~= nil  and ActorUtil.IsPlayerOrMajor(VEntity.ID)  then
                    local IsInDungeon = PWorldMgr:CurrIsSpecialTypeMap()
                    if VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Umbrella] ~= nil and 
                    VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Umbrella] > 0 then
                        if not IsInDungeon then
                            Actor:SetOrnamentCompData(FashionDecoDefine.FashionDecoType.Umbrella,VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Umbrella])
                            local StateComp = ActorUtil.GetActorStateComponent(VEntity.ID)
                            local IsHoldWeapon = false
                            if StateComp ~= nil  then
                                IsHoldWeapon = StateComp:IsHoldWeaponState()
                            end
                            if Actor:IfInChangeRole() or IsHoldWeapon or ActorUtil.IsInRide(VEntity.ID) or localbIsCurMapLeapOf then
                                self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,VEntity.ID)
                            end
                        end

                    end
                    if VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Wing] ~= nil and
                    VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Wing] > 0 then
                        if not IsInDungeon then
                        Actor:SetOrnamentCompData(FashionDecoDefine.FashionDecoType.Wing,VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Wing])
                        local StateComp = ActorUtil.GetActorStateComponent(VEntity.ID)
                        local IsHoldWeapon = false
                        if StateComp ~= nil  then
                            IsHoldWeapon = StateComp:IsHoldWeaponState()
                        end
                            if Actor:IfInChangeRole() or IsHoldWeapon or ActorUtil.IsInRide(VEntity.ID) or localbIsCurMapLeapOf then
                                self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,VEntity.ID)
                            end
                        end
                    end

                end
            end
        end
    end
end

--离开视野
function FashionDecoMgr:OnVisionLeave(MsgBody)
    for _, VEntityID in ipairs(MsgBody.Leave.Entities or {}) do
        FashionDecoVM:RemovePlayerEquipMap(VEntityID)
    end
end

--视野内发生改变
function FashionDecoMgr:OnVisionChg(MsgBody)
    local localbIsCurMapLeapOf =_G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()
    if MsgBody ~= nil and MsgBody.AvatarChg ~= nil and (MsgBody.AvatarChg.Type == FashionDecoDefine.FashionDecoTypeFaceIndexKey.Umbrella or MsgBody.AvatarChg.Type == FashionDecoDefine.FashionDecoTypeFaceIndexKey.Wing) then
        if MsgBody.AvatarChg.Avatar ~= nil and MsgBody.AvatarChg.Avatar.Face ~= nil then
            if MsgBody.AvatarChg.EntityID == MajorUtil.GetMajorEntityID() then
                return
            end
            local Actor = ActorUtil.GetActorByEntityID(MsgBody.AvatarChg.EntityID)

            if Actor ~= nil then
                local IsInDungeon = PWorldMgr:CurrIsSpecialTypeMap()
                if MsgBody.AvatarChg.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Umbrella] ~= nil then
                    if MsgBody.AvatarChg.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Umbrella] ~= 0 then
                        if not IsInDungeon then
                            Actor:SetOrnamentCompData(FashionDecoDefine.FashionDecoType.Umbrella,MsgBody.AvatarChg.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Umbrella])
                            local StateComp = ActorUtil.GetActorStateComponent(MsgBody.AvatarChg.EntityID)
                            local IsHoldWeapon = false
                            if StateComp ~= nil  then
                                IsHoldWeapon = StateComp:IsHoldWeaponState()
                            end
                            if Actor:IfInChangeRole() or IsHoldWeapon or ActorUtil.IsInRide(MsgBody.AvatarChg.EntityID) or localbIsCurMapLeapOf then
                                self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,MsgBody.AvatarChg.EntityID)
                            end
                        end
                    else
                        Actor:DeleteOrnamentData(FashionDecoDefine.FashionDecoType.Umbrella)
                    end
                end
                if MsgBody.AvatarChg.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Wing] ~= nil then
                    if MsgBody.AvatarChg.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Wing] ~= 0 then
                        if not IsInDungeon then
                            Actor:SetOrnamentCompData(FashionDecoDefine.FashionDecoType.Wing,MsgBody.AvatarChg.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Wing])
                            local StateComp = ActorUtil.GetActorStateComponent(MsgBody.AvatarChg.EntityID)
                            local IsHoldWeapon = false
                            if StateComp ~= nil  then
                                IsHoldWeapon = StateComp:IsHoldWeaponState()
                            end
                            if Actor:IfInChangeRole() or IsHoldWeapon or ActorUtil.IsInRide(MsgBody.AvatarChg.EntityID) or localbIsCurMapLeapOf then
                                self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,MsgBody.AvatarChg.EntityID)
                            end
                        end
                    else
                        Actor:DeleteOrnamentData(FashionDecoDefine.FashionDecoType.Wing)
                    end
                end
            end
        end
    end
end
--进入视野回包
function FashionDecoMgr:OnVisionEnter(MsgBody)
    local localbIsCurMapLeapOf =_G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith()
    for _, VEntity in ipairs(MsgBody.Enter.Entities or {}) do
        if VEntity.Role then
            if VEntity.Role.Avatar ~= nil and VEntity.Role.Avatar.Face ~= nil then
                FashionDecoVM:AddPlayerEquipMap(VEntity.ID,VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Umbrella],VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Wing])
                local Actor = ActorUtil.GetActorByEntityID(VEntity.ID)
                if Actor ~= nil and ActorUtil.IsPlayerOrMajor(VEntity.ID)  then
                    if VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Umbrella] ~= nil and
                     VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Umbrella] > 0 then
                        if PWorldMgr:CurrIsSpecialTypeMap() then
                            return
                        end
                        Actor:SetOrnamentCompData(1,VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Umbrella])
                        local StateComp = ActorUtil.GetActorStateComponent(VEntity.ID)
                        local IsHoldWeapon = false
                        if StateComp ~= nil  then
                            IsHoldWeapon = StateComp:IsHoldWeaponState()
                        end
                        if Actor:IfInChangeRole() or IsHoldWeapon or ActorUtil.IsInRide(VEntity.ID) or localbIsCurMapLeapOf then
                            self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,VEntity.ID)
                        end
                    end
                    if VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Wing]~= nil and
                     VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Wing] > 0 then
                        if PWorldMgr:CurrIsSpecialTypeMap() then
                            return
                        end
                        Actor:SetOrnamentCompData(1,VEntity.Role.Avatar.Face[FashionDecoDefine.FashionDecoTypeFaceIndexKey.Wing])
                        local StateComp = ActorUtil.GetActorStateComponent(VEntity.ID)
                        local IsHoldWeapon = false
                        if StateComp ~= nil  then
                            IsHoldWeapon = StateComp:IsHoldWeaponState()
                        end
                        if Actor:IfInChangeRole() or IsHoldWeapon or ActorUtil.IsInRide(VEntity.ID) or localbIsCurMapLeapOf then
                            self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Max,VEntity.ID)
                        end
                    end
                end
            end
        end
    end
end
--脱衣服回包
function FashionDecoMgr:OnUnClothingCurrentFashionDecorate(MsgBody)
    local MajorActor = MajorUtil.GetMajor()
    if MajorActor ~= nil and MsgBody.Unclothing ~=nil and FashionDecoVM.CurrentClothingMap ~= nil  then
        FashionDecoVM:StopMontageByEntityID(MajorUtil.GetMajorEntityID())
        FashionDecoVM:SetMainVMWeatBtn(FashionDecoVM.CurrentClothingMap[MsgBody.Unclothing.DecorateType],LSTR(1030010),true)
        MajorActor:DeleteOrnamentData(MsgBody.Unclothing.DecorateType)
        FashionDecoVM:UpdateItemClothingState(FashionDecoVM.CurrentClothingMap[MsgBody.Unclothing.DecorateType],false)
        FashionDecoVM:DeleteCurrentEquip(MsgBody.Unclothing.DecorateType)
        EventMgr:SendEvent(EventID.FashionDecorateUpdateData,  FashionDecoVM.CurrentClothingMap)
    end
end

--收藏回包
function FashionDecoMgr:OnCollectCurrentFashionDecorate(MsgBody)
    if MsgBody.Collect ~=nil  then

        FashionDecoVM:UpdateCollectState(MsgBody.Collect.ID,MsgBody.Collect.IsCollect)
        if FashionDecoVM:GetCurrentChooseType() == FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByLike and not FashionDecoVM:CheckHasCollect() then
            FashionDecoMgr:SetCurrentChooseType(FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByLast)
            MsgTipsUtil.ShowTips(LSTR(1030014))
        end
        if MsgBody.Collect.IsCollect and self.GLOBAL_CFG_FASHIONDECO_MAXCOLLECTNUM ~= nil and self.GLOBAL_CFG_FASHIONDECO_MAXCOLLECTNUM > 0 then
            local itemCurrentSelectedCfg = FashionDecorateCfg:FindCfgByKey(MsgBody.Collect.ID)
            if itemCurrentSelectedCfg ~= nil then
            MsgTipsUtil.ShowTips(string.format(LSTR(1030017),itemCurrentSelectedCfg.Name,FashionDecoVM:GetCollectNum(),self.GLOBAL_CFG_FASHIONDECO_MAXCOLLECTNUM))-- bodystring.format(LSTR(720008), AchievementDefine.TagetAchievementTotalNum) 
            end
        end
    end
end



--播放技能
function FashionDecoMgr:OnCallBackNotifyCurrentFashionDecorate(MsgBody)
    if MsgBody ~= nil and MsgBody.Show ~= nil then
        FashionDecoVM:PlayUmSkillActionByIndex(MsgBody.Show.EntityID,MsgBody.Show.ID,MsgBody.Show.ActionID)
    end
end

function FashionDecoMgr:OnSingBarStart(MsgBody)
    if MsgBody ~= nil and MsgBody.Play ~= nil and MsgBody.Play.EntityID ~= nil and MajorUtil.GetMajorEntityID() ~= MsgBody.Play.EntityID then
        FashionDecoVM:PlaySingBarAnim(4,MsgBody.Play.EntityID)
        self:ChangeOrnamentVisibleState(false,FashionDecoDefine.FashionDecoType.Umbrella,MsgBody.Play.EntityID)
        local AnimComp = ActorUtil.GetActorAnimationComponent(MsgBody.Play.EntityID)
        if AnimComp ~= nil  then
            AnimComp:PlayQueuedAnimations(self.AnimationQueueCounter)
        end

    end
end

--穿衣服回包和设置AutoUse
function FashionDecoMgr:OnClothingCurrentFashionDecorate(MsgBody)
	local MajorActor = MajorUtil.GetMajor()
    if MajorActor ~= nil and MsgBody.Clothing ~=nil and MsgBody.Clothing.ID ~=nil and MsgBody.Clothing.ID ~= 0  then
        local itemCurrentSelectedCfg = FashionDecorateCfg:FindCfgByKey(MsgBody.Clothing.ID)
        if itemCurrentSelectedCfg ~= nil then
            local MapID = PWorldMgr:GetCurrMapResID()
            local CurWeatherId = WeatherUtil.GetMapWeather(MapID, 0)
            if CurWeatherId == 7 or CurWeatherId == 8 or CurWeatherId == 10  then
                    if false == MajorActor:CheckIsInRainOutDoor() and MsgBody.Clothing.ChooseType ~= 0 then
                        self:SendUnClothing(FashionDecoDefine.FashionDecoType.Umbrella)
                        FashionDecoVM:SetCurrentChooseType(MsgBody.Clothing.ChooseType)
                    return
                    end
            end
            if FashionDecoVM.CurrentClothingMap ~= nil then
                FashionDecoVM:UpdateItemClothingState(FashionDecoVM.CurrentClothingMap[itemCurrentSelectedCfg.DecorationType],false)
            end
            FashionDecoVM:UpdateCurrentEquip(MsgBody.Clothing.ID)
            if FashionDecoVM.CurrentClothingMap ~= nil then
                FashionDecoVM:UpdateItemClothingState(FashionDecoVM.CurrentClothingMap[itemCurrentSelectedCfg.DecorationType],true)
            end
            FashionDecoVM:SetMainVMWeatBtn(MsgBody.Clothing.ID,LSTR(1030009),false)
            MajorActor:SetOrnamentCompData(itemCurrentSelectedCfg.DecorationType,MsgBody.Clothing.ID)
            local tempType = FashionDecoVM:GetTypeByID( MsgBody.Clothing.ID)
            --如果是雨伞的话，会覆盖AutoUseType
            if tempType == FashionDecoDefine.FashionDecoType.Umbrella then
                if MsgBody.Clothing.ChooseType  ~= 0  then
                    self.bLastWearUmbrellaBySetting = true
                    FashionDecoVM:SetCurrentChooseType(MsgBody.Clothing.ChooseType)
                else
                    self.bLastWearUmbrellaBySetting = false
                    self.bPauseAutoUse = true
                end
                self.LastTakeUmbrellaTime = TimeUtil.GetLocalTimeMS()
            end

            --更新主界面
            EventMgr:SendEvent(EventID.FashionDecorateUpdateData,  FashionDecoVM.CurrentClothingMap)
        end
    end
    SingBarMgr:OnBreakSingOver()
    --如果出现0，0情况表示纯设置为正常状态，非自动使用
    if MajorActor ~= nil and MsgBody.Clothing ~=nil and MsgBody.Clothing.ChooseType ~= nil and MsgBody.Clothing.ID == 0  then

        --if MsgBody.Clothing.ChooseType ~= FashionDecoVM:GetCurrentChooseType() then
            --if MsgBody.Clothing.ChooseType == 0 then
               -- _G.TimerMgr:CancelTimer(self.TimerID)
            --else
                --弱网状态下晴天触发自动使用不管
                --_G.TimerMgr:CancelTimer(self.TimerID)
                --self.TimerID = _G.TimerMgr:AddTimer(self, self.OnUpdateTime, 0, 1, -1)
            --end

        --end
        FashionDecoVM:SetCurrentChooseType(MsgBody.Clothing.ChooseType)
    end
end

--解锁
function FashionDecoMgr:OnReceivedDecorateUnlock(MsgBody)
    local FashionDecoUnlockRsp = MsgBody.Unlock

    if FashionDecoUnlockRsp ~= nil and FashionDecoUnlockRsp.ID ~= nil then
        FashionDecoVM:SetFashionDecorateBitmapIsNew(FASHION_DECORTTE_SUB.FashionDecorateBitmap.FashionDecorateNew)
        FashionDecoVM:AddNewRecordElemFashionDeco(FashionDecoUnlockRsp.ID,FASHION_DECORTTE_SUB.FashionDecorateBitmap.FashionDecorateNew,TimeUtil.GetServerTime())
    end
    --教程解锁暂时等策划配置
    --if not _G.ModuleOpenMgr:CheckOpenState(ProtoCommon.ModuleID.ModuleIDFashionDecorate) then
        --local EventParams = _G.EventMgr:GetEventParams()
        --EventParams.Type = TutorialDefine.TutorialConditionType.UnlockRiderItem --新手引导触发类型
        --_G.NewTutorialMgr:OnCheckTutorialStartCondition(EventParams)
    --end
end
function FashionDecoMgr:GetAllReadStatus()
    return FashionDecoVM:GetAllReadStatus()
end
-- 收到阅读
function FashionDecoMgr:OnReceivedRead(MsgBody)
    local FashionDecoReadRsp = MsgBody.Read
    FashionDecoVM:SetElemRead(FashionDecoReadRsp.ID)
end

--注册网络事件  --End

--发送网络包    --Start

--查询时尚配饰信息
function FashionDecoMgr:SendFashionDecoListQuery()
    local MsgID = FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE
    local SubMsgID = FASHION_DECORTTE_SUB_ID.CsFashionDecorateQuery
    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.FashionData = {}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--发送已读
function FashionDecoMgr:SendRead(InID)
    local MsgID = FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE
    local SubMsgID = FASHION_DECORTTE_SUB_ID.CsFashionDecorateRead
    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    MsgBody.Read = {ID = InID}
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end
--发送读条开始
function FashionDecoMgr:SendSingBarStart(InID)
    local MsgID = FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE
    local SubMsgID = FASHION_DECORTTE_SUB_ID.CsFashionDecoratePlay
    local MsgBody = {}
    MsgBody.Cmd = SubMsgID
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end
--发送穿衣服
function FashionDecoMgr:SingAndSendClothing(InID,InbIsUmbrella,InbIsByClickWear)

    local IsCombatState = ActorUtil.IsCombatState(MajorUtil.GetMajorEntityID())
    if self:CheckIsInSpecialState(MajorUtil.GetMajorEntityID()) or IsCombatState then
        MsgTipsUtil.ShowTips(LSTR(1030016))--当前状态无法装备
        return
    end

    local function Callback(bIsInterrupted)
        if not bIsInterrupted then
            local function FuncSendClothing()
                FashionDecoMgr:SendClothing(InID,InbIsUmbrella,InbIsByClickWear)
            end
            self.SendClothingTimerHandler = TimerMgr:AddTimer(self, FuncSendClothing, 1.2)
        end
    end
    self:SendSingBarStart(InID)
    SingBarMgr:MajorSingBySingStateIDWithoutInteractiveID(243, Callback)


end
--发送穿衣服
function FashionDecoMgr:SendClothing(InID,InbIsUmbrella,InbIsByClickWear)

    local MsgID = FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE
    local SubMsgID = FASHION_DECORTTE_SUB_ID.CsFashionDecorateClothing
    local TempChooseType = nil

    if InbIsUmbrella then
        TempChooseType = FashionDecoVM:GetCurrentChooseType()
    else
        TempChooseType = 0
    end

    if InbIsByClickWear then
        TempChooseType = 0
    end
    if InbIsByClickWear ~= nil  then
        self.LastWearByClick = InbIsByClickWear
        self.NeedAutoUnWearOnce = not InbIsByClickWear
        USaveMgr.SetInt(SaveKey.FashionDecoLastWearWay, self.LastWearByClick and 1 or 0, false)
    end

    local MsgBody = {
        Cmd = SubMsgID,
        Clothing ={
            ID = InID,
            ChooseType =  TempChooseType
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

end
function FashionDecoMgr:ClearData()
    FashionDecoVM:OnChangeLevelClearData()
end
--发送播放技能
function FashionDecoMgr:SendPlaySkillAction(InCurrentSelectedID,InID)
    if self:CheckIsInSpecialState(MajorUtil.GetMajorEntityID()) then
        MsgTipsUtil.ShowTips(LSTR(1030016))--当前状态无法装备
        return
    end

    local MsgID = FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE
    local SubMsgID = FASHION_DECORTTE_SUB_ID.CsFashionDecorateCall
    local MsgBody = {
        Cmd = SubMsgID,
        Call ={
            ID = InCurrentSelectedID,
            ActionID =  InID
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

end

--发送自动使用类型
function FashionDecoMgr:SendChooseType(InID)

	--self:SendEquipCommon(FASHION_DECORTTE_SUB_ID.CsFashionDecorateQuery, nil, nil)
    --:SendMoveToBlacklistMsg(MvRoleID, Unfriend, DelEachOther, Remark)
    local MsgID = FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE
    local SubMsgID = FASHION_DECORTTE_SUB_ID.CsFashionDecorateClothing
    local MsgBody = {
        Cmd = SubMsgID,
        Clothing ={
            ChooseType = InID
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

end

--发送改变自动使用类型
function FashionDecoMgr:SendAutoUseType(InID)
    if self:CheckIsInSpecialState(MajorUtil.GetMajorEntityID()) then
        return
    end
    local MsgID = FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE
    local SubMsgID = FASHION_DECORTTE_SUB_ID.CsFashionDecorateClothing
    local MsgBody = {
        Cmd = SubMsgID,
        Clothing ={
            ChooseType = InID
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)

end

--发送脱衣服
function FashionDecoMgr:SendUnClothing(InType)
    if self:CheckIsInSpecialState(MajorUtil.GetMajorEntityID()) then
        MsgTipsUtil.ShowTips(LSTR(1030016))--当前状态无法装备
        return
    end
    local MsgID = FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE
    local SubMsgID = FASHION_DECORTTE_SUB_ID.CsFashionDecorateUnClothing

    local MsgBody = {
        Cmd = SubMsgID,
        Unclothing ={
            DecorateType = InType
        }
    }
    self.bPauseAutoUse = true
    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end

--发送收藏
function FashionDecoMgr:SendCollect(InID,InNewState)

    if self.GLOBAL_CFG_FASHIONDECO_MAXCOLLECTNUM ~= nil and self.GLOBAL_CFG_FASHIONDECO_MAXCOLLECTNUM < FashionDecoVM:GetCollectNum() then
        --local itemCurrentSelectedCfg = FashionDecorateCfg:FindCfgByKey(InID)
        --if itemCurrentSelectedCfg ~= nil then
        --_G.MsgTipsUtil.ShowTips(string.format(LSTR(1030017)),itemCurrentSelectedCfg.Name,FashionDecoVM:GetCollectNum(),self.GLOBAL_CFG_FASHIONDECO_MAXCOLLECTNUM)-- bodystring.format(LSTR(720008), AchievementDefine.TagetAchievementTotalNum) 
        --end
        MsgTipsUtil.ShowTips(LSTR(1030018))
        return
    end
    local MsgID = FASHION_DECORTTE_CS_CMD.CS_CMD_FASHION_DECORATE
    local SubMsgID = FASHION_DECORTTE_SUB_ID.CsFashionDecorateCollect

    local MsgBody = {
        Cmd = SubMsgID,
        Collect ={
            ID = InID,
            IsCollect = InNewState
        }
    }

    GameNetworkMgr:SendMsg(MsgID, SubMsgID, MsgBody)
end
--发送网络包    --End

--工具函数 --Start

--检测是否处于特殊状态
function FashionDecoMgr:CheckIsInSpecialState(InEntityID,EscapeKey)
    local localMajorEntityID = MajorUtil.GetMajorEntityID()
    local bIsMajorCheck = false
    if InEntityID == localMajorEntityID then
        bIsMajorCheck = true
    end

    if self.CurrentMajorLockMap[FashionDecoDefine.FashionDecorateHiddenPriority.Map] then
        return true
    end
    if bIsMajorCheck then
        for _,v in pairs(FashionDecoDefine.FashionDecorateHiddenPriority) do
            if EscapeKey ~= v and self.CurrentMajorLockMap[v]  then
                return true
            end
        end
        if RideShootingMgr:IsRideShootingDungeon() then
            return true
        end
        if MountMgr:IsInRide() then
            return true
        end
        if  _G.GoldSaucerMiniGameMgr:IsInGoldSaucerMiniGame() then
            return true
        end
    end
    if  _G.GoldSauserLeapOfFaithMgr:IsCurMapLeapOfFaith() then
        return true
    end


    --检查是否在坐骑上



    if  _G.MagicCardMgr:IsInMagicCardGame(InEntityID) then
        return true
    end
    return false
end
function FashionDecoMgr:GetCurrentEquip(InType)
    return FashionDecoVM:GetCurrentEquip(InType)
end
function FashionDecoMgr:GetTypeNum(InType)
    return FashionDecoVM:GetTypeNum(InType)
end

--检测自动持伞
function FashionDecoMgr:OnUpdateTime()
	local MajorActor = MajorUtil.GetMajor()

    if MajorActor ~= nil then
        --if MajorActor:CheckIsInRainOutDoor() then
            --MajorActor:SetWetByRain(true)
        --else
            --MajorActor:SetWetByRain(false)
        --end
        FashionDecoVM:UpdateDryRestTime()
        local resultChooseType = FashionDecoVM:GetCurrentChooseType()
        local MapID = PWorldMgr:GetCurrMapResID()
        local CurWeatherId = WeatherUtil.GetMapWeather(MapID, 0)
        --雨天，看到很多系统都是这种直接使用
        if CurWeatherId == 7 or CurWeatherId == 8 or CurWeatherId == 10  then
            local CurrentUmbrellaID = FashionDecoVM:GetCurrentEquip(FashionDecoDefine.FashionDecoType.Umbrella)
            local CurrentUmbrellaNum = FashionDecoVM:GetTypeNum(FashionDecoDefine.FashionDecoType.Umbrella)
            local IsInRainOutDoor = MajorActor:CheckIsInRainOutDoor() 

            --设置自动撑伞
            if resultChooseType ~= nil and resultChooseType ~= FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByNone and CurrentUmbrellaNum > 0 then
                if IsInRainOutDoor then--现在在屋外
                    if self.bIsOurDoorLastCheck == false then--之前在屋内
                        self.bPauseAutoUse = false
                    end
                    if not self.bPauseAutoUse then
                        local result = CurrentUmbrellaID
                        if result == nil or result == 0 and not self:CheckIsInSpecialState(MajorUtil.GetMajorEntityID())  then
                            self:SendClothing(1,true,false)
                        end
                    end
                    self.bIsOurDoorLastCheck = true
                else--现在在屋内
                    if self.bIsOurDoorLastCheck == true then--之前在屋外
                        --self.bPauseAutoUse = false
                    end
                    if not self.bPauseAutoUse then
                        local result = CurrentUmbrellaID
                        if result ~= nil and result > 0 then
                            self:SendUnClothing(FashionDecoDefine.FashionDecoType.Umbrella)
                        end
                    end

                    self.bIsOurDoorLastCheck = false
                end
            end
                        --设置自动湿身
                        if IsInRainOutDoor  then
                            if resultChooseType == FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByNone and (CurrentUmbrellaID == nil or CurrentUmbrellaID <= 0 ) then
                                self:ReSetWetToDryRestTime(MajorUtil.GetMajorEntityID(),true)
                                MajorActor:SetWetByRain(true)
                            end
                            if resultChooseType ~= FashionDecoDefine.FashionDecorateAutoUseChooseType.FashionDecorateUseByNone and self.bPauseAutoUse and (CurrentUmbrellaID == nil or CurrentUmbrellaID <= 0 ) then
                                self:ReSetWetToDryRestTime(MajorUtil.GetMajorEntityID(),true)
                                MajorActor:SetWetByRain(true)
                            end
                        end
        else
            if self.NeedAutoUnWearOnce  then
                if self.IsInitByNet then
                    self.NeedAutoUnWearOnce = false
                    if FashionDecoVM:IsInAutoUseType() then
                        if not self.LastWearByClick then
                            self:SendUnClothing(FashionDecoDefine.FashionDecoType.Umbrella)
                        end
                    end
                end

            end
        end

    end
end
function FashionDecoMgr:CheckFashionDecorateHiddenState(InType)
	local MajorActor = MajorUtil.GetMajor()

    if MajorActor ~= nil then
        return MajorActor:CheckFashionDecorateHiddenState(InType)
    end
end
--是否是自动使用状态
function FashionDecoMgr:IsInAutoUseType()
    FashionDecoVM:IsInAutoUseType()
end

--获取第一个解锁的类型
function FashionDecoMgr:GetFirstUnlockedType()
    return FashionDecoVM:GetFirstUnlockedType()
end

--是否是新的未读
function FashionDecoMgr:IsNewToRead(InID)
    return FashionDecoVM:IsNewToRead(InID)
end

--设置主界面VM
function FashionDecoMgr:SetMainVM(InMainVM)
    FashionDecoVM:SetMainVM(InMainVM)
end

--检查是否有已收藏元素
function FashionDecoMgr:CheckHasCollect()
    return FashionDecoVM:CheckHasCollect()
end


--按照类型生成数据
function FashionDecoMgr:GetListDataByType(InType,InVMType)
	return FashionDecoVM:GetListDataByType(InType,InVMType)
end
--按照技能生成按钮VM数据
function FashionDecoMgr:GetActionListDataByID(InCurrentSelectedID,InVMType)
    return FashionDecoVM:GetActionListDataByID(InCurrentSelectedID,InVMType)
end
--改变姿势
function FashionDecoMgr:PlaySwitchAction()
    self:ReqChangeIdleAnim()
end

--改变姿势
function FashionDecoMgr:ReqChangeIdleAnim()
    EmotionMgr:ReqChangeIdleAnim()
end

--播放本地动作
function FashionDecoMgr:PlaySkillLocalAction(InCurrentSelectedID,InID)
    FashionDecoVM:PlaySkillAction(InCurrentSelectedID,InID)
end

--播放技能
function FashionDecoMgr:PlaySkillAction(InCurrentSelectedID,InID)
    local Major = MajorUtil.GetMajor()
        if Major and Major.CharacterMovement then
            local Velocity = Major.CharacterMovement.Velocity
            if (Velocity.X ~= 0 or Velocity.Y ~= 0 or Velocity.Z ~= 0)  then
                MsgTipsUtil.ShowTips(LSTR(1030015))--移动中无法释放技能
                return
            end
            self:SendPlaySkillAction(InCurrentSelectedID,InID)
        else
            --角色已销毁（转场、断线）
            return false
        end
end


function FashionDecoMgr:SetCurrentChooseType(InChooseType)
    FashionDecoVM:SetCurrentChooseType(InChooseType)
end

--获取当前装备
function FashionDecoMgr:GetCurrentClothingMap()
    return FashionDecoVM.CurrentClothingMap
end

--获取当前的AutoUse类型
function FashionDecoMgr:GetCurrentChooseType()
    return FashionDecoVM:GetCurrentChooseType()
end

function FashionDecoMgr:ReSetWetToDryRestTime(InEntityID,bByRain)
    FashionDecoVM:ReSetWetToDryRestTime(InEntityID,bByRain)
end
function FashionDecoMgr:OnHideMainView()
    FashionDecoVM:OnHideMainView()
end
return FashionDecoMgr