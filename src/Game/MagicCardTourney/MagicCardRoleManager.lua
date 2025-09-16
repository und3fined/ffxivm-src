---
--- Author: carl
--- DateTime: 2022-05-17 19:01
--- Description: 幻卡大赛对局角色管理
---

local ProtoRes = require("Protocol/ProtoRes")
local EventID = require("Define/EventID")
local RoleInfoMgr = require("Game/Role/RoleInfoMgr")
local Utils = require("Game/MagicCard/Module/CommonUtils")
local TourneyDefine = require("Game/MagicCardTourney/MagicCardTourneyDefine")
local ActorAnimService = require("Game/MagicCard/Module/ActorAnimService")
local GameEventRegister = require("Register/GameEventRegister")
local MagicCardVMUtils = require("Game/MagicCard/MagicCardVMUtils")
local ProtoCommon = require("Protocol/ProtoCommon")
local NpcAnimEnum = ProtoRes.fantasy_card_npc_anim_enum
local MajorAnimEnum = ProtoRes.fantasy_card_major_anim_enum
local RaceTypeEnum = ProtoCommon.race_type
local LuaClass = require("Core/LuaClass")
local ActorUtil = require("Utils/ActorUtil")
local MajorUtil = require("Utils/MajorUtil")
local TourneyVMUtils = require("Game/MagicCardTourney/MagicCardTourneyVMUtils")
local ClientActorFactory = require("Game/Actor/ClientActorFactory")

local EActorType = _G.UE.EActorType

local MagicCardRoleManager = LuaClass()

function MagicCardRoleManager:Ctor()
--     repeated uint64 PlayerTournamentStart = 1;  // 玩家进入大赛对局
    -- repeated uint64 PlayerTournamentEnd = 2;    // 玩家退出大赛对局
    -- repeated Desk Desks = 3;                    // 桌子状态
    -- message Desk {
    --     int32 ID = 1;                   // 桌子ID
    --     repeated RobotNPC Players = 2;  // 两个对局玩家，数组为空表示没有玩家
    --     uint64 EndTime = 3;             // 对局结束戳MS(UTC)
    -- }
    -- message RobotNPC {
    --     uint64 RoleID = 1;  // 玩家ID用于拉取形象
    --     int32 NameID = 2;   // 机器人名字ID
    -- }
    self.NearDistance = 150  --判断移动NPC是否在桌子附近的最大距离
    self:Init()
end

function MagicCardRoleManager:Init()
    self.MajorDeskID = 0
    self.DeskTimer = {}
    self.AllPlayingDeskCache = {}   -- 所有对局桌子玩家信息
    self.InGamePlayerEntityIDMap = {}  --进入大赛对局玩家
    self.OverGameRoleIDList = {} --退出大赛对局玩家
    self.StayingDeskList = {} -- 观众NPC停留桌子
    self.StoolCache = {}
    self.PVPRealOpponentRoleID = 0 -- PVP模式下的真实玩家RoleID,非创建出来的虚拟对手，用于关闭结算界面时恢复显示
end

---@type 进入对局室
function MagicCardRoleManager:OnEnterMatchRoom()
    self.GameEventRgister = GameEventRegister.New()
    self.GameEventRgister:Register(EventID.VisionEnter, self, self.OnVisionEnter)
    self.GameEventRgister:Register(EventID.ActorDestroyed, self, self.OnEventNPCDestroy)
end

---@type 退出对局室
function MagicCardRoleManager:OnExitMatchRoom()
    if self.DeskTimer then
        for _, TimerID in pairs(self.DeskTimer) do
            _G.TimerMgr:CancelTimer(TimerID)
        end
        self.DeskTimer = {}
    end
    self:RemoveAllVirtualPlayers()
    self:Init()
    
    if self.GameEventRgister then
        self.GameEventRgister:UnRegisterAll()
        self.GameEventRgister = nil
    end
end

---@param Params table
function MagicCardRoleManager:OnVisionEnter(Params)
    local EntityID = Params.ULongParam1
    if MajorUtil.IsMajor(EntityID) then
        return
    end

    local ActorType = ActorUtil.GetActorType(EntityID)
    if ActorType ~= EActorType.Player then
       return
    end
    
    self:ShowPlayerRankTag(EntityID, true)
end

function MagicCardRoleManager:OnEventNPCDestroy(Params)
    if (Params.IntParam1 ~= EActorType.Npc and Params.IntParam1 ~= EActorType.Player) then
        return
    end
    local EntityID = Params.ULongParam1
    if (EntityID ~= nil and EntityID == self.CreatedNPCEntityID) then
        if (ActorAnimService ~=nil) then
            ActorAnimService:Reset()
        end
    end
end

-------------------------------------------当前对局玩家管理 ----------------------------------------
-----
---@type 当前对局双方形象处理
function MagicCardRoleManager:OnHandleOpponentAndMajor(IsPVP, OpponentRoleSimple, OpponentResID)
    if not IsPVP then
        return
    end

    self.PVPRealOpponentRoleID = OpponentRoleSimple and OpponentRoleSimple.RoleID
    _G.UE.UActorManager:Get():HideAllPlayer(true)
    self:HideAllVirtualPlayers(true)

    local DeskID, LocationInfoList = nil, {} --self:GetAvailableDeskLocationAndRotation()
    if self.MajorDeskID and self.MajorDeskID > 0 then
        DeskID = self.MajorDeskID
        LocationInfoList = TourneyVMUtils.GetLocationAndRotationOfPlayers(self.MajorDeskID)
    else
        DeskID, LocationInfoList = self:GetAvailableDeskLocationAndRotation()
    end

    --未找到空闲位置，默认取第一桌
    if DeskID == nil then
        DeskID = 1
        LocationInfoList = TourneyVMUtils.GetLocationAndRotationOfPlayers(DeskID)
        self:RemoveVirtualPlayerByDeskID(DeskID)
    end

    if LocationInfoList and #LocationInfoList >= 2 then
        local LeftLocationInfo = LocationInfoList[1]
        local RightLocationInfo = LocationInfoList[2]
        if LeftLocationInfo == nil or RightLocationInfo == nil then
            return
        end

        if self.CreatedNPCEntityID == nil or self.CreatedNPCEntityID == 0 then
            self.CreatedNPCEntityID, self.OpponentStool = self:CreateOpponentVirtualCharacter(OpponentRoleSimple, OpponentResID, LeftLocationInfo)
        end

        _G.UE.UActorManager:Get():HideActor(self.CreatedNPCEntityID, false) -- 如果是PVP那么需要显示，因为PVP的对象是player

        self:HandleMajor(RightLocationInfo, LeftLocationInfo.Location)
        local DeskCache = {
            DeskID = DeskID,
            DeskLocation = TourneyVMUtils.GetDeskLocation(DeskID),
            PlayerList = {},
        }
        self.AllPlayingDeskCache[DeskID] = DeskCache  --本地玩家对局加入队列，防止虚拟玩家在当前桌生成
        self.MajorDeskID = DeskID

        return self.CreatedNPCEntityID
    end
end

---@type 获取空闲桌子位置
function MagicCardRoleManager:GetAvailableDeskLocationAndRotation()
    local DeskCount = TourneyVMUtils.GetMaxDeskNum()
    if DeskCount <= 0 then
        return
    end
    local DeskID = 0
    if self.AllPlayingDeskCache == nil or next(self.AllPlayingDeskCache) == nil then
        DeskID = math.random(DeskCount)
    else
        local EmptyDeskList = {}
        for i = 1, DeskCount do
            if not self.AllPlayingDeskCache[i] then
                table.insert(EmptyDeskList, i)
            end
        end
        local EmptyCount = #EmptyDeskList
        local RandomIndex = math.random(EmptyCount)
        DeskID = EmptyDeskList[RandomIndex]
    end

    if DeskID and DeskID > 0 then
        return DeskID, TourneyVMUtils.GetLocationAndRotationOfPlayers(DeskID)
    end
end

---@type 复制对手虚拟角色
---@param OpponentRoleSimple table 被复制对象信息
---@param LocatioonInfo table 位置和旋转
---@param OpponentResID number 备用NPCBaseID
---@return CreatedNPCEntityID 新角色EntityID
---@return StoolActor 凳子Actor
function MagicCardRoleManager:CreateOpponentVirtualCharacter(OpponentRoleSimple, OpponentResID, LocatioonInfo)
    if LocatioonInfo == nil then
        return
    end

    --处理对手玩家形象和位置
    local NewLocation = LocatioonInfo.Location
    local NewRotation = LocatioonInfo.Rotation
    local NpcActor = nil
    local CreatedNPCEntityID = nil
    local StoolActor = nil
    local OpponentRace = nil
    if OpponentRoleSimple then
        local TempResID = 29000080 -- 一个临时用的模型
        OpponentRace = OpponentRoleSimple.Race
        CreatedNPCEntityID = _G.UE.UActorManager:Get():CreateClientActor(_G.UE.EActorType.Player, 0, TempResID, NewLocation, NewRotation)
        NpcActor = ActorUtil.GetActorByEntityID(CreatedNPCEntityID)
        if (NpcActor ~= nil) then
            local Character = NpcActor:Cast(_G.UE.ABaseCharacter)
            ActorUtil.UpdateAvatar(Character, OpponentRoleSimple)  --复制对手形象
        else
            FLOG_ERROR("复制玩家角色失败")
        end
    elseif OpponentResID and OpponentResID > 0 then  --没有找到玩家形象，所以采用NPCBaseID生成虚拟角色
        CreatedNPCEntityID = _G.UE.UActorManager.Get():CreateClientActor(_G.UE.EActorType.Npc, 0, OpponentResID, NewLocation, NewRotation)
        NpcActor = ActorUtil.GetActorByEntityID(CreatedNPCEntityID)
        
        if (NpcActor ~= nil) then
            local AttributeComp = NpcActor:GetAttributeComponent()
            if AttributeComp and AttributeComp.RaceID == RaceTypeEnum.RACE_TYPE_Lalafell then
                OpponentRace = AttributeComp.RaceID
            end
            
        else
            FLOG_ERROR("NPC角色创建失败,请检查NPC表格和NPCBase表是否配置该ID"..OpponentResID)
        end
    else
        FLOG_ERROR("备用NPCBaseID 参数为空或小于0!!!")
    end

    if (NpcActor ~= nil) then
        _G.UE.UVisionMgr.Get():RemoveFromVision(NpcActor)
        local StoolHigh = 47 --凳子高度
        local HalfHeight = NpcActor:GetCapsuleHalfHeight()
        
        --生成凳子垫高
        if OpponentRace == RaceTypeEnum.RACE_TYPE_Lalafell then
            StoolActor = self:AllocStool(NewLocation, NewRotation)
            NewLocation.Z = NewLocation.Z + StoolHigh + HalfHeight --角色放凳子上方
            NpcActor:K2_SetActorLocation(NewLocation, false, nil, false)
        else
            NewLocation = _G.UE.FVector(NewLocation.X, NewLocation.Y, NewLocation.Z + HalfHeight)
        end
        _G.HUDMgr:UpdateActorVisibility(CreatedNPCEntityID, false, false)
        local CollisionComponent = NpcActor:GetComponentByClass(_G.UE.UCapsuleComponent)
        if (CollisionComponent) then
            local CapsuleComponent = CollisionComponent:Cast(_G.UE.UCapsuleComponent)
            if (CapsuleComponent) then
                CapsuleComponent:SetCollisionEnabled(_G.UE.ECollisionEnabled.NoCollision)
            end
        end
    else
        _G.FLOG_ERROR("错误，加载角色失败，请检查！")
    end

    return CreatedNPCEntityID, StoolActor
end

---@type 设置本地玩家位置和旋转
function MagicCardRoleManager:HandleMajor(LocationInfo, LookAtLocation)
    if LocationInfo == nil then
        return
    end

    _G.UE.UActorManager:Get():HideActor(MajorUtil.GetMajorEntityID(), false)
    local MajorLocation = LocationInfo.Location
    local MajorRotation = LocationInfo.Rotation
    local Major = MajorUtil.GetMajor()
    if Major then
        _G.UE.UVisionMgr.Get():RemoveFromVision(Major)
        self.CurMajorLoc = Major:FGetActorLocation()
        self.CurMajorRotation = Major:K2_GetActorRotation()
        Major:DoClientModeEnter()

        local function SwitchToGameState()
           self:StopAnimationAndSkill()
            --生成凳子垫高
            if MajorUtil:GetMajorRaceID() == RaceTypeEnum.RACE_TYPE_Lalafell then
                self.MajorStool = self:AllocStool(MajorLocation, MajorRotation)
                MajorLocation.Z = MajorLocation.Z + 100 --角色放凳子上方
            end
            Major:K2_SetActorLocation(MajorLocation, false, nil, false)
            if LookAtLocation then
                MajorUtil.LookAtPos(LookAtLocation)
            end
        end
        Utils.Delay(0.1, SwitchToGameState)
    end
end

function MagicCardRoleManager:StopAnimationAndSkill()
    local CombatComponent = MajorUtil.GetMajor():GetSkillComponent()
    if CombatComponent ~= nil then
        CombatComponent:BreakSkill()
    end
    _G.EmotionMgr:StopAllEmotions(MajorUtil.GetMajorEntityID(), false)
end

---@type 恢复玩家位置
function MagicCardRoleManager:ReSetMajorLocPosition()
    if self.CurMajorLoc == nil or self.CurMajorRotation == nil then
        return
    end
    local Major = MajorUtil.GetMajor()
    if Major then
        Major:K2_SetActorLocation(self.CurMajorLoc, false, nil, false)
        Major:FSetRotationForServer(self.CurMajorRotation)
        self.CurMajorLoc = nil
        self.CurMajorRotation = nil
        local function RestoreState()
            Major:DoClientModeExit()
            print("[MagicCardRoleManager]ReSetMajorLocPosition:DoClientModeExit")
        end
        Utils.Delay(0.1, RestoreState)
    end
end

---@type 播放虚拟玩家默认待机动作
function MagicCardRoleManager:PlayVirtualPlayerDefaultAnim(EntityID)
    local NpcActor = ActorUtil.GetActorByEntityID(EntityID)
    if NpcActor == nil then
        return
    end

    local NpcAnimComponent = NpcActor:GetAnimationComponent()
    if NpcAnimComponent == nil then
        return
    end

    local TimelineID = MagicCardVMUtils.GetFantasyCardTimelineID(NpcAnimEnum.Anim_InGame_Normal)
    if TimelineID and TimelineID > 0 then
        NpcAnimComponent:PlayActionTimeline(TimelineID)
    end
end

---@type 生成凳子
function MagicCardRoleManager:AllocStool(NewLocation, NewRotation)
    --凳子的X轴朝向不正确，正确的应该朝向左边
    local LookAtPos = NewLocation + NewRotation:GetRightVector() * -100
    local TargetRotation = _G.UE.UKismetMathLibrary.FindLookAtRotation(NewLocation, LookAtPos)
    local CalibrateLocation = NewLocation + NewRotation:GetForwardVector() * -15 -- 凳子往前挪一点，使玩家可以踩在中间
    -- 缓存容易出错，暂弃
    --local NewStool = self.StoolCache and self.StoolCache[#self.StoolCache]
    -- if NewStool and _G.UE.UCommonUtil.IsObjectValid(NewStool) then
    --     NewStool:SetActorHiddenInGame(false)
    --     NewStool.StaticMeshComponent:SetCollisionEnabled(_G.UE.ECollisionEnabled.QueryAndPhysics)
    --     NewStool:K2_SetActorLocation(CalibrateLocation, false, nil, false)
    --     NewStool:K2_SetActorRotation(NewRotation, false, nil, false)
    --     table.remove(self.StoolCache, #self.StoolCache)
    -- else
    --     local StoolPath = "StaticMesh'/Game/Assets/bg/ffxiv/wil_w1/twn/common/bgparts/w1t0_w0_stp1.w1t0_w0_stp1'" 
    --     local ObjectGCType = require("Define/ObjectGCType")
    --     local Obj = _G.ObjectMgr:LoadObjectSync(StoolPath, ObjectGCType.LRU)
    --     NewStool = _G.CommonUtil.SpawnActor(_G.UE.AStaticMeshActor.StaticClass(), CalibrateLocation, NewRotation)
    --     if NewStool then
    --         NewStool:SetMobility(_G.UE.EComponentMobility.Movable)
    --         NewStool.StaticMeshComponent:SetStaticMesh(Obj)
    --     end
    -- end

    local StoolPath = "StaticMesh'/Game/Assets/bg/ffxiv/wil_w1/twn/common/bgparts/w1t0_w0_stp1.w1t0_w0_stp1'" 
    local ObjectGCType = require("Define/ObjectGCType")
    local Obj = _G.ObjectMgr:LoadObjectSync(StoolPath, ObjectGCType.LRU)
    local NewStool = _G.CommonUtil.SpawnActor(_G.UE.AStaticMeshActor.StaticClass(), CalibrateLocation, NewRotation)
    if NewStool then
        NewStool:SetMobility(_G.UE.EComponentMobility.Movable)
        NewStool.StaticMeshComponent:SetStaticMesh(Obj)
    end

    return NewStool
end

---@type 移除凳子
function MagicCardRoleManager:RemoveStool(Actor)
    if Actor and _G.UE.UCommonUtil.IsObjectValid(Actor) then
        _G.CommonUtil.DestroyActor(Actor)
        -- Actor:SetActorHiddenInGame(true)
        -- Actor.StaticMeshComponent:SetCollisionEnabled(_G.UE.ECollisionEnabled.NoCollision)
        -- if self.StoolCache == nil then
        --     self.StoolCache = {}
        -- end
        -- table.insert(self.StoolCache, Actor)
    end
end

---@type 移除当前对局凳子
function MagicCardRoleManager:RemoveCurStool()
    if self.OpponentStool then
        self:RemoveStool(self.OpponentStool)
        self.OpponentStool = nil
    end

    if self.MajorStool then
        self:RemoveStool(self.MajorStool)
        self.MajorStool = nil
    end
end

---@type 对局结束
function MagicCardRoleManager:OnMagicCardBattleQuit()
    if (self.CreatedNPCEntityID ~= nil and self.CreatedNPCEntityID > 0) then
        ClientActorFactory:DestoryClientActor(self.CreatedNPCEntityID, _G.UE.EActorType.Player)
        self.CreatedNPCEntityID = 0
    end

    self:ReSetMajorLocPosition()

    if self.MajorDeskID and self.MajorDeskID > 0 then
        self.AllPlayingDeskCache[self.MajorDeskID] = nil
        self.MajorDeskID = 0
    end
    self:RemoveCurStool()
    _G.UE.UActorManager:Get():HideAllPlayer(false)
    self:HideAllVirtualPlayers(false)
end

------------------ 所有桌子的虚拟玩家管理----------------------------------------------------------------------

---@type 对局室虚拟玩家更新
function MagicCardRoleManager:OnMagicCardRoomUpdate(MsgBody)
    if MsgBody == nil then
        return
    end
    self:UpdatePlayersHideInGame(MsgBody.PlayerTournamentStart, MsgBody.PlayerTournamentEnd)
    self:CreateAllVirtualPlayers(MsgBody.Desks)
end


---@type 生成虚拟对局玩家
function MagicCardRoleManager:CreateAllVirtualPlayers(DeskInfoList)
    if DeskInfoList == nil then
        return
    end

    for _, DeskInfo in ipairs(DeskInfoList) do
        local DeskID = DeskInfo.ID
        local PlayerList = DeskInfo.Players
        local PlayerEndTime = DeskInfo.EndTime/1000

        local function OnCreatedSuccess(DeskID)
            --定时移除桌子旁的虚拟玩家
            local Delay = PlayerEndTime - _G.TimeUtil.GetServerTime()
            if Delay >= 0 then
                if self.DeskTimer == nil then
                    self.DeskTimer = {}
                end
                local ExistTimer = self.DeskTimer[DeskID]
                if ExistTimer then
                    _G.TimerMgr:CancelTimer(ExistTimer)
                    self.DeskTimer[DeskID]  = nil
                    self:RemoveVirtualPlayerByDeskID(DeskID)
                end
                local TimerID = _G.TimerMgr:AddTimer(self, self.RemoveVirtualPlayerByDeskID, Delay, nil, 1, DeskID)
                self.DeskTimer[DeskID] = TimerID
            else
                FLOG_ERROR(string.format("虚拟对局桌消失时间有问题,EndTime:%s < CurServerTime:%s", PlayerEndTime, _G.TimeUtil.GetServerTime()))
            end
        end

        self:CreateVirtualPlayerAroundDesk(DeskID, PlayerList, OnCreatedSuccess)
    end
end

---@type 查询玩家并且复制出虚拟对局玩家
function MagicCardRoleManager:CreateVirtualPlayerAroundDesk(DeskID, PlayerList, Callback)
    if DeskID == nil then
        FLOG_ERROR(string.format("[MagicCardRoleManager]:DeskID Is nil !", DeskID))
        return false
    end

    if DeskID <= 0 then
        FLOG_ERROR(string.format("[MagicCardRoleManager]:DeskID %s Is Not Valid!", DeskID))
        return false
    end

    -- 当前桌子正在虚拟对局
    local PlayingDesk = self.AllPlayingDeskCache[DeskID]
    if PlayingDesk then
        return
    end
    
    -- 当前桌子正在玩家对局 
    if self.MajorDeskID and self.MajorDeskID == DeskID then
        return
    end

    if PlayerList == nil or #PlayerList <= 0 then
        return false
    end

    if self.AllPlayingDeskCache == nil then
        self.AllPlayingDeskCache = {}
    end

    local DeskCache = {
        DeskID = DeskID,
        DeskLocation = TourneyVMUtils.GetDeskLocation(DeskID),
        PlayerList = {},
    }

    local RoleIDs = {}
    for _, Player in ipairs(PlayerList) do
        table.insert(RoleIDs, Player.RoleID)
    end

    RoleInfoMgr:QueryRoleSimples(
        RoleIDs,
        function()
            for Index, Player in ipairs(PlayerList) do
                local RoleID = Player.RoleID
                local NPCID = Player.NPCID
                --local RoleVM = RoleInfoMgr:FindRoleVM(RoleID, true)
                -- 特殊处理，屏蔽掉无效玩家
                --local RoleSimple = RoleVM and RoleVM.RoleSimple
                local LocationInfoList = TourneyVMUtils.GetLocationAndRotationOfPlayers(DeskID)
                if LocationInfoList then
                    local LocationInfo = LocationInfoList[Index]
                    local RoleVM = RoleInfoMgr:FindRoleVM(RoleID, true)
                    local RoleSimple = RoleVM and RoleVM.RoleSimple
                    if RoleSimple == nil then
                        FLOG_INFO("复制玩家数据不存在，采用NPCBaseID 生成角色:"..NPCID)
                    end

                    local CreatedEntityID, StoolActor = self:CreateOpponentVirtualCharacter(RoleSimple, NPCID, LocationInfo)
                    if CreatedEntityID and CreatedEntityID > 0 then
                        local PlayerInfo = {
                            EntityID = CreatedEntityID, 
                            NPCID = NPCID, 
                            RoleID = RoleID, 
                            Stool = StoolActor,
                            IsWithStool = StoolActor ~= nil,
                        }
                        table.insert(DeskCache.PlayerList, PlayerInfo)

                        -- 玩家对局时，不显示任何角色
                        if _G.MagicCardTourneyMgr:GetIsInTourney() then
                            _G.UE.UActorManager:Get():HideActor(CreatedEntityID, true)
                            if StoolActor and _G.UE.UCommonUtil.IsObjectValid(StoolActor) then
                                StoolActor:SetActorHiddenInGame(true)
                            end
                        end

                        _G.TimerMgr:AddTimer(self, self.PlayVirtualPlayerDefaultAnim, 2, 0, 1, CreatedEntityID) --播放待机动作
                    end
                end
            end

            self.AllPlayingDeskCache[DeskID] = DeskCache
            if Callback then
                Callback(DeskID)
            end
        end,
        nil,
        false
    )
end

---@type 移除所有虚拟对局玩家
function MagicCardRoleManager:RemoveAllVirtualPlayers()
    if self.AllPlayingDeskCache == nil then
        return
    end

    for DeskID, _ in pairs(self.AllPlayingDeskCache) do
        self:RemoveVirtualPlayerByDeskID(DeskID)
    end

    self.AllPlayingDeskCache = {}
end

---@type 移除指定桌子的虚拟对局玩家
function MagicCardRoleManager:RemoveVirtualPlayerByDeskID(DeskID)
    if self.AllPlayingDeskCache == nil then
        return
    end

    local ToRemoveDesk = self.AllPlayingDeskCache[DeskID]
    if ToRemoveDesk == nil then
        return
    end

    local PlayerList = ToRemoveDesk.PlayerList
    if PlayerList == nil or #PlayerList <= 0 then
        self.AllPlayingDeskCache[DeskID] = nil
        return
    end

    --移除虚拟玩家
    for _, Player in ipairs(PlayerList) do
        local EntityID = Player.EntityID
        _G.UE.UActorManager:Get():RemoveClientActor(EntityID)
        self:RemoveStool(Player.Stool)
    end

    self:RemoveStayingDesk(DeskID)
    self.AllPlayingDeskCache[DeskID] = nil

    --移除计时器
    local ExistTimer = self.DeskTimer[DeskID]
    if ExistTimer then
        _G.TimerMgr:CancelTimer(ExistTimer)
        self.DeskTimer[DeskID]  = nil
    end
end

---@type 隐藏所有虚拟对局玩家
function MagicCardRoleManager:HideAllVirtualPlayers(IsHide)
    if self.AllPlayingDeskCache == nil then
        return
    end

    for _, DeskInfo in pairs(self.AllPlayingDeskCache) do
        local PlayerList = DeskInfo.PlayerList
        if PlayerList and #PlayerList > 0 then
            for _, Player in ipairs(PlayerList) do
                local EntityID = Player.EntityID
                local StoolActor = Player.Stool
                _G.UE.UActorManager:Get():HideActor(EntityID, IsHide)
                if StoolActor and _G.UE.UCommonUtil.IsObjectValid(StoolActor) then
                    StoolActor:SetActorHiddenInGame(IsHide)
                end
            end
        end
    end
end

function MagicCardRoleManager:GetAvailableKey(RoleID, NPCID)
    if RoleID and RoleID > 0 then
        return RoleID
    end

    if NPCID and NPCID > 0 then
        return NPCID
    end
    return nil
end

---@type 更新真实玩家显隐
function MagicCardRoleManager:UpdatePlayersHideInGame(PlayersInGame, PlayersEndGame)
    --玩家进入大赛对局，隐藏
    if PlayersInGame then
        for _, RoleID in ipairs(PlayersInGame) do
            local MajorRoleID = MajorUtil.GetMajorRoleID()
            if MajorRoleID ~= RoleID then
                local Actor = ActorUtil.GetActorByRoleID(RoleID)
                if Actor then
                    local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
                    _G.UE.UActorManager:Get():HideActor(EntityID, true)
                    _G.HUDMgr:UpdateActorVisibility(EntityID, false, false)
                    
                    if self.InGamePlayerEntityIDMap == nil then
                        self.InGamePlayerEntityIDMap = {}
                    end
                    if EntityID then
                        self.InGamePlayerEntityIDMap[EntityID] = EntityID
                    end
                end
            end
        end
    end
    --玩家退出大赛对局，显示
    if PlayersEndGame then
        for _, RoleID in ipairs(PlayersEndGame) do
            -- 如果是当前对手，则先不恢复显示对手真实模型，等关闭结算界面后再显示
            local Actor = ActorUtil.GetActorByRoleID(RoleID)
            local EntityID = ActorUtil.GetEntityIDByRoleID(RoleID)
            if Actor then
                if RoleID ~= self.PVPRealOpponentRoleID then
                    _G.UE.UActorManager:Get():HideActor(EntityID, false)
                    self:ShowPlayerRankTag(EntityID, true)
                    _G.HUDMgr:UpdateActorVisibility(EntityID, true, true)
                end

                if EntityID and self.InGamePlayerEntityIDMap[EntityID] then
                    self.InGamePlayerEntityIDMap[EntityID] = nil
                end
            end
        end
    end
end

---@type HUD 显示玩家头顶排名标识
function MagicCardRoleManager:ShowPlayerRankTag(EntityID, IsShow)
    local EntityIDList = {}
    if EntityID then
        table.insert(EntityIDList, EntityID)
    end
    
    local Params = {
        IsVisible = IsShow,
        EntityIDList = EntityIDList,
    }
    _G.EventMgr:SendEvent(EventID.MagicCardTourneyRankUpdate, Params)
end

---@type 距离NPC最近桌是否正在对局中
function MagicCardRoleManager:IsNearDeskPlaying(NPCEntityID, NearDistance)
    local NPCActor = ActorUtil.GetActorByEntityID(NPCEntityID)
    if NPCActor == nil then
        return false
    end

    if self.AllPlayingDeskCache == nil or next(self.AllPlayingDeskCache) == nil then
        return false
    end

    local Distance = NearDistance
    if Distance == nil or Distance <= 0 then
        Distance = self.NearDistance
    end

    local NPCLocation = NPCActor:K2_GetActorLocation()
    for _, DeskInfo in pairs(self.AllPlayingDeskCache) do
        local DeskLoc = DeskInfo.DeskLocation
        local DistanceToDesk = _G.UE.UKismetMathLibrary.Vector_Distance(NPCLocation, DeskLoc)
        if DistanceToDesk <= NearDistance then
            if self.StayingDeskList == nil then
                self.StayingDeskList = {}
            end
            self.StayingDeskList[NPCEntityID] = DeskInfo.DeskID
            return true
        end
    end
    return false
end

---@type NPC停留桌是否结束对局
function MagicCardRoleManager:IsNearDeskEndPlay(NPCEntityID)
    if NPCEntityID == nil or NPCEntityID <= 0 then
        return true
    end

    if self.StayingDeskList == nil or next(self.StayingDeskList) == nil then
        return true
    end

    if self.AllPlayingDeskCache == nil or next(self.AllPlayingDeskCache) == nil then
        return true
    end

    local StayDeskID = self.StayingDeskList[NPCEntityID]
    if StayDeskID == nil then
        return true
    end

    local PlayingDesk = self.AllPlayingDeskCache[NPCEntityID]
    if PlayingDesk then
        return false
    end
end

---@type 移除NPC停留信息
function MagicCardRoleManager:RemoveStayingDesk(ToRemoveDeskID)
    if self.StayingDeskList == nil or next(self.StayingDeskList) == nil then
        return
    end

    for NPCEntityID, DeskID in pairs(self.StayingDeskList) do
        if ToRemoveDeskID == DeskID then
            self.StayingDeskList[NPCEntityID] = nil
            return
        end
    end
end

---@type 获取对局中的玩家实例ID
function MagicCardRoleManager:GetInGamePlayerEntityIDMap()
    return self.InGamePlayerEntityIDMap
end

return MagicCardRoleManager
